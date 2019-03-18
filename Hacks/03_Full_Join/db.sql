CREATE SCHEMA IF NOT EXISTS Practice;
USE Practice;

-- phpMyAdmin SQL Dump
-- version 4.7.7
-- https://www.phpmyadmin.net/
--
-- Host: localhost:8889
-- Generation Time: Mar 18, 2019 at 03:26 AM
-- Server version: 5.6.38
-- PHP Version: 7.2.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

--
-- Database: `practice`
--
CREATE DATABASE IF NOT EXISTS `practice` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `practice`;

-- --------------------------------------------------------

--
-- Table structure for table `Letter1`
--

DROP TABLE IF EXISTS `Letter1`;
CREATE TABLE `Letter1` (
  `id` int(11) NOT NULL,
  `letter` varchar(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Letter1`
--

INSERT INTO `Letter1` (`id`, `letter`) VALUES
(1, 'N'),
(2, 'B'),
(3, 'N');

-- --------------------------------------------------------

--
-- Table structure for table `Letter2`
--

DROP TABLE IF EXISTS `Letter2`;
CREATE TABLE `Letter2` (
  `id` int(11) NOT NULL,
  `letter` varchar(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Letter2`
--

INSERT INTO `Letter2` (`id`, `letter`) VALUES
(1, 'A'),
(2, 'C'),
(3, 'A');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Letter1`
--
ALTER TABLE `Letter1`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `Letter2`
--
ALTER TABLE `Letter2`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `Letter1`
--
ALTER TABLE `Letter1`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `Letter2`
--
ALTER TABLE `Letter2`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
