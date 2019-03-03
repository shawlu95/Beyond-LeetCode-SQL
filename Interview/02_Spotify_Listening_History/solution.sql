SET @now = "2019-03-01 00:00:00";

-- Step 1. Build temporary table
DROP TABLE IF EXISTS daily_count;
CREATE TEMPORARY TABLE daily_count
SELECT 
  user_id
  ,song_id
  ,COUNT(*) AS tally
FROM Daily
WHERE DATEDIFF(@now, time_stamp) = 0
GROUP BY user_id, song_id;

-- Step 2. Update existing pair
UPDATE History AS uh
JOIN daily_count AS dc
  ON uh.user_id = dc.user_id
  AND uh.song_id = dc.song_id
SET uh.tally = uh.tally + dc.tally;

-- Step 3. Insert new pair
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

