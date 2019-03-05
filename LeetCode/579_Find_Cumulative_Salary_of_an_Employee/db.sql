DROP SCHEMA IF EXISTS LeetCode;
CREATE SCHEMA LeetCode;
USE LeetCode;

Create table If Not Exists Employee (Id int, Month int, Salary int);

insert into Employee (Id, Month, Salary) values ('1', '1', '20');
insert into Employee (Id, Month, Salary) values ('2', '1', '20');
insert into Employee (Id, Month, Salary) values ('1', '2', '30');
insert into Employee (Id, Month, Salary) values ('2', '2', '30');
insert into Employee (Id, Month, Salary) values ('3', '2', '40');
insert into Employee (Id, Month, Salary) values ('1', '3', '40');
insert into Employee (Id, Month, Salary) values ('3', '3', '60');
insert into Employee (Id, Month, Salary) values ('1', '4', '60');
insert into Employee (Id, Month, Salary) values ('3', '4', '70');