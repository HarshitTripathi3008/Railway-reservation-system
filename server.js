const express = require('express');
const cors = require('cors');
const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
const validator = require('validator');
require('dotenv').config();

const app = express();

// Configuration
const CONFIG = {
    PORT: process.env.PORT || 8081,
    DB_CONFIG: {
        host: 'localhost',
        user: 'root',
        password: '',
        database: 'railway_reservation_system'
    },
    SALT_ROUNDS: 10
};

// Middleware
app.use(cors());
app.use(express.json());

// Middleware for sanitizing inputs
app.use((req, res, next) => {
    if (req.body) {
        Object.keys(req.body).forEach((key) => {
            if (typeof req.body[key] === 'string') {
                req.body[key] = req.body[key].trim();
            }
        });
    }
    next();
});

// Database Connection Pool
const pool = mysql.createPool({
    ...CONFIG.DB_CONFIG,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Validation Utility
const ValidationUtils = {
    validateName(name) {
        if (!name || typeof name !== 'string' || name.length < 2 || name.length > 50) {
            return { isValid: false, message: "Name must be between 2-50 characters." };
        }
        return { isValid: true };
    },

    validateEmail(email) {
        if (!email || !validator.isEmail(email)) {
            return { isValid: false, message: "Invalid email address." };
        }
        return { isValid: true };
    },

    validatePassword(password) {
        const strongPasswordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;
        if (!password || password.length < 8 || !strongPasswordRegex.test(password)) {
            return {
                isValid: false,
                message: "Password must be at least 8 characters, include uppercase, lowercase, number, and special character."
            };
        }
        return { isValid: true };
    }
};



// Train Routes
const TrainRoutes = {
    async searchTrains(req, res) {
        try {
            const { departure_station, arrival_station } = req.query;

            // Validate query parameters
            if (!departure_station || !arrival_station) {
                return res.status(400).json({ success: false, message: 'Both departure and arrival stations are required.' });
            }

            const [trains] = await pool.execute(
                'SELECT t.train_id, t.train_name, t.departure_time, t.arrival_time, t.departure_station, t.arrival_station, ' +
                's.s1, s.s2, s.b1, s.b2, s.a1, s.a2 ' +
                'FROM trains t ' +
                'LEFT JOIN seats s ON t.train_id = s.train_id ' +
                'WHERE departure_station = ? AND arrival_station = ?',
                [departure_station, arrival_station]
            );

            if (trains.length > 0) {
                trains.forEach(train => {
                    train.available_tickets = train.seats_available;
                });

                res.json({ success: true, trains });
            } else {
                res.json({ success: false, message: 'No trains found.' });
            }
        } catch (error) {
            console.error('Error in search-trains route:', error);
            res.status(500).json({ success: false, message: 'Internal server error.' });
        }
    }
};

// Booking Routes
const BookingRoutes = {
    async bookTicket(req, res) {
        const { train_id, passenger_name, contact_info, user_id, age, seat_class } = req.body;

        if (!train_id || !passenger_name || !contact_info || !user_id || !age || !seat_class) {
            return res.status(400).json({ success: false, message: 'Missing required fields. Please make sure all fields are provided.' });
        }

        let connection;
        try {
            connection = await pool.getConnection();
            await connection.beginTransaction();

            // Check if user exists
            const [users] = await connection.execute('SELECT * FROM users WHERE user_id = ?', [user_id]);
            if (users.length === 0) {
                await connection.rollback();
                return res.status(404).json({ success: false, message: 'User not found.' });
            }

            // Check if train exists
            const [trains] = await connection.execute('SELECT * FROM trains WHERE train_id = ? FOR UPDATE', [train_id]);
            if (trains.length === 0) {
                await connection.rollback();
                return res.status(404).json({ success: false, message: 'Train not found.' });
            }

            // Check seat availability
            const [seats] = await connection.execute('SELECT * FROM seats WHERE train_id = ? FOR UPDATE', [train_id]);
            if (seats.length === 0) {
                await connection.rollback();
                return res.status(400).json({ success: false, message: 'No seat availability data found for this train.' });
            }

            const seatAvailability = seats[0];

            // Check seat availability based on class
            let availableSeats = seatAvailability[seat_class];
            if (availableSeats <= 0) {
                await connection.rollback();
                return res.status(400).json({ success: false, message: 'No available seats for this class.' });
            }

            // Insert the booking
            const [bookingResult] = await connection.execute(
                'INSERT INTO bookings (train_id, passenger_name, contact_info, user_id, age, seat_class, status, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
                [train_id, passenger_name, contact_info, user_id, age, seat_class, 'Booked', new Date().toISOString()]
            );

            // Update seat availability
            let updateSeatQuery = `UPDATE seats SET ${seat_class} = ${seat_class} - 1 WHERE train_id = ?`;
            await connection.execute(updateSeatQuery, [train_id]);

            await connection.commit();

            // Get the updated seats available for the train
            const [updatedSeats] = await connection.execute('SELECT * FROM seats WHERE train_id = ?', [train_id]);

            // Fetch train details to include in the response
            const [trainDetails] = await connection.execute('SELECT * FROM trains WHERE train_id = ?', [train_id]);

            res.status(201).json({
                success: true,
                message: 'Booking successful.',
                booking_id: bookingResult.insertId,
                train_name: trainDetails[0].train_name, 
                passenger_name: passenger_name,
                seat_class: seat_class,
                contact_info: contact_info,
                age: age,
                train_id: train_id
            });
        } catch (error) {
            if (connection) {
                await connection.rollback();
            }
            console.error('Error in booking ticket:', error);
            res.status(500).json({ success: false, message: 'Internal server error.' });
        } finally {
            if (connection) {
                connection.release();
            }
        }
    },

    async cancelTicket(req, res) {
        const { booking_id } = req.body;

        if (!booking_id) {
            return res.status(400).json({ success: false, message: 'Booking ID is required.' });
        }

        let connection;
        try {
            connection = await pool.getConnection();
            await connection.beginTransaction();

            const [bookings] = await connection.execute('SELECT * FROM bookings WHERE booking_id = ? FOR UPDATE', [booking_id]);

            if (bookings.length === 0) {
                await connection.rollback();
                return res.status(404).json({ success: false, message: 'Booking not found.' });
            }

            const booking = bookings[0];

            if (booking.status === 'Cancelled') {
                await connection.rollback();
                return res.status(400).json({ success: false, message: 'Ticket is already cancelled.' });
            }

            // Update booking status to 'Cancelled'
            await connection.execute('UPDATE bookings SET status = ? WHERE booking_id = ?', ['Cancelled', booking_id]);

            // Update seat availability in the `seats` table
            let updateSeatQuery = `UPDATE seats SET ${booking.seat_class} = ${booking.seat_class} + 1 WHERE train_id = ?`;
            await connection.execute(updateSeatQuery, [booking.train_id]);

            await connection.commit();

            res.json({
                success: true,
                message: 'Ticket successfully cancelled.',
                booking_id: booking_id,
                train_id: booking.train_id
            });
        } catch (error) {
            if (connection) {
                await connection.rollback();
            }
            console.error('Error in cancel ticket:', error);
            res.status(500).json({ success: false, message: 'Internal server error.' });
        } finally {
            if (connection) {
                connection.release();
            }
        }
    }
};

// Admin Routes
const AdminRoutes = {
    async getAdminDetails(req, res) {
        try {
            const { admin_id } = req.body;

            if (!admin_id) {
                return res.status(400).json({ success: false, message: 'Admin ID is required.' });
            }

            const [admin] = await pool.execute('SELECT * FROM admins WHERE admin_id = ?', [admin_id]);

            if (admin.length === 0) {
                return res.status(404).json({ success: false, message: 'Admin not found.' });
            }

            res.json({
                success: true,
                admin: admin[0]
            });
        } catch (error) {
            console.error('Error fetching admin details:', error);
            res.status(500).json({ success: false, message: 'Internal server error.' });
        }
    },

    async totalBookingsByUser(req, res) {
        const { user_id } = req.body;

        if (!user_id) {
            return res.status(400).json({ success: false, message: 'User ID is required.' });
        }

        try {
            const [bookings] = await pool.execute(
                'SELECT COUNT(*) AS total_bookings FROM bookings WHERE user_id = ?',
                [user_id]
            );

            res.json({
                success: true,
                total_bookings: bookings[0].total_bookings
            });
        } catch (error) {
            console.error('Error fetching total bookings:', error);
            res.status(500).json({ success: false, message: 'Internal server error.' });
        }
    },

    async trainDetails(req, res) {
        const { train_id } = req.body;

        if (!train_id) {
            return res.status(400).json({ success: false, message: 'Train ID is required.' });
        }

        try {
            const [trainDetails] = await pool.execute(
                'SELECT * FROM trains WHERE train_id = ?',
                [train_id]
            );

            if (trainDetails.length === 0) {
                return res.status(404).json({ success: false, message: 'Train not found.' });
            }

            res.json({
                success: true,
                train: trainDetails[0]
            });
        } catch (error) {
            console.error('Error fetching train details:', error);
            res.status(500).json({ success: false, message: 'Internal server error.' });
        }
    },

    async trainSeatAvailability(req, res) {
        const { train_id } = req.body;

        if (!train_id) {
            return res.status(400).json({ success: false, message: 'Train ID is required.' });
        }

        try {
            const [seatsData] = await pool.execute(
                'SELECT s1, s2, b1, b2, a1, a2 FROM seats WHERE train_id = ?',
                [train_id]
            );

            if (seatsData.length === 0) {
                return res.status(404).json({ success: false, message: 'Train not found or no seat data available.' });
            }

            const seatTypes = ['s1', 's2', 'b1', 'b2', 'a1', 'a2'];
            const availableSeats = seatTypes.reduce((acc, type) => {
                acc[type] = seatsData[0][type];
                return acc;
            }, {});

            res.json({ success: true, availableSeats });
        } catch (error) {
            console.error('Error fetching train seat availability:', error);
            res.status(500).json({ success: false, message: 'Internal server error.' });
        }
    },

    async bookingsByTrain(req, res) {
        const { user_id } = req.body;

        if (!user_id) {
            return res.status(400).json({ success: false, message: 'User ID is required.' });
        }

        try {
            const [bookingsByTrain] = await pool.execute(
                `SELECT 
                    b.train_id,
                    t.train_name,
                    t.departure_station,
                    t.arrival_station,
                    COUNT(CASE WHEN b.status = 'Booked' THEN 1 END) AS booked_count,
                    COUNT(CASE WHEN b.status = 'Cancelled' THEN 1 END) AS cancelled_count,
                    COUNT(*) AS total_bookings,
                    GROUP_CONCAT(DISTINCT b.seat_class) AS booked_seat_classes
                FROM bookings b
                JOIN trains t ON b.train_id = t.train_id
                WHERE b.user_id = ?
                GROUP BY b.train_id, t.train_name, t.departure_station, t.arrival_station`,
                [user_id]
            );

            if (bookingsByTrain.length === 0) {
                return res.status(404).json({ success: false, message: 'No bookings found for the user.' });
            }

            res.json({ success: true, bookingsByTrain });
        } catch (error) {
            console.error('Error fetching bookings by train:', error);
            res.status(500).json({ success: false, message: 'Internal server error.' });
        }
    },

    async totalUsers(req, res) {
        try {
            const [result] = await pool.execute('SELECT COUNT(*) AS total_users FROM users');
            res.json({ success: true, total_users: result[0].total_users });
        } catch (error) {
            console.error('Error fetching total users:', error);
            res.status(500).json({ success: false, message: 'Internal server error.' });
        }
    },

    async adminList(req, res) {
        try {
            const [admins] = await pool.execute('SELECT admin_id, name, email, role FROM admins ORDER BY admin_id');
            if (admins.length === 0) {
                return res.status(404).json({ success: false, message: 'No admins found.' });
            }
            res.json({ success: true, admins });
        } catch (error) {
            console.error('Error fetching admin list:', error);
            res.status(500).json({ success: false, message: 'Internal server error while fetching admin list.' });
        }
    }
};

// Routes
const AuthService = {
    async checkUserExists(email) {
        const [users] = await pool.execute('SELECT * FROM users WHERE email = ?', [email]);
        return users.length > 0;
    },

    async checkAdminExists(email) {
        const [admins] = await pool.execute('SELECT * FROM admins WHERE email = ?', [email]);
        return admins.length > 0;
    },

    async createUser(name, email, password) {
        const hashedPassword = await bcrypt.hash(password, CONFIG.SALT_ROUNDS);
        const [result] = await pool.execute(
            'INSERT INTO users (name, email, password, status) VALUES (?, ?, ?, ?)',
            [name, email, hashedPassword, 'active']
        );
        return result.insertId;
    },

    async createAdmin(name, email, password) {
        const hashedPassword = await bcrypt.hash(password, CONFIG.SALT_ROUNDS);
        const [result] = await pool.execute(
            'INSERT INTO admins (name, email, password, role) VALUES (?, ?, ?, ?)',
            [name, email, hashedPassword, 'admin']
        );
        return result.insertId;
    },

    async verifyPassword(storedPassword, inputPassword) {
        return await bcrypt.compare(inputPassword, storedPassword);
    }
};

// Add this route to the existing server.js file
app.post('/booking-details', async (req, res) => {
    const { booking_id } = req.body;

    if (!booking_id) {
        return res.status(400).json({ 
            success: false, 
            message: 'Booking ID is required.' 
        });
    }

    try {
        // Query to fetch booking details with train information
        const [bookings] = await pool.execute(
            `SELECT b.*, t.train_name 
             FROM bookings b
             LEFT JOIN trains t ON b.train_id = t.train_id
             WHERE b.booking_id = ?`, 
            [booking_id]
        );

        if (bookings.length === 0) {
            console.log(`No booking found for ID: ${booking_id}`);  // Add this line
            return res.status(404).json({ 
                success: false, 
                message: 'Booking not found.' 
            });
        }

        res.json({ 
            success: true, 
            booking: bookings[0] 
        });
    } catch (error) {
        console.error('Detailed error in booking details route:', error);  // Improved error logging
        res.status(500).json({ 
            success: false, 
            message: 'Internal server error.',
            errorDetails: error.message  // Send error message to client for debugging
        });
    }
});
// User Signup (POST route)
app.post('/user/signup', async (req, res) => {
    const { name, email, password } = req.body;

    // Validate input fields
    const nameValidation = ValidationUtils.validateName(name);
    if (!nameValidation.isValid) {
        return res.status(400).json({ success: false, message: nameValidation.message });
    }

    const emailValidation = ValidationUtils.validateEmail(email);
    if (!emailValidation.isValid) {
        return res.status(400).json({ success: false, message: emailValidation.message });
    }

    const passwordValidation = ValidationUtils.validatePassword(password);
    if (!passwordValidation.isValid) {
        return res.status(400).json({ success: false, message: passwordValidation.message });
    }

    try {
        // Check if the user already exists
        const userExists = await AuthService.checkUserExists(email);
        if (userExists) {
            return res.status(400).json({ success: false, message: 'Email already registered.' });
        }

        // Create the new user
        const userId = await AuthService.createUser(name, email, password);
        return res.status(201).json({ success: true, message: 'User created successfully.', user_id: userId });
    } catch (error) {
        console.error('Error in user signup:', error);
        return res.status(500).json({ success: false, message: 'Internal server error.' });
    }
});
// Admin Signup Route (for creating a new admin account)
app.post('/create-admin', async (req, res) => {
    const { name, email, password } = req.body;

    // Validate input fields
    const nameValidation = ValidationUtils.validateName(name);
    if (!nameValidation.isValid) {
        return res.status(400).json({ success: false, message: nameValidation.message });
    }

    const emailValidation = ValidationUtils.validateEmail(email);
    if (!emailValidation.isValid) {
        return res.status(400).json({ success: false, message: emailValidation.message });
    }

    const passwordValidation = ValidationUtils.validatePassword(password);
    if (!passwordValidation.isValid) {
        return res.status(400).json({ success: false, message: passwordValidation.message });
    }

    try {
        // Check if the admin already exists
        const adminExists = await AuthService.checkAdminExists(email);
        if (adminExists) {
            return res.status(400).json({ success: false, message: 'Admin with this email already exists.' });
        }

        // Create the new admin
        const adminId = await AuthService.createAdmin(name, email, password);
        return res.status(201).json({ 
            success: true, 
            message: 'Admin created successfully.', 
            admin_id: adminId 
        });
    } catch (error) {
        console.error('Error in admin signup:', error);
        return res.status(500).json({ success: false, message: 'Internal server error.' });
    }
});

// User Login (POST route)
app.post('/user/login', async (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ success: false, message: 'Email and password are required.' });
    }

    try {
        const [users] = await pool.execute('SELECT * FROM users WHERE email = ?', [email]);

        if (users.length === 0) {
            return res.status(404).json({ success: false, message: 'User not found.' });
        }

        const user = users[0];
        const isPasswordCorrect = await AuthService.verifyPassword(user.password, password);

        if (!isPasswordCorrect) {
            return res.status(401).json({ success: false, message: 'Invalid credentials.' });
        }

        res.json({
            success: true,
            message: 'Login successful.',
            user_id: user.user_id,
            name: user.name,
            email: user.email
        });
    } catch (error) {
        console.error('Error in user login:', error);
        res.status(500).json({ success: false, message: 'Internal server error.' });
    }
});

// Admin Routes

// Admin Login (POST route)
app.post('/admin/login', async (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ success: false, message: 'Email and password are required.' });
    }

    try {
        const [admins] = await pool.execute('SELECT * FROM admins WHERE email = ?', [email]);

        if (admins.length === 0) {
            return res.status(404).json({ success: false, message: 'Admin not found.' });
        }

        const admin = admins[0];
        const isPasswordCorrect = await AuthService.verifyPassword(admin.password, password);

        if (!isPasswordCorrect) {
            return res.status(401).json({ success: false, message: 'Invalid credentials.' });
        }

        res.json({
            success: true,
            message: 'Admin login successful.',
            admin_id: admin.admin_id,
            name: admin.name,
            email: admin.email
        });
    } catch (error) {
        console.error('Error in admin login:', error);
        res.status(500).json({ success: false, message: 'Internal server error.' });
    }
});

app.post('/admin/total-bookings', async (req, res) => {
    const { user_id } = req.body;

    if (!user_id) {
        return res.status(400).json({ success: false, message: 'User ID is required.' });
    }

    try {
        // Query to count total bookings by user
        const [bookings] = await pool.execute(
            'SELECT COUNT(*) AS total_bookings FROM bookings WHERE user_id = ?', 
            [user_id]
        );
        
        res.json({ 
            success: true, 
            total_bookings: bookings[0].total_bookings 
        });
    } catch (error) {
        console.error('Error fetching total bookings:', error);
        res.status(500).json({ success: false, message: 'Internal server error.' });
    }
});

// Train Seat Availability
// Route for train details
app.post('/admin/train-details', async (req, res) => {
    const { train_id } = req.body;

    if (!train_id) {
        return res.status(400).json({ 
            success: false, 
            message: 'Train ID is required.' 
        });
    }

    try {
        // Query to fetch train details
        const [trainDetails] = await pool.execute(
            `SELECT train_id, train_name, departure_station, arrival_station 
             FROM trains 
             WHERE train_id = ?`, 
            [train_id]
        );

        if (trainDetails.length === 0) {
            return res.status(404).json({ 
                success: false, 
                message: 'Train not found.' 
            });
        }

        res.json({ 
            success: true, 
            train: trainDetails[0] 
        });
    } catch (error) {
        console.error('Error fetching train details:', error);
        res.status(500).json({ 
            success: false, 
            message: 'Internal server error.' 
        });
    }
});

// Route for train seat availability
app.post('/admin/train-seats', async (req, res) => {
    const { train_id } = req.body;

    if (!train_id) {
        return res.status(400).json({ 
            success: false, 
            message: 'Train ID is required.' 
        });
    }

    try {
        // Query to get seat availability for a specific train
        const [seatsData] = await pool.execute(
            'SELECT s1, s2, b1, b2, a1, a2 FROM seats WHERE train_id = ?', 
            [train_id]
        );

        if (seatsData.length === 0) {
            return res.status(404).json({ 
                success: false, 
                message: 'Train not found or no seat data available.' 
            });
        }

        // Calculate total and available seats
        const seatTypes = ['s1', 's2', 'b1', 'b2', 'a1', 'a2'];
        const availableSeats = seatTypes.reduce((acc, type) => {
            acc[type] = seatsData[0][type];
            return acc;
        }, {});

        res.json({ 
            success: true, 
            availableSeats 
        });
    } catch (error) {
        console.error('Error fetching train seat availability:', error);
        res.status(500).json({ 
            success: false, 
            message: 'Internal server error.' 
        });
    }
});

// Route for train list (used in the previous implementation)
app.post('/admin/train-list', async (req, res) => {
    try {
        // Query to fetch all trains
        const [trains] = await pool.execute(
            `SELECT train_id, train_name 
             FROM trains`
        );

        if (trains.length === 0) {
            return res.status(404).json({ 
                success: false, 
                message: 'No trains found.' 
            });
        }

        res.json({ 
            success: true, 
            trains 
        });
    } catch (error) {
        console.error('Error fetching train list:', error);
        res.status(500).json({ 
            success: false, 
            message: 'Internal server error.' 
        });
    }
});

// Bookings by Train
app.post('/admin/bookings-by-train', async (req, res) => {
    const { user_id } = req.body;

    if (!user_id) {
        return res.status(400).json({ success: false, message: 'User ID is required.' });
    }

    try {
        // Updated query to include booking status and count bookings based on status
        const [bookingsByTrain] = await pool.execute(
            `SELECT 
                b.train_id,
                t.train_name,
                t.departure_station,
                t.arrival_station,
                COUNT(CASE WHEN b.status = 'Booked' THEN 1 END) AS booked_count,
                COUNT(CASE WHEN b.status = 'Cancelled' THEN 1 END) AS cancelled_count,
                COUNT(*) AS total_bookings,
                GROUP_CONCAT(DISTINCT b.seat_class) AS booked_seat_classes
            FROM bookings b
            JOIN trains t ON b.train_id = t.train_id
            WHERE b.user_id = ?
            GROUP BY b.train_id, t.train_name, t.departure_station, t.arrival_station`,
            [user_id]
        );

        if (bookingsByTrain.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'No bookings found for the user.'
            });
        }

        res.json({
            success: true,
            bookingsByTrain
        });
    } catch (error) {
        console.error('Error fetching bookings by train:', error);
        res.status(500).json({ success: false, message: 'Internal server error.' });
    }
});

// Users List
app.post('/admin/users', async (req, res) => {
    try {
        // Query to get all users 
        const [users] = await pool.execute(
            'SELECT user_id, name, email, status, created_at FROM users ORDER BY created_at DESC'
        );

        if (users.length === 0) {
            return res.status(404).json({ 
                success: false, 
                message: 'No users found.' 
            });
        }

        res.json({ 
            success: true, 
            users 
        });
    } catch (error) {
        console.error('Error fetching users:', error);
        res.status(500).json({ success: false, message: 'Internal server error.' });
    }
});
app.post('/admin/bookings', async (req, res) => {
    try {
        const [bookings] = await pool.query(`
            SELECT 
                b.booking_id, 
                b.train_id, 
                b.passenger_name, 
                b.seat_class, 
                b.status, 
                b.created_at, 
                b.contact_info, 
                b.age,
                t.train_name
            FROM bookings b
            LEFT JOIN trains t ON b.train_id = t.train_id
            ORDER BY b.created_at DESC
        `);
        res.json({ 
            success: true, 
            bookings: bookings 
        });
    } catch (error) {
        console.error('Bookings Fetch Error:', error);
        res.status(500).json({ 
            success: false, 
            message: error.message || 'Internal Server Error' 
        });
    }
});

app.post('/admin/admin-list', async (req, res) => {
    try {
        const [admins] = await pool.execute(
            'SELECT admin_id, name, email, role FROM admins ORDER BY admin_id'
        );
        if (admins.length === 0) {
            return res.status(404).json({ 
                success: false, 
                message: 'No admins found.' 
            });
        }
        res.json({ 
            success: true, 
            admins 
        });
    } catch (error) {
        console.error('Error fetching admin list:', error);
        res.status(500).json({ 
            success: false, 
            message: 'Internal server error while fetching admin list.' 
        });
    }
});

// Add additional routes for train search and booking
app.get('/trains/search', TrainRoutes.searchTrains);
app.post('/bookings', BookingRoutes.bookTicket);
app.post('/cancel', BookingRoutes.cancelTicket);

// Admin specific routes
app.get('/admin/details', AdminRoutes.getAdminDetails);
app.get('/admin/bookings/by-train', AdminRoutes.bookingsByTrain);
app.get('/admin/train-seat-availability', AdminRoutes.trainSeatAvailability);
app.get('/admin/train-details', AdminRoutes.trainDetails);
app.get('/admin/total-users', AdminRoutes.totalUsers);
app.get('/admin/list', AdminRoutes.adminList);

// Start Server
app.listen(CONFIG.PORT, () => {
    console.log(`Server running on http://localhost:${CONFIG.PORT}`);
});

