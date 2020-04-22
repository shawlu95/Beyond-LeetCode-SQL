
DROP SCHEMA IF EXISTS Advertiser;
CREATE SCHEMA Advertiser;
USE Advertiser;

DROP TABLE IF EXISTS `Advertiser`;
CREATE TABLE `Advertiser` (
  `id` int(11) NOT NULL,
  `user_id` varchar(10) NOT NULL,
  `status` enum('CHURN','NEW','EXISTING','RESURRECT') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `Advertiser` (`id`, `user_id`, `status`) VALUES
(1, 'bing', 'NEW'),
(2, 'yahoo', 'NEW'),
(3, 'alibaba', 'EXISTING'),
(4, 'baidu', 'EXISTING'),
(5, 'target', 'CHURN'),
(6, 'tesla', 'CHURN'),
(7, 'morgan', 'RESURRECT'),
(8, 'chase', 'RESURRECT');

ALTER TABLE `Advertiser`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `Advertiser`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

-- Table structure for table `DailyPay`
DROP TABLE IF EXISTS `DailyPay`;
CREATE TABLE `DailyPay` (
  `id` int(11) NOT NULL,
  `user_id` varchar(10) NOT NULL,
  `paid` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `DailyPay` (`id`, `user_id`, `paid`) VALUES
(1, 'yahoo', 45),
(2, 'alibaba', 100),
(3, 'target', 13),
(4, 'morgan', 600),
(5, 'fitdata', 1);

ALTER TABLE `DailyPay`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `DailyPay`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
