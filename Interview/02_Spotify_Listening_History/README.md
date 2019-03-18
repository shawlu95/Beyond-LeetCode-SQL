# Spotify Listening History

### Key Concepts
* Update aggregate table with event log.
* Temporary table & reusability.
* Update with join statement.
* Edge case: adding new user-song pair.
* Aggregation.

---
### Two Tables
You have a History table where you have date, user_id, song_id and count(tally).
It shows at the end of each day how many times in her history a user has listened to a given song.
So count is cumulative sum.

You have to update this on a daily basis based on a second *Daily* table that records 
in real time when a user listens to a given song.

Basically, at the end of each day, you go to this second table and pull a count 
of each user/song combination and then add this count to the first table that 
has the lifetime count.

### Sample Database
Load the database file [db.sql](db.sql) to localhost MySQL. A Spotify database will be created with two tables. 
```
mysql < db.sql -uroot -p
```

```
mysql> SELECT * from History;
+----+---------+---------+-------+
| id | user_id | song_id | tally |
+----+---------+---------+-------+
|  1 | shaw    | rise    |     2 |
|  2 | linda   | lemon   |     4 |
+----+---------+---------+-------+
2 rows in set (0.00 sec)

mysql> SELECT * from Daily;
+----+---------+---------+---------------------+
| id | user_id | song_id | time_stamp          |
+----+---------+---------+---------------------+
|  1 | shaw    | rise    | 2019-03-01 05:33:08 |
|  2 | shaw    | rise    | 2019-03-01 16:00:00 |
|  3 | shaw    | goodie  | 2019-03-01 10:15:00 |
|  4 | linda   | lemon   | 2019-02-28 00:00:00 |
|  5 | mark    | game    | 2019-03-01 04:00:00 |
+----+---------+---------+---------------------+
5 rows in set (0.00 sec)
```

---
### Observation 
* Note that the *Daily* table is a event-log. To update *History*, we need to aggregate the event log, grouping by *user_id* and *song_id*.
* A user may listen to a new song for the first time, in which case no existing (*user_id*, *song_id*) compound key pair exists in the *History* table. So we need an additional INSERT statement.

### Solution
__Step 1. Build temporary table.__ 
For both the UPDATE and INSERT statements, we need the same aggregated information from the *Daily* table. So we can save it as a temporary table.
```
SET @now = "2019-03-01 00:00:00";

-- Create tamporary table
DROP TABLE IF EXISTS daily_count;
CREATE TEMPORARY TABLE daily_count
SELECT 
  user_id
  ,song_id
  ,COUNT(*) AS tally
FROM Daily
WHERE DATEDIFF(@now, time_stamp) = 0
GROUP BY user_id, song_id;
```

Check the temporary table.
```
mysql> SELECT * FROM daily_count;       
+---------+---------+-------+
| user_id | song_id | tally |
+---------+---------+-------+
| mark    | game    |     1 |
| shaw    | goodie  |     1 |
| shaw    | rise    |     2 |
+---------+---------+-------+
3 rows in set (0.00 sec)
```

__Step 2. Update existing pair.__ It's okay to join the temporary table with the History table during the update process, because History is independent of the temporary table. 
```
UPDATE History AS uh
JOIN daily_count AS dc
  ON uh.user_id = dc.user_id
  AND uh.song_id = dc.song_id
SET uh.tally = uh.tally + dc.tally;
```

Check if update is correct: *shaw* listened to *rise* twice on March 1. So the compound key is incremented by 2. On the other hand, linda did not listened to any song on March 1. So her number doesn't change.
```
mysql> SELECT * FROM History;
+----+---------+---------+-------+
| id | user_id | song_id | tally |
+----+---------+---------+-------+
|  1 | shaw    | rise    |     4 |
|  2 | linda   | lemon   |     4 |
+----+---------+---------+-------+
2 rows in set (0.00 sec)
```

__Step 3. Insert new pair.__ After updating existing (*user_id*, *song_id*) compound key pair, we need to insert new ones:

```
INSERT INTO History (user_id, song_id, tally)
SELECT
  dc.user_id
  ,dc.song_id
  ,dc.tally
FROM daily_count AS dc
LEFT JOIN History AS uh
  ON dc.user_id = uh.user_id
  AND dc.song_id = uh.song_id
WHERE uh.tally IS NULL;
```

Check that the insertions are correct.
```
mysql> SELECT * FROM History;
+----+---------+---------+-------+
| id | user_id | song_id | tally |
+----+---------+---------+-------+
|  1 | shaw    | rise    |     4 |
|  2 | linda   | lemon   |     4 |
|  3 | mark    | game    |     1 |
|  4 | shaw    | goodie  |     1 |
+----+---------+---------+-------+
4 rows in set (0.00 sec)
```

See solution [here](solution.sql).