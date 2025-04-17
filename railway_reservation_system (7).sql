-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 17, 2025 at 03:50 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `railway_reservation_system`
--

-- --------------------------------------------------------

--
-- Table structure for table `admins`
--

CREATE TABLE `admins` (
  `admin_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` varchar(50) DEFAULT 'admin',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admins`
--

INSERT INTO `admins` (`admin_id`, `name`, `email`, `password`, `role`, `created_at`) VALUES
(1, 'Harshit Tripathi', 'admin@gmail.com', '$2a$10$PrYp8oJAxIl/Un2XLU9e0O/K/iDyvZyM1R.1ouV/MDIRsw5WZowe6', 'admin', '2024-12-16 19:10:20'),
(2, 'Gaurav Rai', 'gaurav@gmail.com', '$2a$10$09cXxOCKY7iL2v9FpHf1O.5sgIjgGZKrliHdE27R/GUZJH0NAB2/q', 'admin', '2024-12-17 05:58:00');

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `booking_id` int(11) NOT NULL,
  `train_id` int(11) DEFAULT NULL,
  `passenger_name` varchar(100) NOT NULL,
  `contact_info` varchar(100) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `age` int(11) NOT NULL,
  `seat_class` enum('s1','s2','b1','b2','a1','a2') NOT NULL,
  `status` enum('Booked','Cancelled') DEFAULT 'Booked',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bookings`
--

INSERT INTO `bookings` (`booking_id`, `train_id`, `passenger_name`, `contact_info`, `user_id`, `age`, `seat_class`, `status`, `created_at`) VALUES
(1, 20, 'vishnu', '9776765464', 1, 21, 's1', 'Cancelled', '2024-12-16 09:13:18'),
(2, 20, 'Harshit Tripathi', '0977676546', 1, 20, 'b2', 'Booked', '2024-12-16 11:21:52'),
(3, 20, 'Harshit Tripathi', '0977676546', 1, 20, 's2', 'Booked', '2024-12-16 11:24:29'),
(4, 34, 'Harshit Tripathi', '0977676546', 1, 20, 'a1', 'Booked', '2024-12-16 11:29:04'),
(5, 34, 'Harshit Tripathi', '0977676546', 1, 20, 's2', 'Cancelled', '2024-12-16 11:39:57'),
(6, 34, 'Gaurav Rai', '0790500296', 1, 25, 'b2', 'Booked', '2024-12-16 11:43:30'),
(7, 34, 'harshit', '0790500296', 1, 23, 'b1', 'Booked', '2024-12-16 11:50:15'),
(8, 34, 'Harshit Pandey', '0977456666', 1, 20, 'b2', 'Booked', '2024-12-16 11:52:37'),
(9, 34, 'Harshit Pandey', '0977456666', 1, 21, 's1', 'Booked', '2024-12-16 11:54:38'),
(10, 34, 'Harshit Pandey', '0977456666', 1, 21, 's1', 'Cancelled', '2024-12-16 11:55:47'),
(11, 34, 'Harshit Pandey', '0977456666', 1, 21, 'a1', 'Booked', '2024-12-16 11:58:05'),
(12, 34, 'Harshit Pandey', '0977456666', 1, 21, 'b2', 'Booked', '2024-12-16 11:58:57'),
(13, 34, 'Harshit Pandey', '0977456666', 1, 21, 's1', 'Booked', '2024-12-16 12:00:58'),
(14, 34, 'Harshit Pandey', '0977456666', 1, 21, 's1', 'Booked', '2024-12-16 12:02:04'),
(15, 7, 'Gaurav Rai', '4577456666', 1, 23, 'b2', 'Cancelled', '2024-12-16 16:05:46'),
(16, 36, 'Gaurav Rai', '4577457894', 1, 23, 'b1', 'Booked', '2024-12-16 16:07:16'),
(17, 20, 'Gaurav Rai', '4577456666', 1, 23, 'b2', 'Booked', '2024-12-17 00:13:49'),
(18, 36, 'Harshit Tripathi', '7905002968', 1, 19, 'b1', 'Booked', '2024-12-17 00:19:00'),
(19, 7, 'vishnu', '0735596865', 1, 25, 'a1', 'Booked', '2024-12-17 00:29:50'),
(20, 60, 'vishnu', '0735596865', 1, 25, 'a1', 'Booked', '2024-12-17 00:44:14'),
(21, 18, 'raghu', '5555887722', 1, 56, 'b1', 'Booked', '2024-12-17 00:48:35'),
(22, 60, 'Aaditya Srivastava', '7896543201', 1, 20, 'b2', 'Cancelled', '2024-12-17 02:46:43'),
(23, 36, 'Sridhar', '4569871230', 1, 87, 'a2', 'Cancelled', '2024-12-17 02:50:06'),
(24, 60, 'Harshit Tripathi', '7905002968', 1, 19, 'b2', 'Booked', '2024-12-17 05:03:39'),
(25, 36, 'Harshit Tripathi', '7905002968', 1, 19, 's1', 'Booked', '2024-12-17 07:35:15'),
(26, 60, 'Harshit Tripathi', '7905002968', 1, 18, 'b2', 'Cancelled', '2024-12-18 00:33:33'),
(27, 9, 'Harshit Tripathi', '7905002968', 1, 18, 'a2', 'Booked', '2024-12-18 00:52:02'),
(28, 9, 'Harshit Tripathi', '7905002968', 1, 19, 'b2', 'Booked', '2024-12-18 01:04:47'),
(29, 38, 'Harshit Tripathi', '7905002968', 1, 19, 'a1', 'Cancelled', '2024-12-18 04:18:54');

-- --------------------------------------------------------

--
-- Table structure for table `seats`
--

CREATE TABLE `seats` (
  `seat_id` int(11) NOT NULL,
  `train_id` int(11) DEFAULT NULL,
  `s1` int(11) DEFAULT 0,
  `s2` int(11) DEFAULT 0,
  `b1` int(11) DEFAULT 0,
  `b2` int(11) DEFAULT 0,
  `a1` int(11) DEFAULT 0,
  `a2` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `seats`
--

INSERT INTO `seats` (`seat_id`, `train_id`, `s1`, `s2`, `b1`, `b2`, `a1`, `a2`) VALUES
(1, 1, 72, 72, 72, 72, 72, 72),
(2, 2, 72, 72, 72, 72, 72, 72),
(3, 3, 72, 72, 72, 72, 72, 72),
(4, 4, 72, 72, 72, 72, 72, 72),
(5, 5, 72, 72, 72, 72, 72, 72),
(6, 6, 72, 72, 72, 72, 72, 72),
(7, 7, 72, 72, 72, 72, 71, 72),
(8, 8, 72, 72, 72, 72, 72, 72),
(9, 9, 72, 72, 72, 71, 72, 71),
(10, 10, 72, 72, 72, 72, 72, 72),
(11, 11, 72, 72, 72, 72, 72, 72),
(12, 12, 72, 72, 72, 72, 72, 72),
(13, 13, 72, 72, 72, 72, 72, 72),
(14, 14, 72, 72, 72, 72, 72, 72),
(15, 15, 72, 72, 72, 72, 72, 72),
(16, 16, 72, 72, 72, 72, 72, 72),
(17, 17, 72, 72, 72, 72, 72, 72),
(18, 18, 72, 72, 71, 72, 72, 72),
(19, 19, 72, 72, 72, 72, 72, 72),
(20, 20, 72, 71, 72, 70, 72, 72),
(21, 21, 72, 72, 72, 72, 72, 72),
(22, 22, 72, 72, 72, 72, 72, 72),
(23, 23, 72, 72, 72, 72, 72, 72),
(24, 24, 72, 72, 72, 72, 72, 72),
(25, 25, 72, 72, 72, 72, 72, 72),
(26, 26, 72, 72, 72, 72, 72, 72),
(27, 27, 72, 72, 72, 72, 72, 72),
(28, 28, 72, 72, 72, 72, 72, 72),
(29, 29, 72, 72, 72, 72, 72, 72),
(30, 30, 72, 72, 72, 72, 72, 72),
(31, 31, 72, 72, 72, 72, 72, 72),
(32, 32, 72, 72, 72, 72, 72, 72),
(33, 33, 72, 72, 72, 72, 72, 72),
(34, 34, 69, 72, 71, 69, 70, 72),
(35, 35, 72, 72, 72, 72, 72, 72),
(36, 36, 71, 72, 70, 72, 72, 72),
(37, 37, 72, 72, 72, 72, 72, 72),
(38, 38, 72, 72, 72, 72, 72, 72),
(39, 39, 72, 72, 72, 72, 72, 72),
(40, 40, 72, 72, 72, 72, 72, 72),
(41, 41, 72, 72, 72, 72, 72, 72),
(42, 42, 72, 72, 72, 72, 72, 72),
(43, 43, 72, 72, 72, 72, 72, 72),
(44, 44, 72, 72, 72, 72, 72, 72),
(45, 45, 72, 72, 72, 72, 72, 72),
(46, 46, 72, 72, 72, 72, 72, 72),
(47, 47, 72, 72, 72, 72, 72, 72),
(48, 48, 72, 72, 72, 72, 72, 72),
(49, 49, 72, 72, 72, 72, 72, 72),
(50, 50, 72, 72, 72, 72, 72, 72),
(51, 51, 72, 72, 72, 72, 72, 72),
(52, 52, 72, 72, 72, 72, 72, 72),
(53, 53, 72, 72, 72, 72, 72, 72),
(54, 54, 72, 72, 72, 72, 72, 72),
(55, 55, 72, 72, 72, 72, 72, 72),
(56, 56, 72, 72, 72, 72, 72, 72),
(57, 57, 72, 72, 72, 72, 72, 72),
(58, 58, 72, 72, 72, 72, 72, 72),
(59, 59, 72, 72, 72, 72, 72, 72),
(60, 60, 72, 72, 72, 71, 71, 72),
(61, 61, 72, 72, 72, 72, 72, 72);

-- --------------------------------------------------------

--
-- Table structure for table `trains`
--

CREATE TABLE `trains` (
  `train_id` int(11) NOT NULL,
  `train_name` varchar(100) NOT NULL,
  `departure_station` varchar(100) NOT NULL,
  `arrival_station` varchar(100) NOT NULL,
  `departure_time` datetime NOT NULL,
  `arrival_time` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `trains`
--

INSERT INTO `trains` (`train_id`, `train_name`, `departure_station`, `arrival_station`, `departure_time`, `arrival_time`) VALUES
(1, 'Rajdhani Express', 'New Delhi', 'Mumbai Central', '2024-12-16 17:30:00', '2024-12-17 06:00:00'),
(2, 'Shatabdi Express', 'Chandigarh', 'New Delhi', '2024-12-16 07:00:00', '2024-12-16 10:00:00'),
(3, 'Duronto Express', 'Kolkata', 'Delhi Hazrat Nizamuddin', '2024-12-16 18:00:00', '2024-12-17 06:30:00'),
(4, 'Golden Temple Mail', 'Amritsar', 'Mumbai CST', '2024-12-16 10:30:00', '2024-12-17 07:45:00'),
(5, 'Vande Bharat Express', 'New Delhi', 'Varanasi', '2024-12-16 06:00:00', '2024-12-16 14:00:00'),
(6, 'Howrah Rajdhani', 'Kolkata', 'New Delhi', '2024-12-16 16:30:00', '2024-12-17 06:00:00'),
(7, 'Mysuru Express', 'Mysuru', 'Bangalore', '2024-12-16 08:30:00', '2024-12-16 12:15:00'),
(8, 'Deccan Queen', 'Pune', 'Mumbai CST', '2024-12-16 06:00:00', '2024-12-16 09:00:00'),
(9, 'Tripathi Express', 'Prayagraj', 'Kannauj', '2024-12-16 19:00:00', '2024-12-17 10:30:00'),
(10, 'Trivandrum Express', 'Trivandrum', 'Mumbai CST', '2024-12-16 15:30:00', '2024-12-17 04:00:00'),
(11, 'Mumbai Rajdhani', 'Mumbai Central', 'New Delhi', '2024-12-16 13:30:00', '2024-12-17 06:00:00'),
(12, 'Kochuveli Express', 'Kochuveli', 'New Delhi', '2024-12-16 16:00:00', '2024-12-17 10:00:00'),
(13, 'Satyagrah Express', 'Patna', 'Delhi Hazrat Nizamuddin', '2024-12-16 11:00:00', '2024-12-16 22:00:00'),
(14, 'Swarna Shatabdi', 'Amritsar', 'New Delhi', '2024-12-16 09:00:00', '2024-12-16 12:00:00'),
(15, 'Udhampur Express', 'Udhampur', 'Jammu Tawi', '2024-12-16 12:00:00', '2024-12-16 14:30:00'),
(16, 'Bangalore-Mysore Express', 'Bangalore', 'Mysuru', '2024-12-16 08:00:00', '2024-12-16 09:45:00'),
(17, 'Rajasthan Sampark Kranti', 'Jaipur', 'New Delhi', '2024-12-16 07:30:00', '2024-12-16 12:30:00'),
(18, 'Mahayogi Experess', 'Prayagraj', 'Pune', '2024-12-16 19:30:00', '2024-12-17 11:30:00'),
(19, 'Purushottam Express', 'Puri', 'New Delhi', '2024-12-16 14:00:00', '2024-12-17 07:30:00'),
(20, 'Chennai Express', 'Chennai', 'New Delhi', '2024-12-16 15:30:00', '2024-12-17 08:30:00'),
(21, 'Shiv Ganga Express', 'Varanasi', 'New Delhi', '2024-12-16 10:30:00', '2024-12-16 20:30:00'),
(22, 'Vaigai Express', 'Madurai', 'Chennai', '2024-12-16 06:30:00', '2024-12-16 11:30:00'),
(23, 'Mumbai-Bhopal Express', 'Mumbai CST', 'Bhopal', '2024-12-16 20:00:00', '2024-12-17 05:30:00'),
(24, 'Bhubaneswar Express', 'Bhubaneswar', 'New Delhi', '2024-12-16 13:00:00', '2024-12-17 08:30:00'),
(25, 'Nagpur Shatabdi', 'Nagpur', 'Mumbai CST', '2024-12-16 07:45:00', '2024-12-16 12:30:00'),
(26, 'Nellore Express', 'Nellore', 'Chennai', '2024-12-16 18:30:00', '2024-12-16 22:00:00'),
(27, 'Sampark Kranti Express', 'Lucknow', 'New Delhi', '2024-12-16 09:00:00', '2024-12-16 19:30:00'),
(28, 'Anand Vihar Express', 'Anand Vihar', 'New Delhi', '2024-12-16 16:00:00', '2024-12-16 19:00:00'),
(29, 'Satyagraha Express', 'Mumbai CST', 'Delhi Hazrat Nizamuddin', '2024-12-16 14:00:00', '2024-12-16 23:30:00'),
(30, 'Madhubani Express', 'Madhubani', 'Patna', '2024-12-16 06:15:00', '2024-12-16 09:30:00'),
(31, 'Vishakhapatnam Express', 'Visakhapatnam', 'New Delhi', '2024-12-16 15:00:00', '2024-12-17 05:00:00'),
(32, 'Kolkata Rajdhani', 'Kolkata', 'New Delhi', '2024-12-16 17:30:00', '2024-12-17 08:00:00'),
(33, 'Bhagalpur Express', 'Bhagalpur', 'New Delhi', '2024-12-16 09:30:00', '2024-12-16 17:45:00'),
(34, 'Kanpur Shatabdi', 'Kanpur', 'New Delhi', '2024-12-16 07:00:00', '2024-12-16 10:30:00'),
(35, 'Chandigarh Express', 'Chandigarh', 'New Delhi', '2024-12-16 05:30:00', '2024-12-16 08:00:00'),
(36, 'Mysuru Shatabdi', 'Mysuru', 'Bangalore', '2024-12-16 10:00:00', '2024-12-16 12:15:00'),
(37, 'Nagpur Superfast', 'Nagpur', 'Mumbai CST', '2024-12-16 08:00:00', '2024-12-16 12:15:00'),
(38, 'Mradul Express', 'Kasganj', 'Prayag Junction', '2024-12-18 05:00:00', '2024-12-18 15:30:00'),
(39, 'Patna Express', 'Patna', 'New Delhi', '2024-12-16 14:15:00', '2024-12-16 22:30:00'),
(40, 'Dibrugarh Rajdhani', 'Dibrugarh', 'New Delhi', '2024-12-16 09:30:00', '2024-12-17 08:30:00'),
(41, 'Varanasi Express', 'Varanasi', 'New Delhi', '2024-12-16 15:00:00', '2024-12-16 23:30:00'),
(42, 'Mangalore Express', 'Mangalore', 'Mumbai CST', '2024-12-16 16:00:00', '2024-12-16 21:30:00'),
(43, 'Ajmer Express', 'Ajmer', 'New Delhi', '2024-12-16 07:15:00', '2024-12-16 12:30:00'),
(44, 'Gaya Express', 'Gaya', 'New Delhi', '2024-12-16 10:00:00', '2024-12-16 16:45:00'),
(45, 'Rishikesh Express', 'Rishikesh', 'New Delhi', '2024-12-16 06:00:00', '2024-12-16 09:30:00'),
(46, 'Udhampur Jammu Express', 'Udhampur', 'Jammu Tawi', '2024-12-16 12:30:00', '2024-12-16 15:00:00'),
(47, 'Tirunelveli Express', 'Tirunelveli', 'Chennai', '2024-12-16 05:30:00', '2024-12-16 09:00:00'),
(48, 'Bhopal Express', 'Bhopal', 'Mumbai CST', '2024-12-16 13:00:00', '2024-12-16 19:00:00'),
(49, 'Surat Shatabdi', 'Surat', 'New Delhi', '2024-12-16 10:30:00', '2024-12-16 14:00:00'),
(50, 'Kochi Express', 'Kochi', 'New Delhi', '2024-12-16 15:30:00', '2024-12-17 06:30:00'),
(51, 'Madgaon Express', 'Madgaon', 'Chennai', '2024-12-16 18:30:00', '2024-12-17 01:30:00'),
(52, 'Barmer Express', 'Barmer', 'New Delhi', '2024-12-16 13:00:00', '2024-12-16 19:30:00'),
(53, 'Indore Shatabdi', 'Indore', 'New Delhi', '2024-12-16 07:00:00', '2024-12-16 12:00:00'),
(54, 'Jammu Express', 'Jammu Tawi', 'Prayag Junction', '2024-12-16 17:30:00', '2024-12-17 06:00:00'),
(55, 'Ranchi Express', 'Ranchi', 'New Delhi', '2024-12-16 09:00:00', '2024-12-16 17:30:00'),
(56, 'Jodhpur Express', 'Jodhpur', 'New Delhi', '2024-12-16 14:00:00', '2024-12-16 22:00:00'),
(57, 'Bilaspur Express', 'Bilaspur', 'New Delhi', '2024-12-16 12:30:00', '2024-12-16 19:30:00'),
(58, 'Bhubaneshwar Express', 'Bhubaneshwar', 'New Delhi', '2024-12-16 07:30:00', '2024-12-16 15:00:00'),
(59, 'Ranchi Shatabdi', 'Ranchi', 'New Delhi', '2024-12-16 08:15:00', '2024-12-16 17:30:00'),
(60, 'Mysuru Superfast', 'Mysuru', 'Bangalore', '2024-12-16 08:30:00', '2024-12-16 12:00:00'),
(61, 'Surat Express', 'Surat', 'Mumbai CST', '2024-12-16 10:00:00', '2024-12-16 13:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `password` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `name`, `email`, `status`, `password`, `created_at`) VALUES
(1, 'Harshit Tripathi', 'xyz@gmail.com', 'active', '$2a$10$f3icDZeqlAtsBeCnw6BIS.op/4NIioXz9eCWegJbsJEIdrYWJqi0G', '2024-12-16 13:11:27'),
(2, 'Harshit Tripathi', 'harsh@gmail.com', 'active', '$2a$10$Xr83i/NWL198bMhtRjkIK.03QSlwjq545dtxd91q0iaKW4MjH3On.', '2024-12-17 05:48:19'),
(3, 'Aaditya', 'aaditya@gmail.com', 'active', '$2a$10$0omSuCbo.SS62MJjE837ieq68ZJzZLLQimqlcBH8N7NvOYNPph.La', '2024-12-17 08:19:23'),
(4, 'Harshit pandey', 'harshit@gmail.com', 'active', '$2a$10$g0Gf720TZkR.Mr/Rz3kSR.Lxq90MdK8fPgaU7m1POoyWZ9kxkleh6', '2024-12-17 10:34:26');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admins`
--
ALTER TABLE `admins`
  ADD PRIMARY KEY (`admin_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`booking_id`),
  ADD KEY `train_id` (`train_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `seats`
--
ALTER TABLE `seats`
  ADD PRIMARY KEY (`seat_id`),
  ADD KEY `train_id` (`train_id`);

--
-- Indexes for table `trains`
--
ALTER TABLE `trains`
  ADD PRIMARY KEY (`train_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admins`
--
ALTER TABLE `admins`
  MODIFY `admin_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
  MODIFY `booking_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT for table `seats`
--
ALTER TABLE `seats`
  MODIFY `seat_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=62;

--
-- AUTO_INCREMENT for table `trains`
--
ALTER TABLE `trains`
  MODIFY `train_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=62;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`train_id`) REFERENCES `trains` (`train_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `seats`
--
ALTER TABLE `seats`
  ADD CONSTRAINT `seats_ibfk_1` FOREIGN KEY (`train_id`) REFERENCES `trains` (`train_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
