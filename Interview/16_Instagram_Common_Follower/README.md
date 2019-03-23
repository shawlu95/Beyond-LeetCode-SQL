# Instagram Common Follower
> Given a *Follow* table, find the pair of instagram accounts which share highest number of common followers.

___
### Load Data
Load the database file [db.sql](db.sql) to localhost MySQL. A Instagram database will be created with one Follow table. 
```
mysql < db.sql -uroot -p
```

___
### Observation
The major realization is that following is a one-way relationship, unlike friendship which must be two-way. The rest is similar to the earlier problem.

___
### Step 1. Build Candidate Pairs
Find all possible account pairs using cross join. Avoid matching an account to itself.
```
SELECT *
FROM
(SELECT DISTINCT user_id FROM Follow) AS a
CROSS JOIN
(SELECT DISTINCT user_id FROM Follow) AS b 
ON a.user_id != b.user_id

+---------+---------+
| user_id | user_id |
+---------+---------+
| musk    | bezos   |
| ronaldo | bezos   |
| trump   | bezos   |
| bezos   | musk    |
| ronaldo | musk    |
| trump   | musk    |
| bezos   | ronaldo |
| musk    | ronaldo |
| trump   | ronaldo |
| bezos   | trump   |
| musk    | trump   |
| ronaldo | trump   |
+---------+---------+
12 rows in set (0.00 sec)
```

___
### Step 2. Find Common Followers
```
SELECT *
FROM
(SELECT DISTINCT user_id FROM Follow) AS a
CROSS JOIN
(SELECT DISTINCT user_id FROM Follow) AS b 
ON a.user_id != b.user_id
JOIN Follow AS af
ON a.user_id = af.user_id
JOIN Follow AS bf
ON b.user_id = bf.user_id
AND af.follower_id = bf.follower_id;

+---------+---------+---------+-------------+---------+-------------+
| user_id | user_id | user_id | follower_id | user_id | follower_id |
+---------+---------+---------+-------------+---------+-------------+
| musk    | bezos   | musk    | david       | bezos   | david       |
| ronaldo | bezos   | ronaldo | david       | bezos   | david       |
| ronaldo | bezos   | ronaldo | james       | bezos   | james       |
| ronaldo | bezos   | ronaldo | mary        | bezos   | mary        |
| bezos   | musk    | bezos   | david       | musk    | david       |
| ronaldo | musk    | ronaldo | david       | musk    | david       |
| bezos   | ronaldo | bezos   | david       | ronaldo | david       |
| musk    | ronaldo | musk    | david       | ronaldo | david       |
| bezos   | ronaldo | bezos   | james       | ronaldo | james       |
| bezos   | ronaldo | bezos   | mary        | ronaldo | mary        |
+---------+---------+---------+-------------+---------+-------------+
10 rows in set (0.00 sec)
```

___
### Step 3. Aggregate Count
```
SELECT
a.user_id
,b.user_id
,COUNT(*) AS common
FROM
(SELECT DISTINCT user_id FROM Follow) AS a
CROSS JOIN
(SELECT DISTINCT user_id FROM Follow) AS b 
ON a.user_id != b.user_id
JOIN Follow AS af
ON a.user_id = af.user_id
JOIN Follow AS bf
ON b.user_id = bf.user_id
AND af.follower_id = bf.follower_id
GROUP BY a.user_id, b.user_id
ORDER BY common DESC, a.user_id, b.user_id;

+---------+---------+--------+
| user_id | user_id | common |
+---------+---------+--------+
| bezos   | ronaldo |      3 |
| ronaldo | bezos   |      3 |
| bezos   | musk    |      1 |
| musk    | bezos   |      1 |
| musk    | ronaldo |      1 |
| ronaldo | musk    |      1 |
+---------+---------+--------+
6 rows in set (0.00 sec)
```

___
### Parting Thought
We do we stil get candidate pairs in both direction? Because the undirected edge only affects __step 2__ when we join both parties of a candidate pair with their respective followers!

See solution [here](solution.sql).