CREATE SCHEMA IF NOT EXISTS Practice;
USE Practice;


-- phpMyAdmin SQL Dump
-- version 4.7.7
-- https://www.phpmyadmin.net/
--
-- Host: localhost:8889
-- Generation Time: Mar 17, 2019 at 11:27 AM
-- Server version: 5.6.38
-- PHP Version: 7.2.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

--
-- Database: `practice`
--

-- --------------------------------------------------------

--
-- Table structure for table `Balance`
--

DROP TABLE IF EXISTS `Balance`;
CREATE TABLE `Balance` (
  `id` int(11) NOT NULL,
  `name` varchar(10) DEFAULT NULL,
  `balance` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Balance`
--

INSERT INTO `Balance` (`id`, `name`, `balance`) VALUES
(1, 'Alice', 10),
(2, 'Bob', 5),
(3, NULL, 20),
(4, 'Cindy', NULL),
(5, 'Bob', 10),
(6, 'Cindy', 100);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Balance`
--
ALTER TABLE `Balance`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `Balance`
--
ALTER TABLE `Balance`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;
