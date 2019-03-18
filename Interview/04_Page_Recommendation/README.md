# Page Recommendation

This question is inspired by this quora [post](https://www.quora.com/How-can-I-prepare-for-a-case-analysis-interview-question-for-a-Facebook-data-scientist-position). Some very important key concepts are tested.

*Write an SQL query that makes recommendations using the pages that your friends liked. Assume you have two tables: a two-column table of users and their friends, and a two-column table of users and the pages they liked. It should not recommend pages you already like.*

### Key Concepts
* Accounding for mutual relationship (undirected edge) using relational table.
* Excluding pages users already follow.

### Sample data
Load the database file [db.sql](db.sql) to localhost MySQL. A Recommendation database will be created with two tables. 
```
mysql < db.sql -uroot -p
```
```
mysql> SELECT * FROM Friendship;
+----+---------+-----------+
| id | user_id | friend_id |
+----+---------+-----------+
|  1 | alice   | bob       |
|  2 | alice   | charles   |
|  3 | alice   | david     |
|  4 | bob     | david     |
+----+---------+-----------+
4 rows in set (0.00 sec)

mysql> SELECT * FROM PageFollow;
+----+---------+----------+
| id | user_id | page_id  |
+----+---------+----------+
|  1 | alice   | google   |
|  2 | bob     | google   |
|  3 | charles | google   |
|  4 | bob     | linkedin |
|  5 | charles | linkedin |
|  6 | david   | linkedin |
|  7 | david   | github   |
|  8 | charles | github   |
|  9 | alice   | facebook |
| 10 | bob     | facebook |
+----+---------+----------+
10 rows in set (0.00 sec)
```

---
### Solution
#### Step 1: Accounting Undirected Edge
Ask for clarification whether the *Friendship* table accounts for two directions. For example, if Alice is friend with Bob, are there two rows (Alice, Bob) and (Bob, Alice) in the table? If not (in this example), we need to union the table with itself.

This is necessary because when we aggregate over *user_id*, we want to match to all friends that *user_id* has. Alice will match to Bob, and Bob will match to Alice.

```
SELECT 
  user_id
  ,friend_id
FROM Friendship
UNION
SELECT 
  friend_id
  ,user_id
FROM Friendship;

+---------+-----------+
| user_id | friend_id |
+---------+-----------+
| alice   | bob       |
| alice   | charles   |
| alice   | david     |
| bob     | david     |
| bob     | alice     |
| charles | alice     |
| david   | alice     |
| david   | bob       |
+---------+-----------+
8 rows in set (0.00 sec)
```

#### Step 2: Expand Pages
We are recommending pages based on what __friends__ are following, so in this step, friend_id is joined with *PageFollow* table.
```
WITH two_way_friendship AS (
SELECT 
  user_id
  ,friend_id
FROM Friendship
UNION
SELECT 
  friend_id
  ,user_id
FROM Friendship
)
SELECT
  f.user_id
  ,f.friend_id
  ,p.page_id
FROM two_way_friendship AS f
LEFT JOIN PageFollow AS p
  ON f.friend_id = p.user_id
ORDER BY f.user_id ASC, p.page_id;

+---------+-----------+----------+
| user_id | friend_id | page_id  |
+---------+-----------+----------+
| alice   | bob       | facebook |
| alice   | charles   | github   |
| alice   | david     | github   |
| alice   | charles   | google   |
| alice   | bob       | google   |
| alice   | bob       | linkedin |
| alice   | charles   | linkedin |
| alice   | david     | linkedin |
| bob     | alice     | facebook |
| bob     | david     | github   |
| bob     | alice     | google   |
| bob     | david     | linkedin |
| charles | alice     | facebook |
| charles | alice     | google   |
| david   | alice     | facebook |
| david   | bob       | facebook |
| david   | alice     | google   |
| david   | bob       | google   |
| david   | bob       | linkedin |
+---------+-----------+----------+
```

#### Step 3: Aggregation
We are recommending for each user, the pages with highest number of followers who are friends. In other word, we are counting friends for each (user_id, page_id). Be careful with what to put in GROUP BY and what to put in COUNT().
```
WITH two_way_friendship AS (
SELECT 
  user_id
  ,friend_id
FROM Friendship
UNION
SELECT 
  friend_id
  ,user_id
FROM Friendship
)
SELECT
  f.user_id
  ,p.page_id
  ,COUNT(*) AS friends_follower
FROM two_way_friendship AS f
LEFT JOIN PageFollow AS p
  ON f.friend_id = p.user_id
GROUP BY f.user_id, p.page_id
ORDER BY f.user_id ASC, COUNT(*) DESC;

+---------+----------+------------------+
| user_id | page_id  | friends_follower |
+---------+----------+------------------+
| alice   | linkedin |                3 |
| alice   | github   |                2 |
| alice   | google   |                2 |
| alice   | facebook |                1 |
| bob     | google   |                1 |
| bob     | github   |                1 |
| bob     | facebook |                1 |
| bob     | linkedin |                1 |
| charles | google   |                1 |
| charles | facebook |                1 |
| david   | google   |                2 |
| david   | facebook |                2 |
| david   | linkedin |                1 |
+---------+----------+------------------+
13 rows in set (0.00 sec)
```

#### Step 4: De-duplicaton
We don't want to recommend pages user already likes. So we need to check for existance and exclude pages that are already liked.

In the final [solution](solution.sql) output, pages are ranked for each user by the number of friends who liked the page.
```
WITH two_way_friendship AS(
SELECT 
  user_id
  ,friend_id
FROM Friendship
UNION
SELECT 
  friend_id
  ,user_id
FROM Friendship
)
SELECT
  f.user_id
  ,p.page_id
  ,COUNT(*) AS friends_follower
FROM two_way_friendship AS f
LEFT JOIN PageFollow AS p
  ON f.friend_id = p.user_id
WHERE NOT EXISTS (
  SELECT 1 FROM PageFollow AS p2
  WHERE f.user_id = p2.user_id
    AND p.page_id = p2.page_id
)
GROUP BY f.user_id, p.page_id
ORDER BY f.user_id ASC, COUNT(*) DESC;

+---------+----------+------------------+
| user_id | page_id  | friends_follower |
+---------+----------+------------------+
| alice   | linkedin |                3 |
| alice   | github   |                2 |
| bob     | github   |                1 |
| charles | facebook |                1 |
| david   | google   |                2 |
| david   | facebook |                2 |
+---------+----------+------------------+
6 rows in set (0.00 sec)
```

---
#### Optional: Tuple Predicate
More simply, we can use two-column pairs to check existance.

```
-- MySQL equivalent solution
WITH two_way_friendship AS(
SELECT 
  user_id
  ,friend_id
FROM Friendship
UNION
SELECT 
  friend_id
  ,user_id
FROM Friendship
)
SELECT
  f.user_id
  ,p.page_id
  ,COUNT(*) AS friends_follower
FROM two_way_friendship AS f
LEFT JOIN PageFollow AS p
  ON f.friend_id = p.user_id
WHERE (f.user_id, p.page_id) NOT IN (
  SELECT user_id, page_id FROM PageFollow
)
GROUP BY f.user_id, p.page_id
ORDER BY f.user_id ASC, COUNT(*) DESC;
```

See solution [here](solution.sql).