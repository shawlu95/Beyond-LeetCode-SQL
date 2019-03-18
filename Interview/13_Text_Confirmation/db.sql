-- phpMyAdmin SQL Dump
-- version 4.7.7
-- https://www.phpmyadmin.net/
--
-- Host: localhost:8889
-- Generation Time: Mar 18, 2019 at 10:53 AM
-- Server version: 5.6.38
-- PHP Version: 7.2.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

--
-- Database: `Email`
--
CREATE DATABASE IF NOT EXISTS `Email` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `Email`;

-- --------------------------------------------------------

--
-- Table structure for table `Email`
--

DROP TABLE IF EXISTS `Email`;
CREATE TABLE `Email` (
  `ts` datetime NOT NULL,
  `user_id` varchar(10) NOT NULL,
  `email` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Email`
--

INSERT INTO `Email` (`ts`, `user_id`, `email`) VALUES
('2019-03-13 00:00:00', 'neo', 'anderson@matrix.com'),
('2019-03-17 12:15:00', 'Ross', 'ross@126.com'),
('2019-03-18 05:37:00', 'ali', 'ali@hotmail.com'),
('2019-03-18 06:00:00', 'shaw', 'shawlu95@gmail.com');

-- --------------------------------------------------------

--
-- Table structure for table `Text`
--

DROP TABLE IF EXISTS `Text`;
CREATE TABLE `Text` (
  `id` int(11) NOT NULL,
  `ts` datetime NOT NULL,
  `user_id` varchar(10) NOT NULL,
  `action` enum('CONFIRMED') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Text`
--

INSERT INTO `Text` (`id`, `ts`, `user_id`, `action`) VALUES
(1, '2019-03-17 12:15:00', 'Ross', 'CONFIRMED'),
(2, '2019-03-18 05:37:00', 'Ali', NULL),
(3, '2019-03-18 14:00:00', 'Ali', 'CONFIRMED'),
(4, '2019-03-18 06:00:00', 'shaw', NULL),
(5, '2019-03-19 00:00:00', 'shaw', 'CONFIRMED');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Email`
--
ALTER TABLE `Email`
  ADD PRIMARY KEY (`ts`);

--
-- Indexes for table `Text`
--
ALTER TABLE `Text`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `Text`
--
ALTER TABLE `Text`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
