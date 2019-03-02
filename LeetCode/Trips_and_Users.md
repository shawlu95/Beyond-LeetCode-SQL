# Trips and Users

## Observation
Make the following observation to interviewers. Confirm your observation is correct. Ask for clarification if necessary.
* Each trip has two foreign key (*Client_Id*, *Driver_Id*) referring the *Users* table's primary key.
* No trip can have __NULL__ in *Driver_id* or *Client_Id*.
* Because of the above assumptions, the three-way driver-trip-rider join results in same number of rows as the *Trips* table, before applying WHERE clause predicate.

## On Correctness
* Need to exclude both banned drivers and riders from calculation.
* Output rate to 2 decimal place as requried.
* Give descriptive names to output columns as required.
* Constrain date range as required.

Basic solution that gives correct ouput:
```
-- MySQL
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

## On Efficiency
SQL performs JOIN operation before applying WHERE clause. If many users are banned, JOIN operation results in lots of invalid trips in which either rider or driver is banned. We may pre-filter the *Users* table and store the results in a temporary table (note that temporary table does not work in LeetCode).

Similarly, joining the full *Trips* table can be wasteful. It may contain years of data, and we're interested in only 3 day's data. We can pre-filter the *Trips* table before joining it.

Finally, we inner join the pre-filtered *valid_trips* table to *valid_user* table twice. INNER JOIN filters out trips that have no match in *valid_users*, meaning that the driver or rider is banned.

```
-- WARNING: LeetCode does not allow temporary table
WITH valid_user AS (
  SELECT User_Id
  FROM Users
  WHERE Banned = "No"
)
, valid_trips AS (
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

Alternatively, use a set to retain all valid *User_Id*, and directly filter the *Trip* table without joining. The disadvantage is that because most database engine converts IN clause to series of OR operator, the query needs to be re-evaluated every time a new user gets banned, because the number of OR operator is constantly changing.

When using multi-column predicate, applying more restrictive condition first. For example, filter *Request_at* before filtering *Users_Id*. Because table size gets cut drastically upfront, computation required for later predicate decreases.

Using IN (... Banned = "No") clause is more efficient than using NOT IN (...Banned = "Yes"). To check an element is not in a set, a full scan of the set is required.

```
-- MySQL
SELECT
  Request_at AS Day
  ,ROUND(SUM(Status != "completed") / COUNT(*), 2) AS 'Cancellation Rate'
FROM Trips
WHERE Request_at BETWEEN "2013-10-01" AND "2013-10-03"
  AND Driver_Id IN (SELECT Users_Id FROM Users WHERE Banned = 'No')
  AND Client_Id IN (SELECT Users_Id FROM Users WHERE Banned = 'No')
GROUP BY Request_at;
```

## Final Thought
Because temporary table has no index. The second solution works better only when the pre-filtering results in significant reduction of table size. Otherwise, joining temporary tables without index can be slower than joining the full tables. In practice, look up the query plan and estimated cost before running the query.
