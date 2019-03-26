# 11_Spotify_Similar_Friends

> Write a query that identifies all the users that listened  to three of the same songs on Spotify, on the same day, as someone in their friend list. Assume we have the following table
* Song: user_id, song_id, ts
* User: user_id, friend_id

This question is similar to the [last](https://github.com/shawlu95/Beyond-LeetCode-SQL/tree/master/Interview/10_Recommend_Friend) one. The difference is that we are examining users who are already friends. Instead of self-joining song table, we need a three-way-join on song-user-song tables. The key concepts to test are:
* De-duplication with *DISTINCT*.
* Join type: inner or outer join?
* Aggregation: which columns to group by?

___
### Step 1. Three-way Join
First we need to understand the mechanics of three-way join. In this example, we need *INNER* join to look for __same__ songs that are played on the __same__ day. So for any pair of user A, B who are friend, we can safely ignore songs that user A listened on a day that user B did not, and songs that user B listened on a day that user A did not: we only need the common songs.

In this problem, we are using the same [dataset](https://github.com/shawlu95/Beyond-LeetCode-SQL/blob/master/Interview/10_Recommend_Friend/db.sql) as the previous problem. There is only one friendship in the *User* table.

```sql
SELECT * FROM User;
```
```
+----+---------+-----------+
| id | user_id | friend_id |
+----+---------+-----------+
|  1 | Cindy   | Bill      |
+----+---------+-----------+
```

Now join the only friendship with *Song* table, using user_id. It's clear to see that Cindy listend to 6 songs in her entire history.
```sql
SELECT *
FROM Song AS s1
JOIN User AS u 
  ON u.user_id = s1.user_id;
```
```
+----+---------+---------------+------------+----+---------+-----------+
| id | user_id | song          | ts         | id | user_id | friend_id |
+----+---------+---------------+------------+----+---------+-----------+
| 17 | Cindy   | Kiroro        | 2019-03-17 |  1 | Cindy   | Bill      |
| 18 | Cindy   | Clair de Lune | 2019-03-17 |  1 | Cindy   | Bill      |
| 19 | Cindy   | My Love       | 2019-03-14 |  1 | Cindy   | Bill      |
| 20 | Cindy   | Clair de Lune | 2019-03-14 |  1 | Cindy   | Bill      |
| 21 | Cindy   | Lemon Tree    | 2019-03-14 |  1 | Cindy   | Bill      |
| 22 | Cindy   | Mad World     | 2019-03-14 |  1 | Cindy   | Bill      |
+----+---------+---------------+------------+----+---------+-----------+
6 rows in set (0.00 sec)
```

Join the *Song* table using friend_id. We see that Bill  listend to 11 songs in her entire history.
```sql
SELECT *
FROM Song AS s1
JOIN User AS u 
  ON u.friend_id = s1.user_id;
```
```
+----+---------+-------------------+------------+----+---------+-----------+
| id | user_id | song              | ts         | id | user_id | friend_id |
+----+---------+-------------------+------------+----+---------+-----------+
|  6 | Bill    | Shape of My Heart | 2019-03-17 |  1 | Cindy   | Bill      |
|  7 | Bill    | Clair de Lune     | 2019-03-17 |  1 | Cindy   | Bill      |
|  8 | Bill    | The Fall          | 2019-03-17 |  1 | Cindy   | Bill      |
|  9 | Bill    | Forever Young     | 2019-03-17 |  1 | Cindy   | Bill      |
| 10 | Bill    | My Love           | 2019-03-14 |  1 | Cindy   | Bill      |
| 14 | Bill    | Shape of My Heart | 2019-03-17 |  1 | Cindy   | Bill      |
| 15 | Bill    | Shape of My Heart | 2019-03-17 |  1 | Cindy   | Bill      |
| 16 | Bill    | Shape of My Heart | 2019-03-17 |  1 | Cindy   | Bill      |
| 23 | Bill    | Lemon Tree        | 2019-03-14 |  1 | Cindy   | Bill      |
| 24 | Bill    | Mad World         | 2019-03-14 |  1 | Cindy   | Bill      |
| 25 | Bill    | My Love           | 2019-03-14 |  1 | Cindy   | Bill      |
+----+---------+-------------------+------------+----+---------+-----------+
11 rows in set (0.00 sec)
```

What will be result of 3-way join without filtering? For every song that Cindy listened to, it is matched to 11 songs that Bill ever listened to. This is equivalent to a cartesian product, using *Friend* as a linkage table. Most of the paired songs are diffrent, some of them are the same. See the full cartesian product [here](cartesian.txt) to understand its structure.
```sql
SELECT COUNT(*)
FROM User AS u
JOIN Song AS s1 
  ON u.user_id = s1.user_id
JOIN Song AS s2
  ON u.friend_id = s2.user_id
```
```
+----------+
| COUNT(*) |
+----------+
|       66 |
+----------+
1 row in set (0.00 sec)
```

___
### Step 2. Filtering & Select
Apply the *WHERE* clause to get the __same__ songs listened on the __same__ day.

```sql
SELECT *
FROM Song AS s1
JOIN User AS u 
  ON u.user_id = s1.user_id
JOIN Song AS s2
  ON u.friend_id = s2.user_id
WHERE s1.ts = s2.ts
  AND s1.song = s2.song;
```
```
+----+---------+---------------+------------+----+---------+-----------+----+---------+---------------+------------+
| id | user_id | song          | ts         | id | user_id | friend_id | id | user_id | song          | ts         |
+----+---------+---------------+------------+----+---------+-----------+----+---------+---------------+------------+
| 18 | Cindy   | Clair de Lune | 2019-03-17 |  1 | Cindy   | Bill      |  7 | Bill    | Clair de Lune | 2019-03-17 |
| 19 | Cindy   | My Love       | 2019-03-14 |  1 | Cindy   | Bill      | 10 | Bill    | My Love       | 2019-03-14 |
| 21 | Cindy   | Lemon Tree    | 2019-03-14 |  1 | Cindy   | Bill      | 23 | Bill    | Lemon Tree    | 2019-03-14 |
| 22 | Cindy   | Mad World     | 2019-03-14 |  1 | Cindy   | Bill      | 24 | Bill    | Mad World     | 2019-03-14 |
| 19 | Cindy   | My Love       | 2019-03-14 |  1 | Cindy   | Bill      | 25 | Bill    | My Love       | 2019-03-14 |
+----+---------+---------------+------------+----+---------+-----------+----+---------+---------------+------------+
5 rows in set (0.00 sec)
```

Equivalently, we can move the *WHERE* clause conditions into the *JOIN* clause. 

```sql
SELECT *
FROM Song AS s1
JOIN User AS u 
  ON u.user_id = s1.user_id
JOIN Song AS s2
  ON u.friend_id = s2.user_id
  AND s1.ts = s2.ts
  AND s1.song = s2.song;
```
```
+----+---------+---------------+------------+----+---------+-----------+----+---------+---------------+------------+
| id | user_id | song          | ts         | id | user_id | friend_id | id | user_id | song          | ts         |
+----+---------+---------------+------------+----+---------+-----------+----+---------+---------------+------------+
| 18 | Cindy   | Clair de Lune | 2019-03-17 |  1 | Cindy   | Bill      |  7 | Bill    | Clair de Lune | 2019-03-17 |
| 19 | Cindy   | My Love       | 2019-03-14 |  1 | Cindy   | Bill      | 10 | Bill    | My Love       | 2019-03-14 |
| 21 | Cindy   | Lemon Tree    | 2019-03-14 |  1 | Cindy   | Bill      | 23 | Bill    | Lemon Tree    | 2019-03-14 |
| 22 | Cindy   | Mad World     | 2019-03-14 |  1 | Cindy   | Bill      | 24 | Bill    | Mad World     | 2019-03-14 |
| 19 | Cindy   | My Love       | 2019-03-14 |  1 | Cindy   | Bill      | 25 | Bill    | My Love       | 2019-03-14 |
+----+---------+---------------+------------+----+---------+-----------+----+---------+---------------+------------+
5 rows in set (0.00 sec)
```

___
### Step 3. De-duplication
Note that 'My Love' is double counted on March 14. We don't want to count it as two different songs. So in the *COUNT()* function, we need to count *DISTINCT* song title.

```sql
SELECT 
  s1.ts, u.user_id
  ,u.friend_id
  ,COUNT(DISTINCT s1.song) AS shared
FROM User AS u
JOIN Song AS s1 
  ON u.user_id = s1.user_id
JOIN Song AS s2
  ON u.friend_id = s2.user_id
WHERE s1.ts = s2.ts
  AND s1.song = s2.song
GROUP BY s1.ts, u.user_id, u.friend_id
HAVING shared >= 3;
```
```
+------------+---------+-----------+--------+
| ts         | user_id | friend_id | shared |
+------------+---------+-----------+--------+
| 2019-03-14 | Cindy   | Bill      |      3 |
+------------+---------+-----------+--------+
1 row in set (0.01 sec)
```

Finally, filter user pairs who have at least three songs on common on any day. Note that we need to select *DISTINCT* user pair. Because a pair of users may listened to more than three common songs in more than one day!

```sql
SELECT DISTINCT
  u.user_id
  ,u.friend_id
FROM User AS u
JOIN Song AS s1 
  ON u.user_id = s1.user_id
JOIN Song AS s2
  ON u.friend_id = s2.user_id
WHERE s1.ts = s2.ts
  AND s1.song = s2.song
GROUP BY s1.ts, u.user_id, u.friend_id
HAVING COUNT(DISTINCT s1.song) >= 3;
```
```
+---------+-----------+
| user_id | friend_id |
+---------+-----------+
| Cindy   | Bill      |
+---------+-----------+
1 row in set (0.00 sec)
```

___
### Cross Join Solution
The cross join yields the same result.
```sql
-- cross join
SELECT DISTINCT
  u.user_id, u.friend_id
FROM
  User u, Song s1, Song s2
WHERE
  u.user_id = s1.user_id
  AND u.friend_id = s2.user_id
  AND s1.song = s2.song
  AND s1.ts = s2.ts
GROUP BY 1, 2, s1.ts
HAVING COUNT(DISTINCT s1.song) >= 3;
```
```
+---------+-----------+
| user_id | friend_id |
+---------+-----------+
| Cindy   | Bill      |
+---------+-----------+
1 row in set (0.00 sec)
```

### Optional: Pre-filtering
Because the user table is large, and most users may be inactive most of the days, it is preferable to pre-filter tables such that only users who have evner listened to >= 3 songs a day are included in the join. 

```sql
WITH active_user_id AS (
  SELECT
    u.user_id
    ,s.ts
    ,COUNT(*) AS song_tally
  FROM user AS u
  JOIN song AS s
  ON u.user_id = s.user_id
  GROUP BY user_id, ts
  HAVING COUNT(*) >= 3
)
,active_friend_id AS (
  SELECT
    u.friend_id
    ,s.ts
    ,COUNT(*) AS song_tally
  FROM user AS u
  JOIN song AS s
  ON u.friend_id = s.user_id
  GROUP BY friend_id, ts
  HAVING COUNT(*) >= 3
)
,possible_match AS (
  SELECT
    u.user_id
    ,f.friend_id
    ,f.ts
  FROM active_user_id AS u
  JOIN active_friend_id AS f
  ON u.ts = f.ts
)
SELECT DISTINCT 
  p.user_id
  ,p.friend_id
FROM possible_match AS p
JOIN song AS s1
  ON p.ts = s1.ts
  AND p.user_id = s1.user_id
JOIN song AS s2
ON p.ts = s2.ts
  AND p.friend_id = s2.user_id
WHERE s2.song = s1.song
GROUP BY p.user_id, p.friend_id, s1.ts
HAVING COUNT(DISTINCT s1.song) >= 3;
```
```
+---------+-----------+
| user_id | friend_id |
+---------+-----------+
| Cindy   | Bill      |
+---------+-----------+
1 row in set (0.00 sec)
```

See solution [here](solution.sql).