# Recommending Friend

> Write a query that identifies all the users that listened  to three of the same songs on Spotify, on the same day, as someone in their friend list. Assume we have the following table
* Song: user_id, song_id, ts
* User: user_id, friend_id

This is one of the hardest question I found online. So far I haven't seen anyone who posted the correct solution. This question tests multiple concepts and numerous edge cases. Among those are:
* Self-join.
* __De-duplication.__
* Exclusion.
* Equi-join, non equi-join.
* Aggregation.

To understand de-duplication, one needs to fully grasp the self-join mechanism, and be able to come up with simple example to keep track of the number of rows.

___
### Load Data
Load the database file [db.sql](db.sql) to localhost MySQL. A SpotifyFriend database will be created with two tables. 
```
mysql < db.sql -uroot -p
```

```
mysql> SELECT * FROM Song LIMIT 5;
+----+---------+-------------------+------------+
| id | user_id | song              | ts         |
+----+---------+-------------------+------------+
|  1 | Alex    | Kiroro            | 2019-03-17 |
|  2 | Alex    | Shape of My Heart | 2019-03-17 |
|  3 | Alex    | Clair de Lune     | 2019-03-17 |
|  4 | Alex    | The Fall          | 2019-03-17 |
|  5 | Alex    | Forever Young     | 2019-03-17 |
+----+---------+-------------------+------------+
5 rows in set (0.00 sec)

mysql> SELECT * FROM User;
+----+---------+-----------+
| id | user_id | friend_id |
+----+---------+-----------+
|  1 | Cindy   | Bill      |
+----+---------+-----------+
1 row in set (0.00 sec)
```

___
### Thought Process
First thing we notice is that we should __not__ join with the *User* table, because doing so will give us pair of users who are already friends. The question explicitly asks for friend recommendation, meaning that we only want to return pair of users who are __not yet friends__.

There are several steps in building the recommendation pairs.
* Step 1: self-join song table.
* Step 2: aggregating the joined table, to count common songs listened by the same user on the same day.
* Step 3: Filter out user pairs who are already friends.

___
#### Step 1. Self Join
Let's first clear-up the arithmetic of inner join. If one row in left table finds N matches on the right table, N rows will be returned, with the one row from the left multipled N times to match the right.

Self-join is no different. If we apply enough condition to restrict matching, we only end up matching one row to one row, and the result contains the same number of rows as before self join.

```
SELECT
  *
FROM Song AS s1
WHERE s1.user_id = 'Cindy'
  AND s1.ts = '2019-03-14';
+----+---------+---------------+------------+
| id | user_id | song          | ts         |
+----+---------+---------------+------------+
| 19 | Cindy   | My Love       | 2019-03-14 |
| 20 | Cindy   | Clair de Lune | 2019-03-14 |
| 21 | Cindy   | Lemon Tree    | 2019-03-14 |
| 22 | Cindy   | Mad World     | 2019-03-14 |
+----+---------+---------------+------------+
4 rows in set (0.00 sec)

SELECT
  *
FROM Song AS s1
JOIN Song AS s2
  ON s1.ts = s2.ts
  AND s1.song = s2.song
WHERE s1.user_id = 'Cindy'
  AND s2.user_id = 'Cindy'
  AND s1.ts = '2019-03-14';

+----+---------+---------------+------------+----+---------+---------------+------------+
| id | user_id | song          | ts         | id | user_id | song          | ts         |
+----+---------+---------------+------------+----+---------+---------------+------------+
| 19 | Cindy   | My Love       | 2019-03-14 | 19 | Cindy   | My Love       | 2019-03-14 |
| 20 | Cindy   | Clair de Lune | 2019-03-14 | 20 | Cindy   | Clair de Lune | 2019-03-14 |
| 21 | Cindy   | Lemon Tree    | 2019-03-14 | 21 | Cindy   | Lemon Tree    | 2019-03-14 |
| 22 | Cindy   | Mad World     | 2019-03-14 | 22 | Cindy   | Mad World     | 2019-03-14 |
+----+---------+---------------+------------+----+---------+---------------+------------+
4 rows in set (0.00 sec)
```

In this example, we don't want to match a user to himself. So we need two equalities and one inequality in the self join: the date and song will be equal, and the user_id must not be equal. Now let's self-join on a small scale, for Cindy and Bill on Mar-14.

```
SELECT
  *
FROM Song AS s1
WHERE s1.user_id = 'Bill'
  AND s1.ts = '2019-03-14';

+----+---------+------------+------------+
| id | user_id | song       | ts         |
+----+---------+------------+------------+
| 10 | Bill    | My Love    | 2019-03-14 |
| 23 | Bill    | Lemon Tree | 2019-03-14 |
| 24 | Bill    | Mad World  | 2019-03-14 |
| 25 | Bill    | My Love    | 2019-03-14 |
+----+---------+------------+------------+
4 rows in set (0.00 sec)
```

Can you predict the result of this join? Here is the accounting:
* Cindy and Bill listened to Lemon Tree once, resulting 1 row. The reverse direction also returns 1 row (the same goes for Mad World).
* Cindy listened to My Love once. Bill listened to it twice, resulting in 2 rows. The reverse direction also returns 2 rows.
* Cindy listened to Clair de Lune whereas Bill did not, returning 0 match.
* The total number of rows returned is (1 + 1) * 2 + (2 + 2) = 8 rows.

```
SELECT
  s1.user_id
  ,s2.user_id
  ,s2.song
  ,s2.ts
FROM (SELECT * FROM Song WHERE user_id IN ('Cindy', 'Bill') AND ts = '2019-03-14') AS s1
JOIN (SELECT * FROM Song WHERE user_id IN ('Cindy', 'Bill') AND ts = '2019-03-14') AS s2
  ON s1.user_id != s2.user_id
  AND s1.song = s2.song
ORDER BY s1.user_id, s2.user_id, s2.song;

+---------+---------+------------+------------+
| user_id | user_id | song       | ts         |
+---------+---------+------------+------------+
| Bill    | Cindy   | Lemon Tree | 2019-03-14 |
| Bill    | Cindy   | Mad World  | 2019-03-14 |
| Bill    | Cindy   | My Love    | 2019-03-14 |
| Bill    | Cindy   | My Love    | 2019-03-14 |
| Cindy   | Bill    | Lemon Tree | 2019-03-14 |
| Cindy   | Bill    | Mad World  | 2019-03-14 |
| Cindy   | Bill    | My Love    | 2019-03-14 |
| Cindy   | Bill    | My Love    | 2019-03-14 |
+---------+---------+------------+------------+
8 rows in set (0.00 sec)
```

The key revelation here is that self-join is a two-eay process. If a row on the left matches to two rows on the right, the two row from the right will appear somewhere inside the left table (because there is only one table). The result is __symmetric__.

___
#### Symmetry of Self-join
<p align="center">
    <img src="fig/symmetry.png" width="700">
</p>
From left to right, the graph represent the following self-join.

__Left graph: two edges__
```
SELECT * FROM Song WHERE id IN (22, 24);
+----+---------+-----------+------------+
| id | user_id | song      | ts         |
+----+---------+-----------+------------+
| 22 | Cindy   | Mad World | 2019-03-14 |
| 24 | Bill    | Mad World | 2019-03-14 |
+----+---------+-----------+------------+

WITH tmp AS (
SELECT * FROM Song WHERE id IN (22, 24)
)
SELECT
  *
FROM tmp AS s1
JOIN tmp AS s2
  ON s1.user_id != s2.user_id
  AND s1.song = s2.song
ORDER BY s1.user_id, s2.user_id, s2.song;
+----+---------+-----------+------------+----+---------+-----------+------------+
| id | user_id | song      | ts         | id | user_id | song      | ts         |
+----+---------+-----------+------------+----+---------+-----------+------------+
| 24 | Bill    | Mad World | 2019-03-14 | 22 | Cindy   | Mad World | 2019-03-14 |
| 22 | Cindy   | Mad World | 2019-03-14 | 24 | Bill    | Mad World | 2019-03-14 |
+----+---------+-----------+------------+----+---------+-----------+------------+
```

__Middle graph: four edges__
```
SELECT * FROM Song WHERE id IN (2, 15, 16);
+----+---------+-------------------+------------+
| id | user_id | song              | ts         |
+----+---------+-------------------+------------+
|  2 | Alex    | Shape of My Heart | 2019-03-17 |
| 15 | Bill    | Shape of My Heart | 2019-03-17 |
| 16 | Bill    | Shape of My Heart | 2019-03-17 |
+----+---------+-------------------+------------+
3 rows in set (0.00 sec)

WITH tmp AS (
SELECT * FROM Song WHERE id IN (2, 15, 16)
)
SELECT
  *
FROM tmp AS s1
JOIN tmp AS s2
  ON s1.user_id != s2.user_id
  AND s1.song = s2.song
ORDER BY s1.user_id, s2.user_id, s2.song;
+----+---------+-------------------+------------+----+---------+-------------------+------------+
| id | user_id | song              | ts         | id | user_id | song              | ts         |
+----+---------+-------------------+------------+----+---------+-------------------+------------+
|  2 | Alex    | Shape of My Heart | 2019-03-17 | 16 | Bill    | Shape of My Heart | 2019-03-17 |
|  2 | Alex    | Shape of My Heart | 2019-03-17 | 15 | Bill    | Shape of My Heart | 2019-03-17 |
| 15 | Bill    | Shape of My Heart | 2019-03-17 |  2 | Alex    | Shape of My Heart | 2019-03-17 |
| 16 | Bill    | Shape of My Heart | 2019-03-17 |  2 | Alex    | Shape of My Heart | 2019-03-17 |
+----+---------+-------------------+------------+----+---------+-------------------+------------+
4 rows in set (0.00 sec)
```

__Right graph: eight edges__
```
SELECT * FROM Song WHERE id IN (12, 13, 14, 15);
+----+---------+-------------------+------------+
| id | user_id | song              | ts         |
+----+---------+-------------------+------------+
| 12 | Alex    | Shape of My Heart | 2019-03-17 |
| 13 | Alex    | Shape of My Heart | 2019-03-17 |
| 14 | Bill    | Shape of My Heart | 2019-03-17 |
| 15 | Bill    | Shape of My Heart | 2019-03-17 |
+----+---------+-------------------+------------+
4 rows in set (0.01 sec)

WITH tmp AS (
SELECT * FROM Song WHERE id IN (12, 13, 14, 15)
)
SELECT
  *
FROM tmp AS s1
JOIN tmp AS s2
  ON s1.user_id != s2.user_id
  AND s1.song = s2.song
ORDER BY s1.user_id, s2.user_id, s2.song;
+----+---------+-------------------+------------+----+---------+-------------------+------------+
| id | user_id | song              | ts         | id | user_id | song              | ts         |
+----+---------+-------------------+------------+----+---------+-------------------+------------+
| 12 | Alex    | Shape of My Heart | 2019-03-17 | 14 | Bill    | Shape of My Heart | 2019-03-17 |
| 13 | Alex    | Shape of My Heart | 2019-03-17 | 14 | Bill    | Shape of My Heart | 2019-03-17 |
| 12 | Alex    | Shape of My Heart | 2019-03-17 | 15 | Bill    | Shape of My Heart | 2019-03-17 |
| 13 | Alex    | Shape of My Heart | 2019-03-17 | 15 | Bill    | Shape of My Heart | 2019-03-17 |
| 15 | Bill    | Shape of My Heart | 2019-03-17 | 13 | Alex    | Shape of My Heart | 2019-03-17 |
| 14 | Bill    | Shape of My Heart | 2019-03-17 | 12 | Alex    | Shape of My Heart | 2019-03-17 |
| 15 | Bill    | Shape of My Heart | 2019-03-17 | 12 | Alex    | Shape of My Heart | 2019-03-17 |
| 14 | Bill    | Shape of My Heart | 2019-03-17 | 13 | Alex    | Shape of My Heart | 2019-03-17 |
+----+---------+-------------------+------------+----+---------+-------------------+------------+
8 rows in set (0.00 sec)
```
___ 
#### Step 2. Aggregation
Identify that there are three columns to aggregate over: user_id pair and date. 
```
SELECT
  s1.user_id
  ,s2.user_id
  ,COUNT(DISTINCT s2.song)
  ,s2.ts
FROM (SELECT * FROM Song WHERE user_id IN ('Cindy', 'Bill') AND ts = '2019-03-14') AS s1
JOIN (SELECT * FROM Song WHERE user_id IN ('Cindy', 'Bill') AND ts = '2019-03-14') AS s2
  ON s1.user_id != s2.user_id
  AND s1.ts = s2.ts
  AND s1.song = s2.song
GROUP BY s1.user_id, s2.user_id, s2.ts;

+---------+---------+-------------------------+------------+
| user_id | user_id | COUNT(DISTINCT s2.song) | ts         |
+---------+---------+-------------------------+------------+
| Bill    | Cindy   |                       3 | 2019-03-14 |
| Cindy   | Bill    |                       3 | 2019-03-14 |
+---------+---------+-------------------------+------------+
2 rows in set (0.00 sec)
```

It's clear that the user_id pair is counted both way, and the count is correct and identical! This is the most confusing part of thie question.

Now we can replace the truncated table with the full table.

```
SELECT
  s1.user_id
  ,s2.user_id
  ,COUNT(DISTINCT s2.song) AS common_song
  ,s2.ts
FROM Song AS s1
JOIN Song AS s2
  ON s1.user_id != s2.user_id
  AND s1.ts = s2.ts
  AND s1.song = s2.song
GROUP BY s1.user_id, s2.user_id, s2.ts
ORDER BY s2.ts, common_song;

+---------+---------+-------------+------------+
| user_id | user_id | common_song | ts         |
+---------+---------+-------------+------------+
| Bill    | Cindy   |           3 | 2019-03-14 |
| Cindy   | Bill    |           3 | 2019-03-14 |
| Bill    | Cindy   |           1 | 2019-03-17 |
| Cindy   | Bill    |           1 | 2019-03-17 |
| Alex    | Cindy   |           2 | 2019-03-17 |
| Cindy   | Alex    |           2 | 2019-03-17 |
| Bill    | Alex    |           4 | 2019-03-17 |
| Alex    | Bill    |           4 | 2019-03-17 |
+---------+---------+-------------+------------+
8 rows in set (0.01 sec)
```
___
#### Step 3. Filtering
First we need to filter user_id pair that have fewer than 3 common song on any day.

```
SELECT
  s1.user_id
  ,s2.user_id
  ,COUNT(DISTINCT s2.song) AS common_song
  ,s2.ts
FROM Song AS s1
JOIN Song AS s2
  ON s1.user_id != s2.user_id
  AND s1.ts = s2.ts
  AND s1.song = s2.song
GROUP BY s1.user_id, s2.user_id, s2.ts
HAVING common_song >= 3;

+---------+---------+-------------+------------+
| user_id | user_id | common_song | ts         |
+---------+---------+-------------+------------+
| Alex    | Bill    |           4 | 2019-03-17 |
| Bill    | Alex    |           4 | 2019-03-17 |
| Bill    | Cindy   |           3 | 2019-03-14 |
| Cindy   | Bill    |           3 | 2019-03-14 |
+---------+---------+-------------+------------+
4 rows in set (0.00 sec)
```

Next, we need to filter user_id pairs that are already friend. Because the Friend table accounts for one way edge, we need to *UNION* with the opposite direction.
```
SELECT
  s1.user_id
  ,s2.user_id AS recommended
FROM Song AS s1
JOIN Song AS s2
  ON s1.user_id != s2.user_id
  AND s1.ts = s2.ts
  AND s1.song = s2.song
WHERE (s1.user_id, s2.user_id) NOT IN (
  SELECT user_id, friend_id FROM User
  UNION
  SELECT friend_id, user_id FROM User
)
GROUP BY s1.user_id, s2.user_id, s2.ts
HAVING COUNT(DISTINCT s2.song) >= 3;

+---------+-------------+
| user_id | recommended |
+---------+-------------+
| Alex    | Bill        |
| Bill    | Alex        |
+---------+-------------+
2 rows in set (0.00 sec)
```

We can probably stop here, because the recommendation will be sent to both nodes of the same edge. For example, just take a single column, and recommend to them the user_id from the second column. 

See full solution [here](solution.sql).

___
#### Parting Thought
Do not directly start writing code. There are so many ways things can go wrong that you're bound to run out of time correcting mistakes. Work with simple examples on the whiteboard to get the general direction correct, don't run into crazy mistakes such as joining User table with Song table (automatic fail). Identify some edge cases such as user listens to the same song multiple times a day. Discuss how to handle NULL (though in this song table, both song and user_id are foreign keys, and by referential integrity, must have parent key). 