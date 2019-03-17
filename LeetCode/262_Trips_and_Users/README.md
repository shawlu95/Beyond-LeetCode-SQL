# Trips and Users

## Description
The Trips table holds all taxi trips. Each trip has a unique Id, while Client_Id and Driver_Id are both foreign keys to the Users_Id at the Users table. Status is an ENUM type of (‘completed’, ‘cancelled_by_driver’, ‘cancelled_by_client’).

```
+----+-----------+-----------+---------+--------------------+----------+
| Id | Client_Id | Driver_Id | City_Id |        Status      |Request_at|
+----+-----------+-----------+---------+--------------------+----------+
| 1  |     1     |    10     |    1    |     completed      |2013-10-01|
| 2  |     2     |    11     |    1    | cancelled_by_driver|2013-10-01|
| 3  |     3     |    12     |    6    |     completed      |2013-10-01|
| 4  |     4     |    13     |    6    | cancelled_by_client|2013-10-01|
| 5  |     1     |    10     |    1    |     completed      |2013-10-02|
| 6  |     2     |    11     |    6    |     completed      |2013-10-02|
| 7  |     3     |    12     |    6    |     completed      |2013-10-02|
| 8  |     2     |    12     |    12   |     completed      |2013-10-03|
| 9  |     3     |    10     |    12   |     completed      |2013-10-03| 
| 10 |     4     |    13     |    12   | cancelled_by_driver|2013-10-03|
+----+-----------+-----------+---------+--------------------+----------+
```

The Users table holds all users. Each user has an unique Users_Id, and Role is an ENUM type of (‘client’, ‘driver’, ‘partner’).

```
+----------+--------+--------+
| Users_Id | Banned |  Role  |
+----------+--------+--------+
|    1     |   No   | client |
|    2     |   Yes  | client |
|    3     |   No   | client |
|    4     |   No   | client |
|    10    |   No   | driver |
|    11    |   No   | driver |
|    12    |   No   | driver |
|    13    |   No   | driver |
+----------+--------+--------+
```
Write a SQL query to find the cancellation rate of requests made by unbanned users between Oct 1, 2013 and Oct 3, 2013. For the above tables, your SQL query should return the following rows with the cancellation rate being rounded to two decimal places.
```
+------------+-------------------+
|     Day    | Cancellation Rate |
+------------+-------------------+
| 2013-10-01 |       0.33        |
| 2013-10-02 |       0.00        |
| 2013-10-03 |       0.50        |
+------------+-------------------+
```

Load the database file [db.sql](db.sql) to localhost MySQL. Relevant tables will be created in the LeetCode database. 
```
mysql < db.sql -uroot -p
```

---
## Observation
Make the following observation to interviewers. Confirm your observation is correct. Ask for clarification if necessary.
* Each trip has two foreign key (*Client_Id*, *Driver_Id*) referring the *Users* table's primary key.
* No trip can have __NULL__ in *Driver_id* or *Client_Id*.
* Because of the above assumptions, the three-way driver-trip-rider join results in same number of rows as the *Trips* table, before applying WHERE clause predicate.

---
## On Correctness
* Need to exclude both banned drivers and riders from calculation.
* Output rate to 2 decimal place as required.
* Give descriptive names to output columns as required.
* Constrain date range as required.

Basic [solution](mysql_simple.sql) that gives correct output:
```
-- MySQL: simple version
SELECT
  t.Request_at AS Day
  ,ROUND(SUM(t.Status != "completed") / COUNT(*), 2) AS 'Cancellation Rate'
FROM Trips t
JOIN Users d ON t.Driver_Id = d.Users_Id
JOIN Users c ON t.Client_Id = c.Users_Id
WHERE d.Banned = "No"
  AND c.Banned = "No"
  AND t.Request_at BETWEEN "2013-10-01" AND "2013-10-03"
GROUP BY t.Request_at
ORDER BY t.Request_at;
```

---
## On Efficiency
SQL performs JOIN operation before applying WHERE clause. If many users are banned, JOIN operation results in lots of invalid trips in which either rider or driver is banned. We may [pre-filter](mysql_pre_filter.sql) the *Users* table and store the results in a temporary table (note that temporary table does not work in LeetCode).

Similarly, joining the full *Trips* table can be wasteful. It may contain years of data, and we're interested in only 3 day's data. We can pre-filter the *Trips* table before joining it.

Finally, we inner join the pre-filtered *valid_trips* table to *valid_user* table twice. INNER JOIN filters out trips that have no match in *valid_users*, meaning that the driver or rider is banned. 

```
-- MySQL: pre-filtering before join
-- WARNING: LeetCode MySQL does not allow temporary table
WITH valid_user AS (
  SELECT Users_Id
  FROM Users
  WHERE Banned = "No"
)
,valid_trips AS (
  SELECT *
  FROM Trips
  WHERE Request_at BETWEEN "2013-10-01" AND "2013-10-03"
)
SELECT
  t.Request_at AS Day
  ,ROUND(SUM(t.Status != "completed") / COUNT(*), 2) AS 'Cancellation Rate'
FROM valid_trips t
JOIN valid_user d ON t.Driver_Id = d.Users_Id
JOIN valid_user c ON t.Client_Id = c.Users_Id
GROUP BY t.Request_at;
```

Instead of building two temporary tables, we can pre-filter by moving the predicate condition inside JOIN. The logic is the same as the code above: tables are filtered before joining. We want to reduce the table size before join. In the SQL code below, trips and drivers are filtered before being joined, and the clients are filtered before joining with the output of the first join.

```
-- MySQL cleaner code
SELECT
  t.Request_at AS Day
  ,ROUND(SUM(t.Status != "completed") / COUNT(*), 2) AS 'Cancellation Rate'
FROM Trips t
JOIN Users d 
  ON t.Driver_Id = d.Users_Id 
  AND d.Banned = 'No'
  AND t.Request_at BETWEEN "2013-10-01" AND "2013-10-03"
JOIN Users c 
  ON t.Client_Id = c.Users_Id 
  And c.Banned = 'No'
GROUP BY t.Request_at;
```

Alternatively, use a [set](mysql_set.sql) to retain all valid *User_Id*, and directly filter the *Trip* table without joining. The disadvantage is that because most database engine converts IN clause to series of OR operator, the query needs to be re-evaluated every time a new user gets banned, because the number of OR operator is constantly changing.

When using multi-column predicate, applying more restrictive condition first. For example, filter *Request_at* before filtering *Users_Id*. Because table size gets cut drastically upfront, computation required for later predicate decreases.

Using IN (... Banned = "No") clause is more efficient than using NOT IN (...Banned = "Yes"). To check an element is not in a set, a full scan of the set is required.

```
-- MySQL: set version
SELECT
  Request_at AS Day
  ,ROUND(SUM(Status != "completed") / COUNT(*), 2) AS 'Cancellation Rate'
FROM Trips
WHERE Request_at BETWEEN "2013-10-01" AND "2013-10-03"
  AND Driver_Id IN (SELECT Users_Id FROM Users WHERE Banned = 'No')
  AND Client_Id IN (SELECT Users_Id FROM Users WHERE Banned = 'No')
GROUP BY Request_at;
```

---
## Parting Thought
Because temporary table has no index. The second solution works better only when the pre-filtering results in significant reduction of table size. Otherwise, joining temporary tables without index can be slower than joining the full tables. In practice, look up the query plan and estimated cost before running the query.
