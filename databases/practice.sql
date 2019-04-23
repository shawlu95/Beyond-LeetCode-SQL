-- phpMyAdmin SQL Dump
-- version 4.7.7
-- https://www.phpmyadmin.net/
--
-- Host: localhost:8889
-- Generation Time: Apr 23, 2019 at 11:53 AM
-- Server version: 5.6.38
-- PHP Version: 7.2.1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `practice`
--
CREATE DATABASE IF NOT EXISTS `practice` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `practice`;

-- --------------------------------------------------------

--
-- Table structure for table `AdDaily`
--

DROP TABLE IF EXISTS `AdDaily`;
CREATE TABLE `AdDaily` (
  `id` int(11) NOT NULL,
  `user_id` varchar(10) NOT NULL,
  `paid` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `AdDaily`
--

INSERT INTO `AdDaily` (`id`, `user_id`, `paid`) VALUES
(1, 'yahoo', 45),
(2, 'baidu', 100),
(3, 'tesla', 60),
(4, 'chase', 20),
(5, 'fitdata', 1);

-- --------------------------------------------------------

--
-- Table structure for table `Advertiser`
--

DROP TABLE IF EXISTS `Advertiser`;
CREATE TABLE `Advertiser` (
  `id` int(11) NOT NULL,
  `user_id` varchar(10) NOT NULL,
  `status` enum('CHURN','NEW','EXISTING','RESURRECT') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Advertiser`
--

INSERT INTO `Advertiser` (`id`, `user_id`, `status`) VALUES
(1, 'bing', 'NEW'),
(2, 'yahoo', 'NEW'),
(3, 'alibaba', 'EXISTING'),
(4, 'baidu', 'EXISTING'),
(5, 'target', 'CHURN'),
(6, 'tesla', 'CHURN'),
(7, 'morgan', 'RESURRECT'),
(8, 'chase', 'RESURRECT');

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

-- --------------------------------------------------------

--
-- Table structure for table `Bugs`
--

DROP TABLE IF EXISTS `Bugs`;
CREATE TABLE `Bugs` (
  `id` int(11) NOT NULL,
  `bug_id` int(11) NOT NULL,
  `status` enum('OPEN','FIXED','','') NOT NULL DEFAULT 'OPEN'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Bugs`
--

INSERT INTO `Bugs` (`id`, `bug_id`, `status`) VALUES
(1, 1, 'OPEN'),
(2, 2, 'OPEN'),
(3, 3, 'OPEN'),
(4, 4, 'OPEN'),
(5, 5, 'OPEN'),
(6, 6, 'OPEN'),
(7, 7, 'OPEN'),
(8, 10, 'FIXED'),
(9, 11, 'FIXED'),
(10, 12, 'FIXED'),
(11, 13, 'FIXED'),
(12, 14, 'FIXED'),
(13, 15, 'FIXED'),
(14, 16, 'FIXED'),
(15, 17, 'FIXED'),
(16, 18, 'FIXED'),
(17, 19, 'FIXED'),
(18, 20, 'FIXED'),
(19, 21, 'FIXED');

-- --------------------------------------------------------

--
-- Table structure for table `BugsProduct`
--

DROP TABLE IF EXISTS `BugsProduct`;
CREATE TABLE `BugsProduct` (
  `id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `bug_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `BugsProduct`
--

INSERT INTO `BugsProduct` (`id`, `product_id`, `bug_id`) VALUES
(1, 1, 10),
(2, 1, 11),
(3, 1, 12),
(4, 1, 13),
(5, 1, 14),
(6, 1, 15),
(7, 1, 16),
(8, 1, 17),
(9, 1, 18),
(10, 1, 19),
(11, 1, 20),
(12, 1, 21),
(13, 1, 1),
(14, 1, 2),
(15, 1, 3),
(16, 1, 4),
(17, 1, 5),
(18, 1, 6),
(19, 1, 7);

-- --------------------------------------------------------

--
-- Table structure for table `courseGrade`
--

DROP TABLE IF EXISTS `courseGrade`;
CREATE TABLE `courseGrade` (
  `student` varchar(10) NOT NULL,
  `course` varchar(10) NOT NULL,
  `grade` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `courseGrade`
--

INSERT INTO `courseGrade` (`student`, `course`, `grade`) VALUES
('Alice ', 'Algebra', 50),
('Alice ', 'DB', 77),
('Alice ', 'java', 80),
('Bob', 'Algebra', 62),
('Bob', 'DB', 95),
('Bob', 'java', 62);

-- --------------------------------------------------------

--
-- Table structure for table `Customer`
--

DROP TABLE IF EXISTS `Customer`;
CREATE TABLE `Customer` (
  `id` int(11) NOT NULL,
  `user_id` int(8) NOT NULL,
  `name` char(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Customer`
--

INSERT INTO `Customer` (`id`, `user_id`, `name`) VALUES
(1, 1, 'Alice'),
(2, 2, 'Bob'),
(3, 3, 'Cindy');

-- --------------------------------------------------------

--
-- Table structure for table `exam`
--

DROP TABLE IF EXISTS `exam`;
CREATE TABLE `exam` (
  `name` varchar(10) NOT NULL,
  `java` int(11) NOT NULL,
  `DB` int(11) NOT NULL,
  `algebra` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `exam`
--

INSERT INTO `exam` (`name`, `java`, `DB`, `algebra`) VALUES
('Alice', 80, 77, 50),
('Bob', 62, 95, 62);

-- --------------------------------------------------------

--
-- Stand-in structure for view `fixed`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `fixed`;
CREATE TABLE `fixed` (
);

-- --------------------------------------------------------

--
-- Table structure for table `FriendPage`
--

DROP TABLE IF EXISTS `FriendPage`;
CREATE TABLE `FriendPage` (
  `id` int(11) NOT NULL,
  `user_id` varchar(10) DEFAULT NULL,
  `page_id` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `FriendPage`
--

INSERT INTO `FriendPage` (`id`, `user_id`, `page_id`) VALUES
(1, 'alice', 'google'),
(2, 'bob', 'google'),
(3, 'charles', 'google'),
(4, 'bob', 'linkedin'),
(5, 'charles', 'linkedin'),
(6, 'david', 'linkedin'),
(7, 'david', 'github'),
(8, 'charles', 'github'),
(9, 'alice', 'facebook'),
(10, 'bob', 'facebook');

-- --------------------------------------------------------

--
-- Table structure for table `Friendship`
--

DROP TABLE IF EXISTS `Friendship`;
CREATE TABLE `Friendship` (
  `id` int(11) NOT NULL,
  `user_id` varchar(10) DEFAULT NULL,
  `friend_id` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Friendship`
--

INSERT INTO `Friendship` (`id`, `user_id`, `friend_id`) VALUES
(1, 'alice', 'bob'),
(2, 'alice', 'charles'),
(3, 'alice', 'david'),
(4, 'bob', 'david'),
(5, 'bob', 'alice'),
(6, 'charles', 'alice'),
(7, 'david', 'alice'),
(8, 'david', 'bob');

-- --------------------------------------------------------

--
-- Table structure for table `Instagram`
--

DROP TABLE IF EXISTS `Instagram`;
CREATE TABLE `Instagram` (
  `user_id` varchar(10) NOT NULL,
  `follower_id` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Instagram`
--

INSERT INTO `Instagram` (`user_id`, `follower_id`) VALUES
('bezos', 'david'),
('bezos', 'james'),
('bezos', 'join'),
('bezos', 'mary'),
('musk', 'david'),
('musk', 'john'),
('ronaldo', 'david'),
('ronaldo', 'james'),
('ronaldo', 'linda'),
('ronaldo', 'mary'),
('trump', 'melinda');

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

-- --------------------------------------------------------

--
-- Table structure for table `Login`
--

DROP TABLE IF EXISTS `Login`;
CREATE TABLE `Login` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `ts` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Login`
--

INSERT INTO `Login` (`id`, `user_id`, `ts`) VALUES
(1, 1, '2019-02-14'),
(2, 1, '2019-02-13'),
(3, 1, '2019-02-12'),
(4, 1, '2019-02-11'),
(5, 2, '2019-02-14'),
(6, 2, '2019-02-12'),
(7, 2, '2019-02-11'),
(8, 2, '2019-02-10'),
(9, 3, '2019-02-14'),
(10, 3, '2019-02-12'),
(11, 4, '2019-02-09'),
(12, 4, '2019-02-08'),
(13, 4, '2019-02-08'),
(14, 4, '2019-02-07');

-- --------------------------------------------------------

--
-- Table structure for table `Number`
--

DROP TABLE IF EXISTS `Number`;
CREATE TABLE `Number` (
  `id` int(11) NOT NULL,
  `number` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Number`
--

INSERT INTO `Number` (`id`, `number`) VALUES
(1, -8),
(2, 30),
(3, 7),
(4, 90);

-- --------------------------------------------------------

--
-- Stand-in structure for view `open`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `open`;
CREATE TABLE `open` (
);

-- --------------------------------------------------------

--
-- Table structure for table `Printer`
--

DROP TABLE IF EXISTS `Printer`;
CREATE TABLE `Printer` (
  `company_name` varchar(9) DEFAULT NULL,
  `action` varchar(5) DEFAULT NULL,
  `pagecount` varchar(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Printer`
--

INSERT INTO `Printer` (`company_name`, `action`, `pagecount`) VALUES
('Company A', 'PRINT', '3'),
('Company A', 'PRINT', '2'),
('Company A', 'PRINT', '3'),
('Company B', 'EMAIL', NULL),
('Company B', 'PRINT', '2'),
('Company B', 'PRINT', '2'),
('Company B', 'PRINT', '1'),
('Company A', 'PRINT', '3');

-- --------------------------------------------------------

--
-- Table structure for table `ProductGroup`
--

DROP TABLE IF EXISTS `ProductGroup`;
CREATE TABLE `ProductGroup` (
  `group_id` bigint(20) UNSIGNED NOT NULL,
  `group_name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `Purchase`
--

DROP TABLE IF EXISTS `Purchase`;
CREATE TABLE `Purchase` (
  `id` int(11) NOT NULL,
  `user_id` int(8) NOT NULL,
  `ts` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Purchase`
--

INSERT INTO `Purchase` (`id`, `user_id`, `ts`) VALUES
(1, 1, '2019-02-14'),
(2, 1, '2019-02-13'),
(3, 2, '2019-01-01');

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

-- --------------------------------------------------------

--
-- Table structure for table `SongDaily`
--

DROP TABLE IF EXISTS `SongDaily`;
CREATE TABLE `SongDaily` (
  `id` int(11) NOT NULL,
  `user_id` varchar(15) DEFAULT NULL,
  `song_id` varchar(15) DEFAULT NULL,
  `time_stamp` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `SongDaily`
--

INSERT INTO `SongDaily` (`id`, `user_id`, `song_id`, `time_stamp`) VALUES
(1, 'shaw', 'rise', '2019-03-01 05:33:08'),
(2, 'shaw', 'rise', '2019-03-01 16:00:00'),
(3, 'shaw', 'goodie', '2019-03-01 10:15:00'),
(4, 'linda', 'lemon', '2019-02-28 00:00:00'),
(5, 'mark', 'game', '2019-03-01 04:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `SongHistory`
--

DROP TABLE IF EXISTS `SongHistory`;
CREATE TABLE `SongHistory` (
  `id` int(11) NOT NULL,
  `user_id` varchar(5) DEFAULT NULL,
  `song_id` varchar(10) DEFAULT NULL,
  `tally` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `SongHistory`
--

INSERT INTO `SongHistory` (`id`, `user_id`, `song_id`, `tally`) VALUES
(1, 'shaw', 'rise', 4),
(2, 'linda', 'lemon', 4),
(3, 'mark', 'game', 1),
(4, 'shaw', 'goodie', 1);

-- --------------------------------------------------------

--
-- Table structure for table `Talent`
--

DROP TABLE IF EXISTS `Talent`;
CREATE TABLE `Talent` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `skill` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Talent`
--

INSERT INTO `Talent` (`id`, `user_id`, `skill`) VALUES
(1, 1, 'swim'),
(2, 1, 'play'),
(3, 1, 'swim'),
(4, 2, 'play'),
(5, 3, 'swim'),
(6, 3, 'swim'),
(7, 2, 'play');

-- --------------------------------------------------------

--
-- Stand-in structure for view `tmp`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `tmp`;
CREATE TABLE `tmp` (
`user_id` varchar(10)
,`status` enum('CHURN','NEW','EXISTING','RESURRECT')
,`paid` int(11)
);

-- --------------------------------------------------------

--
-- Table structure for table `User`
--

DROP TABLE IF EXISTS `User`;
CREATE TABLE `User` (
  `user_id` varchar(10) NOT NULL,
  `name` varchar(10) NOT NULL,
  `phone_num` varchar(12) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `User`
--

INSERT INTO `User` (`user_id`, `name`, `phone_num`) VALUES
('jkog', 'Jing', '202-555-0176'),
('niceguy', 'Goodman', '202-555-0174'),
('sanhoo', 'Sanjay', '202-555-0100'),
('shaw123', 'Shaw', '202-555-0111');

-- --------------------------------------------------------

--
-- Table structure for table `UserHistory`
--

DROP TABLE IF EXISTS `UserHistory`;
CREATE TABLE `UserHistory` (
  `user_id` varchar(10) NOT NULL,
  `date` date NOT NULL,
  `action` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `UserHistory`
--

INSERT INTO `UserHistory` (`user_id`, `date`, `action`) VALUES
('niceguy', '2019-01-22', 'logged_on'),
('sanhoo', '2019-01-01', 'logged_on'),
('sanhoo', '2019-02-27', 'logged_on'),
('shaw123', '2019-02-20', 'logged_on'),
('shaw123', '2019-03-12', 'signed_up');

-- --------------------------------------------------------

--
-- Structure for view `fixed`
--
DROP TABLE IF EXISTS `fixed`;

CREATE ALGORITHM=UNDEFINED DEFINER=`privateuser`@`localhost` SQL SECURITY DEFINER VIEW `fixed`  AS  select `p`.`product_id` AS `product_id`,`f`.`bug_id` AS `bug_id` from (`bugsproducts` `p` join `bugs` `f` on(((`p`.`bug_id` = `f`.`bug_id`) and (`f`.`status` = 'FIXED')))) ;

-- --------------------------------------------------------

--
-- Structure for view `open`
--
DROP TABLE IF EXISTS `open`;

CREATE ALGORITHM=UNDEFINED DEFINER=`privateuser`@`localhost` SQL SECURITY DEFINER VIEW `open`  AS  select `p`.`product_id` AS `product_id`,`o`.`bug_id` AS `bug_id` from (`bugsproducts` `p` join `bugs` `o` on(((`p`.`bug_id` = `o`.`bug_id`) and (`o`.`status` = 'OPEN')))) ;

-- --------------------------------------------------------

--
-- Structure for view `tmp`
--
DROP TABLE IF EXISTS `tmp`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `tmp`  AS  select `a`.`user_id` AS `user_id`,`a`.`status` AS `status`,`d`.`paid` AS `paid` from (`addaily` `d` left join `advertiser` `a` on((`a`.`user_id` = `d`.`user_id`))) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `AdDaily`
--
ALTER TABLE `AdDaily`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `Advertiser`
--
ALTER TABLE `Advertiser`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `Balance`
--
ALTER TABLE `Balance`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `Bugs`
--
ALTER TABLE `Bugs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id` (`id`);

--
-- Indexes for table `BugsProduct`
--
ALTER TABLE `BugsProduct`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `courseGrade`
--
ALTER TABLE `courseGrade`
  ADD PRIMARY KEY (`student`,`course`);

--
-- Indexes for table `Customer`
--
ALTER TABLE `Customer`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `exam`
--
ALTER TABLE `exam`
  ADD PRIMARY KEY (`name`);

--
-- Indexes for table `FriendPage`
--
ALTER TABLE `FriendPage`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `Friendship`
--
ALTER TABLE `Friendship`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `Instagram`
--
ALTER TABLE `Instagram`
  ADD PRIMARY KEY (`user_id`,`follower_id`);

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
-- Indexes for table `Login`
--
ALTER TABLE `Login`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `Number`
--
ALTER TABLE `Number`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ProductGroup`
--
ALTER TABLE `ProductGroup`
  ADD PRIMARY KEY (`group_id`),
  ADD UNIQUE KEY `group_id` (`group_id`);

--
-- Indexes for table `Purchase`
--
ALTER TABLE `Purchase`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `Quiz`
--
ALTER TABLE `Quiz`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `SongDaily`
--
ALTER TABLE `SongDaily`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `SongHistory`
--
ALTER TABLE `SongHistory`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `Talent`
--
ALTER TABLE `Talent`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `User`
--
ALTER TABLE `User`
  ADD PRIMARY KEY (`user_id`);

--
-- Indexes for table `UserHistory`
--
ALTER TABLE `UserHistory`
  ADD PRIMARY KEY (`user_id`,`date`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `AdDaily`
--
ALTER TABLE `AdDaily`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `Advertiser`
--
ALTER TABLE `Advertiser`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `Balance`
--
ALTER TABLE `Balance`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `Bugs`
--
ALTER TABLE `Bugs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `BugsProduct`
--
ALTER TABLE `BugsProduct`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `Customer`
--
ALTER TABLE `Customer`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `FriendPage`
--
ALTER TABLE `FriendPage`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `Friendship`
--
ALTER TABLE `Friendship`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

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

--
-- AUTO_INCREMENT for table `Login`
--
ALTER TABLE `Login`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `Number`
--
ALTER TABLE `Number`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `ProductGroup`
--
ALTER TABLE `ProductGroup`
  MODIFY `group_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `Purchase`
--
ALTER TABLE `Purchase`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `Quiz`
--
ALTER TABLE `Quiz`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `SongDaily`
--
ALTER TABLE `SongDaily`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `SongHistory`
--
ALTER TABLE `SongHistory`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `Talent`
--
ALTER TABLE `Talent`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
