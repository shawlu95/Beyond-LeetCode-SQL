DROP SCHEMA IF EXISTS Recommendation;
CREATE SCHEMA Recommendation;
USE Recommendation;

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

INSERT INTO `Friendship` (`id`, `user_id`, `friend_id`) VALUES
(1, 'alice', 'bob'),
(2, 'alice', 'charles'),
(3, 'alice', 'david'),
(4, 'bob', 'david');

ALTER TABLE `Friendship`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `Friendship`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

-- --------------------------------------------------------

--
-- Table structure for table `PageFollow`
--

DROP TABLE IF EXISTS `PageFollow`;
CREATE TABLE `PageFollow` (
  `id` int(11) NOT NULL,
  `user_id` varchar(10) DEFAULT NULL,
  `page_id` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `PageFollow` (`id`, `user_id`, `page_id`) VALUES
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

ALTER TABLE `PageFollow`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `PageFollow`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

