-- phpMyAdmin SQL Dump
-- version 4.7.7
-- https://www.phpmyadmin.net/
--
-- Host: localhost:8889
-- Generation Time: Mar 18, 2019 at 09:23 AM
-- Server version: 5.6.38
-- PHP Version: 7.2.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

--
-- Database: `Search`
--
CREATE DATABASE IF NOT EXISTS `Search` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `Search`;

-- --------------------------------------------------------

--
-- Table structure for table `SearchCategory`
--

DROP TABLE IF EXISTS `SearchCategory`;
CREATE TABLE `SearchCategory` (
  `country` varchar(10) NOT NULL,
  `search_cat` varchar(10) NOT NULL,
  `num_search` int(10) DEFAULT NULL,
  `zero_result_pct` decimal(10,0) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `SearchCategory`
--

INSERT INTO `SearchCategory` (`country`, `search_cat`, `num_search`, `zero_result_pct`) VALUES
('CN', 'dog', 9700000, NULL),
('CN', 'home', 1200000, '13'),
('CN', 'tax', 1200, '99'),
('CN', 'travel', 980000, '11'),
('UAE', 'home', NULL, NULL),
('UAE', 'travel', NULL, NULL),
('UK', 'home', NULL, NULL),
('UK', 'tax', 98000, '1'),
('UK', 'travel', 100000, '3'),
('US', 'home', 190000, '1'),
('US', 'tax', 12000, NULL),
('US', 'travel', 9500, '3');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `SearchCategory`
--
ALTER TABLE `SearchCategory`
  ADD PRIMARY KEY (`country`,`search_cat`),
  ADD KEY `id` (`country`,`search_cat`);
