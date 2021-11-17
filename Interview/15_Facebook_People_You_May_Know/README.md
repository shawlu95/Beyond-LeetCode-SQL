# People You May Know
> Based on the number of common friends, recommend users to be friend.

___
### Observation
This is a slight twist on the previous problem. Instead of selecting from existing friendships, we are proposing new ones. We'll use the same table as before.

___
### Step 1. Find Candidate Pairs
This can be done with a cross join. Obviously we want to avoid matching a user with himself.

```sql
WITH tmp AS (
SELECT user_id, friend_id FROM Friendship
UNION ALL
SELECT friend_id, user_id FROM Friendship
)

SELECT * FROM
(SELECT DISTINCT user_id FROM tmp) AS a
CROSS JOIN
(SELECT DISTINCT user_id FROM tmp) AS b
ON a.user_id != b.user_id;
```
```
+---------+---------+
| user_id | user_id |
+---------+---------+
| bob     | alice   |
| david   | alice   |
| charles | alice   |
| mary    | alice   |
| sonny   | alice   |
| alice   | bob     |
| david   | bob     |
| charles | bob     |
| mary    | bob     |
| sonny   | bob     |
| alice   | david   |
| bob     | david   |
| charles | david   |
| mary    | david   |
| sonny   | david   |
| alice   | charles |
| bob     | charles |
| david   | charles |
| mary    | charles |
| sonny   | charles |
| alice   | mary    |
| bob     | mary    |
| david   | mary    |
| charles | mary    |
| sonny   | mary    |
| alice   | sonny   |
| bob     | sonny   |
| david   | sonny   |
| charles | sonny   |
| mary    | sonny   |
+---------+---------+
30 rows in set (0.00 sec)
```

Also, we don't want to recommend people who are already friends.

```sql
WITH tmp AS (
SELECT user_id, friend_id FROM Friendship
UNION ALL
SELECT friend_id, user_id FROM Friendship
)

SELECT * FROM
(SELECT DISTINCT user_id FROM tmp) AS a
CROSS JOIN
(SELECT DISTINCT user_id FROM tmp) AS b
ON a.user_id != b.user_id
AND (a.user_id, b.user_id) NOT IN (SELECT user_id, friend_id FROM tmp);
```
```
+---------+---------+
| user_id | user_id |
+---------+---------+
| sonny   | alice   |
| charles | david   |
| mary    | david   |
| david   | charles |
| mary    | charles |
| david   | mary    |
| charles | mary    |
| sonny   | mary    |
| alice   | sonny   |
| mary    | sonny   |
+---------+---------+
10 rows in set (0.00 sec)
```

___
### Step 2. Expand Two-way
The rest is the same as the previous problem.
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
(SELECT DISTINCT user_id FROM tmp) AS a
CROSS JOIN
(SELECT DISTINCT user_id FROM tmp) AS b
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
| alice   | sonny   | bob           |
| alice   | sonny   | charles       |
| alice   | sonny   | david         |
| david   | charles | sonny         |
| charles | david   | sonny         |
| charles | david   | alice         |
| charles | mary    | alice         |
| david   | charles | alice         |
| david   | mary    | alice         |
| mary    | charles | alice         |
| mary    | david   | alice         |
| david   | charles | bob           |
| david   | mary    | bob           |
| charles | david   | bob           |
| charles | mary    | bob           |
| mary    | david   | bob           |
| mary    | charles | bob           |
| mary    | sonny   | bob           |
| sonny   | alice   | david         |
| sonny   | alice   | charles       |
| sonny   | alice   | bob           |
| sonny   | mary    | bob           |
+---------+---------+---------------+
22 rows in set (0.01 sec)
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
(SELECT DISTINCT user_id FROM tmp) AS a
CROSS JOIN
(SELECT DISTINCT user_id FROM tmp) AS b
	ON a.user_id != b.user_id
	AND (a.user_id, b.user_id) NOT IN (SELECT user_id, friend_id FROM tmp)
JOIN tmp AS af
	ON a.user_id = af.user_id
JOIN tmp AS bf
	ON b.user_id = bf.user_id
	AND bf.friend_id = af.friend_id
GROUP BY a.user_id, b.user_id
HAVING COUNT(*) >= 3
ORDER BY common_friend DESC;
```
```
+---------+---------+---------------+
| user_id | user_id | common_friend |
+---------+---------+---------------+
| alice   | sonny   |             3 |
| david   | charles |             3 |
| charles | david   |             3 |
| sonny   | alice   |             3 |
+---------+---------+---------------+
4 rows in set (0.00 sec)
```

See solution [here](solution.sql).