
-- phpMyAdmin SQL Dump
-- version 4.7.7
-- https://www.phpmyadmin.net/
--
-- Host: localhost:8889
-- Generation Time: Mar 21, 2019 at 05:22 AM
-- Server version: 5.6.38
-- PHP Version: 7.2.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

--
-- Database: `practice`
--
CREATE SCHEMA IF NOT EXISTS Practice;
USE Practice;

-- --------------------------------------------------------

--
-- Table structure for table `Quiz`
--

DROP TABLE IF EXISTS `Quiz`;
CREATE TABLE `Quiz` (
  `id` int(11) NOT NULL,
  `user_id` varchar(10) NOT NULL,
  `course` varchar(10) NOT NULL,
  `quiz_date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Quiz`
--

INSERT INTO `Quiz` (`id`, `user_id`, `course`, `quiz_date`) VALUES
(1, 'shaw', 'CS229', '2019-02-08'),
(2, 'shaw', 'CS229', '2019-03-01'),
(3, 'shaw', 'CS230', '2019-03-04'),
(4, 'shaw', 'CS230', '2019-03-14'),
(5, 'shaw', 'CS231', '2019-02-14'),
(6, 'john', 'CS230', '2019-02-01'),
(7, 'john', 'CS230', '2019-02-12'),
(8, 'john', 'CS246', '2019-03-09'),
(9, 'john', 'CS246', '2019-03-29'),
(10, 'john', 'CS246', '2019-03-06');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Quiz`
--
ALTER TABLE `Quiz`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `Quiz`
--
ALTER TABLE `Quiz`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;
