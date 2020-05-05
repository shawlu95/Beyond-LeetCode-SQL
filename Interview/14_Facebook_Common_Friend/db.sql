DROP SCHEMA IF EXISTS Facebook;
CREATE SCHEMA Facebook;
USE Facebook;

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
(4, 'alice', 'mary'),
(5, 'bob', 'david'),
(6, 'bob', 'charles'),
(7, 'bob', 'mary'),
(8, 'david', 'sonny'),
(9, 'charles', 'sonny'),
(10, 'bob', 'sonny');

ALTER TABLE `Friendship`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `Friendship`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;