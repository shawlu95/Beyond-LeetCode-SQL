# Monthly Active User

This post is inspired by this [page](https://www.programmerinterview.com/index.php/database-sql/practice-interview-question-2/). However, the solution from there is not completely correct, as they selected non-aggregated columns (Question 1). Also, *DISTINCT* keyword is not necessary in Question 2.

### Key Concepts
* Aggregate function
* Left join
* Removing duplicate
* Functional dependency

### Sample data
Load the database file [db.sql](db.sql) to localhost MySQL. A MAU database will be created with two tables. 
```
mysql < db.sql -uroot -p
```
```
mysql> SELECT * FROM User;
+---------+---------+--------------+
| user_id | name    | phone_num    |
+---------+---------+--------------+
| jkog    | Jing    | 202-555-0176 |
| niceguy | Goodman | 202-555-0174 |
| sanhoo  | Sanjay  | 202-555-0100 |
| shaw123 | Shaw    | 202-555-0111 |
+---------+---------+--------------+
4 rows in set (0.00 sec)
```

Every time a user logs in a new row is inserted into the UserHistory table with user_id, current date and action (where action = "logged_on").
```
mysql> SELECT * FROM UserHistory;
+---------+------------+-----------+
| user_id | date       | action    |
+---------+------------+-----------+
| shaw123 | 2019-02-20 | logged_on |
| shaw123 | 2019-03-12 | signed_up |
| sanhoo  | 2019-02-27 | logged_on |
| sanhoo  | 2019-01-01 | logged_on |
| niceguy | 2019-01-22 | logged_on |
+---------+------------+-----------+
5 rows in set (0.00 sec)
```

---
### Q1: Find monthly active users.
*Write a SQL query that returns the name, phone number and most recent date for any user that has logged in over the last 30 days (you can tell a user has logged in if the action field in UserHistory is set to "logged_on").*

```
SET @today := "2019-03-01";
SELECT 
  User.name
  ,User.phone_num
  ,MAX(UserHistory.date) 
FROM User, UserHistory 
WHERE User.user_id = UserHistory.user_id 
  AND UserHistory.action = 'logged_on' 
  AND UserHistory.date >= DATE_SUB(@today, INTERVAL 30 DAY) 
GROUP BY User.user_id;

+--------+--------------+-----------------------+
| name   | phone_num    | max(UserHistory.date) |
+--------+--------------+-----------------------+
| Sanjay | 202-555-0100 | 2019-02-27            |
| Shaw   | 202-555-0111 | 2019-02-20            |
+--------+--------------+-----------------------+
2 rows in set (0.00 sec)

```

The above solution is only correct when phone_num and name are functionally dependent on user_id. That is, for every user_id, there is a unique phone_num and name, so we can get away with selecting non-aggregated columns (which are also not in group by clause). 

Depending on database engine configuration, an error may be thrown when a selected column is neither aggregated nor in the group by clause. If we are certain that one-on-one mapping exists, we can add a aggregate function to the additional columns (*MAX()* or *MIN()*).

```
SET @today := "2019-03-01";
SELECT
  MAX(u.name) -- functionally dependent on user_id
  ,MAX(u.phone_num) -- functionally dependent on user_id
  ,MAX(h.date) AS recent_date
FROM User AS u, UserHistory AS h
WHERE u.user_id = h.user_id
  AND h.action = "logged_on"
  AND DATEDIFF(@today, h.date) <= 30 -- DATEDIFF(later, earlier)
GROUP BY u.user_id
ORDER BY recent_date;

+-------------+------------------+-------------+
| MAX(u.name) | MAX(u.phone_num) | recent_date |
+-------------+------------------+-------------+
| Shaw        | 202-555-0111     | 2019-02-20  |
| Sanjay      | 202-555-0100     | 2019-02-27  |
+-------------+------------------+-------------+
2 rows in set (0.01 sec)
```

Inner join also serves the purpose, and avoid making a cartesian product between two tables as in the cross join above (although query optimizer can take care of such trivial optimization, it's useful to know).

__Why__ inner join: *user_id* in  *UserHistory* table is a foreign key referring to *User* table primary key. Meaning that it is a subset of the primary key column. There may exists users who never logged on, and never appeared in the *UserHistory* table. Since we are interested in monthly active users. It's safe to ignore those inactive users.

```
-- using inner join
SET @today := "2019-03-01";
SELECT
  MAX(u.name) -- functionally dependent on user_id
  ,MAX(u.phone_num) -- functionally dependent on user_id
  ,MAX(h.date) AS recent_date
FROM User AS u
JOIN UserHistory AS h
  ON u.user_id = h.user_id
WHERE h.action = "logged_on"
  AND DATEDIFF(@today, h.date) <= 30
GROUP BY u.user_id
ORDER BY recent_date;
```

If any selected column is __not__ functionally dependent on the group by column, then unpredictable result may be returned, or error may be thrown. To avoid such trouble, only select aggregated columns and group by columns into a temporary tables, and join the temporary table with the original table to retrieve other desired columns.

---
### Q2. Find inactive users 
*Write a SQL query to determine which user_ids in the User table are not contained in the UserHistory table (assume the UserHistory table has a subset of the user_ids in User table). Do not use the SQL MINUS statement. Note: the UserHistory table can have multiple entries for each user_id (Note that your SQL should be compatible with MySQL 5.0, and avoid using subqueries)*

See [here](https://www.programmerinterview.com/index.php/database-sql/practice-interview-question-2-continued/) for a detailed walk-through. However, the solution is not totally correct. We __don't__ need the *DISTINCT* keyword here. Because if a *user_id* has no match in the *UserHistory* table, that row it returned __only once__.

```
SELECT *
FROM User AS u
LEFT JOIN UserHistory AS h
  ON u.user_id = h.user_id
WHERE h.user_id IS NULL;

+---------+------+--------------+---------+------+--------+
| user_id | name | phone_num    | user_id | date | action |
+---------+------+--------------+---------+------+--------+
| jkog    | Jing | 202-555-0176 | NULL    | NULL | NULL   |
+---------+------+--------------+---------+------+--------+
1 row in set (0.00 sec)
```

A less efficient approach is to retain valid users in a hashset. Remember that __NOT IN__ requires full traversal of every element in the hashset for a single check (*DISTINCT* keyword turns the set into hash set, but makes no difference on the result).

```
SELECT *
FROM User
WHERE user_id NOT IN (
  SELECT DISTINCT user_id FROM UserHistory
);

+---------+------+--------------+
| user_id | name | phone_num    |
+---------+------+--------------+
| jkog    | Jing | 202-555-0176 |
+---------+------+--------------+
1 row in set (0.00 sec)
```

See solution [here](solution.sql).