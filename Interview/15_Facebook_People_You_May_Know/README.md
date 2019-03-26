# People You May Know
> Based on the number of common friends, recommend users to be friend.

___
### Observation
This is a slight twist on the previous problem. Instead of selecting from existing friendships, we are proposing new ones. We'll use the same table as before.

___
### Step 1. Find Candidate Pairs
This can be done with a cross join. Obviously we want to avoid matching a user with himself.

```sql
SELECT * FROM
(SELECT DISTINCT user_id FROM Friendship) AS a
CROSS JOIN
(SELECT DISTINCT user_id FROM Friendship) AS b
ON a.user_id != b.user_id;
```
```
+---------+---------+
| user_id | user_id |
+---------+---------+
| bob     | alice   |
| david   | alice   |
| charles | alice   |
| alice   | bob     |
| david   | bob     |
| charles | bob     |
| alice   | david   |
| bob     | david   |
| charles | david   |
| alice   | charles |
| bob     | charles |
| david   | charles |
+---------+---------+
12 rows in set (0.00 sec)
```

Also, we don't want to recommend people who are already friends.

```
SELECT * FROM
(SELECT DISTINCT user_id FROM Friendship) AS a
CROSS JOIN
(SELECT DISTINCT user_id FROM Friendship) AS b
ON a.user_id != b.user_id
AND (a.user_id, b.user_id) NOT IN (SELECT user_id, friend_id FROM Friendship)
AND (b.user_id, a.user_id) NOT IN (SELECT user_id, friend_id FROM Friendship);

+---------+---------+
| user_id | user_id |
+---------+---------+
| charles | david   |
| david   | charles |
+---------+---------+
2 rows in set (0.01 sec)
```

___
### Step 2. Expand Two-way
The rest is the same as the previous problem. Here I constructed a tmp table to exclude existing friendship, instead of using two *AND* clause.
```sql
WITH tmp AS (
SELECT user_id, friend_id FROM Friendship
UNION ALL
SELECT friend_id, user_id FROM Friendship
)
SELECT 
	a.user_id
	,b.user_id
	,af.friend_id AS common_friend
FROM
(SELECT DISTINCT user_id FROM Friendship) AS a
CROSS JOIN
(SELECT DISTINCT user_id FROM Friendship) AS b
	ON a.user_id != b.user_id
	AND (a.user_id, b.user_id) NOT IN (SELECT user_id, friend_id FROM tmp)
JOIN tmp AS af
	ON a.user_id = af.user_id
JOIN tmp AS bf
	ON b.user_id = bf.user_id
	AND bf.friend_id = af.friend_id;
```
```
+---------+---------+---------------+
| user_id | user_id | common_friend |
+---------+---------+---------------+
| david   | charles | sonny         |
| david   | charles | alice         |
| david   | charles | bob           |
| charles | david   | sonny         |
| charles | david   | alice         |
| charles | david   | bob           |
+---------+---------+---------------+
6 rows in set (0.00 sec)
```

___
### Step 3. Aggregation
Group by the user_id pair and count the number of common friends. 

```sql
WITH tmp AS (
SELECT user_id, friend_id FROM Friendship
UNION ALL
SELECT friend_id, user_id FROM Friendship
)
SELECT 
	a.user_id
	,b.user_id
	,COUNT(*) AS common_friend
FROM
(SELECT DISTINCT user_id FROM Friendship) AS a
CROSS JOIN
(SELECT DISTINCT user_id FROM Friendship) AS b
	ON a.user_id != b.user_id
	AND (a.user_id, b.user_id) NOT IN (SELECT user_id, friend_id FROM tmp)
JOIN tmp AS af
	ON a.user_id = af.user_id
JOIN tmp AS bf
	ON b.user_id = bf.user_id
	AND bf.friend_id = af.friend_id
GROUP BY a.user_id, b.user_id
ORDER BY common_friend DESC;
```
```
+---------+---------+---------------+
| user_id | user_id | common_friend |
+---------+---------+---------------+
| david   | charles |             3 |
| charles | david   |             3 |
+---------+---------+---------------+
2 rows in set (0.00 sec)
```

See solution [here](solution.sql).