-- phpMyAdmin SQL Dump
-- version 4.7.7
-- https://www.phpmyadmin.net/
--
-- Host: localhost:8889
-- Generation Time: Mar 18, 2019 at 01:41 AM
-- Server version: 5.6.38
-- PHP Version: 7.2.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

--
-- Database: `SpotifyFriend`
--
CREATE DATABASE IF NOT EXISTS `SpotifyFriend` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `SpotifyFriend`;

-- --------------------------------------------------------

--
-- Table structure for table `Song`
--

DROP TABLE IF EXISTS `Song`;
CREATE TABLE `Song` (
  `id` int(11) NOT NULL,
  `user_id` varchar(10) NOT NULL,
  `song` varchar(20) NOT NULL,
  `ts` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Song`
--

INSERT INTO `Song` (`id`, `user_id`, `song`, `ts`) VALUES
(1, 'Alex', 'Kiroro', '2019-03-17'),
(2, 'Alex', 'Shape of My Heart', '2019-03-17'),
(3, 'Alex', 'Clair de Lune', '2019-03-17'),
(4, 'Alex', 'The Fall', '2019-03-17'),
(5, 'Alex', 'Forever Young', '2019-03-17'),
(6, 'Bill', 'Shape of My Heart', '2019-03-17'),
(7, 'Bill', 'Clair de Lune', '2019-03-17'),
(8, 'Bill', 'The Fall', '2019-03-17'),
(9, 'Bill', 'Forever Young', '2019-03-17'),
(10, 'Bill', 'My Love', '2019-03-14'),
(11, 'Alex', 'Kiroro', '2019-03-17'),
(12, 'Alex', 'Shape of My Heart', '2019-03-17'),
(13, 'Alex', 'Shape of My Heart', '2019-03-17'),
(14, 'Bill', 'Shape of My Heart', '2019-03-17'),
(15, 'Bill', 'Shape of My Heart', '2019-03-17'),
(16, 'Bill', 'Shape of My Heart', '2019-03-17'),
(17, 'Cindy', 'Kiroro', '2019-03-17'),
(18, 'Cindy', 'Clair de Lune', '2019-03-17'),
(19, 'Cindy', 'My Love', '2019-03-14'),
(20, 'Cindy', 'Clair de Lune', '2019-03-14'),
(21, 'Cindy', 'Lemon Tree', '2019-03-14'),
(22, 'Cindy', 'Mad World', '2019-03-14'),
(23, 'Bill', 'Lemon Tree', '2019-03-14'),
(24, 'Bill', 'Mad World', '2019-03-14'),
(25, 'Bill', 'My Love', '2019-03-14');

-- --------------------------------------------------------

--
-- Table structure for table `User`
--

DROP TABLE IF EXISTS `User`;
CREATE TABLE `User` (
  `id` int(11) NOT NULL,
  `user_id` varchar(10) NOT NULL,
  `friend_id` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `User`
--

INSERT INTO `User` (`id`, `user_id`, `friend_id`) VALUES
(1, 'Cindy', 'Bill');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Song`
--
ALTER TABLE `Song`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `User`
--
ALTER TABLE `User`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `Song`
--
ALTER TABLE `Song`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `User`
--
ALTER TABLE `User`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
