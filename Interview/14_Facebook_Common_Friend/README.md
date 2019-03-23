# Common Friends
> Given a friendship table, find for each user his friends with whom they have at least 3 friends in common. Rank friends by the number of common friend. The table record one-way relationship: sender of friend request and recipient of friend request.

___
### Load Data
Load the database file [db.sql](db.sql) to localhost MySQL. A Facebook database will be created with one Friendship table. 
```
mysql < db.sql -uroot -p
```

```
select * from friendship limit 5;                                        
+----+---------+-----------+
| id | user_id | friend_id |
+----+---------+-----------+
|  1 | alice   | bob       |
|  2 | alice   | charles   |
|  3 | alice   | david     |
|  4 | alice   | mary      |
|  5 | bob     | david     |
+----+---------+-----------+
5 rows in set (0.00 sec)
```

___
### Observation
Here we are given directed edge. So the first step is to account for both direction (friendship is mutual). Next, for each user_id pair, join both parties with their common friends (excluding each other). Finally, group by the user_id pair and output pair with at least three matches.

### Step 1. Accounting for Undirected Edge
We use a UNION all clause. Because there is no duplicate, we do not use UNION.
```
SELECT user_id, friend_id FROM Friendship
WHERE user_id = 'alice'
UNION ALL
SELECT friend_id, user_id FROM Friendship
WHERE user_id = 'alice'
LIMIT 10;

+---------+-----------+
| user_id | friend_id |
+---------+-----------+
| alice   | bob       |
| alice   | charles   |
| alice   | david     |
| alice   | mary      |
| bob     | alice     |
| charles | alice     |
| david   | alice     |
| mary    | alice     |
+---------+-----------+
8 rows in set (0.00 sec)
```

### Step 2. Expand Two-way
Join the union result twice, to find friends for each user_id. Filter the results to include common friend only.
```
WITH tmp AS (
SELECT user_id, friend_id FROM Friendship
UNION ALL
SELECT friend_id, user_id FROM Friendship
)
SELECT
	ab.user_id AS a
	,ab.friend_id AS b
	,af.friend_id AS a_friend
	,bf.friend_id AS b_friend
FROM tmp AS ab
JOIN tmp AS af
	ON ab.user_id = af.user_id
JOIN tmp AS bf
	ON ab.friend_id = bf.user_id
	AND bf.friend_id = af.friend_id
ORDER BY a, b, a_friend, b_friend;

+---------+---------+----------+----------+
| a       | b       | a_friend | b_friend |
+---------+---------+----------+----------+
| alice   | bob     | charles  | charles  |
| alice   | bob     | david    | david    |
| alice   | bob     | mary     | mary     |
| alice   | charles | bob      | bob      |
| alice   | david   | bob      | bob      |
| alice   | mary    | bob      | bob      |
| bob     | alice   | charles  | charles  |
| bob     | alice   | david    | david    |
| bob     | alice   | mary     | mary     |
| bob     | charles | alice    | alice    |
| bob     | david   | alice    | alice    |
| bob     | mary    | alice    | alice    |
| charles | alice   | bob      | bob      |
| charles | bob     | alice    | alice    |
| david   | alice   | bob      | bob      |
| david   | bob     | alice    | alice    |
| mary    | alice   | bob      | bob      |
| mary    | bob     | alice    | alice    |
+---------+---------+----------+----------+
18 rows in set (0.00 sec)
```

### Step 3. Aggregation
Group by the user_id pair and count the number of common friends. Because we've counted both way, each eligible pair will have a counterpart with the opposite direction.

```
WITH tmp AS (
SELECT user_id, friend_id FROM Friendship
UNION ALL
SELECT friend_id, user_id FROM Friendship
)
SELECT
	ab.user_id
	,ab.friend_id
	,COUNT(*) AS common_friend
FROM tmp AS ab
JOIN tmp AS af
	ON ab.user_id = af.user_id
JOIN tmp AS bf
	ON ab.friend_id = bf.user_id
	AND bf.friend_id = af.friend_id
GROUP BY ab.user_id, ab.friend_id
HAVING common_friend >= 3
ORDER BY common_friend DESC;

+---------+-----------+---------------+
| user_id | friend_id | common_friend |
+---------+-----------+---------------+
| bob     | alice     |             3 |
| alice   | bob       |             3 |
+---------+-----------+---------------+
2 rows in set (0.00 sec)
```

See solution [here](solution.sql).