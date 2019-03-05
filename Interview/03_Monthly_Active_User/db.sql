DROP SCHEMA IF EXISTS MAU;
CREATE SCHEMA MAU;
USE MAU;


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

INSERT INTO `User` (`user_id`, `name`, `phone_num`) VALUES
('jkog', 'Jing', '202-555-0176'),
('niceguy', 'Goodman', '202-555-0174'),
('sanhoo', 'Sanjay', '202-555-0100'),
('shaw123', 'Shaw', '202-555-0111');

ALTER TABLE `User`
  ADD PRIMARY KEY (`user_id`);


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

INSERT INTO `UserHistory` (`user_id`, `date`, `action`) VALUES
('sanhoo', '2019-01-01', 'logged_on'),
('niceguy', '2019-01-22', 'logged_on'),
('shaw123', '2019-02-20', 'logged_on'),
('sanhoo', '2019-02-27', 'logged_on'),
('shaw123', '2019-03-12', 'signed_up');

ALTER TABLE `UserHistory`
  ADD PRIMARY KEY (`user_id`, `date`);