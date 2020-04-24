CREATE SCHEMA IF NOT EXISTS Practice;
USE Practice;

-- ---------------------------------------

--
-- Table structure for table `CourseGrade`
--

DROP TABLE IF EXISTS `CourseGrade`;
CREATE TABLE `CourseGrade` (
  `name` varchar(10) NOT NULL,
  `course` varchar(10) NOT NULL,
  `grade` varchar(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `CourseGrade`
--

INSERT INTO `CourseGrade` (`name`, `course`, `grade`) VALUES
('Alice', 'CS106B', 'A'),
('Alice', 'CS229', 'A'),
('Alice', 'CS224N', 'B'),
('Bob', 'CS106B', 'C'),
('Bob', 'CS229', 'F'),
('Bob', 'CS224N', 'F'),
('Charlie', 'CS106B', 'B'),
('Charlie', 'CS229', 'B'),
('Charlie', 'CS224N', 'A'),
('David', 'CS106B', 'C'),
('David', 'CS229', 'C'),
('David', 'CS224N', 'D'),
('Elsa', 'CS106B', 'B'),
('Elsa', 'CS229', 'B'),
('Elsa', 'CS224N', 'A');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `CourseGrade`
--
ALTER TABLE `CourseGrade`
  ADD KEY `name` (`name`);
