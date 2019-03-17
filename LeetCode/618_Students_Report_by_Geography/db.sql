DROP SCHEMA IF EXISTS LeetCode;
CREATE SCHEMA LeetCode;
USE LeetCode;

Create table If Not Exists student (name varchar(50), continent varchar(7));
Truncate table student;
insert into student (name, continent) values ('Jane', 'America');
insert into student (name, continent) values ('Pascal', 'Europe');
insert into student (name, continent) values ('Xi', 'Asia');
insert into student (name, continent) values ('Jack', 'America');