-- create source table
DROP TABLE IF EXISTS sample_dist_stats;
CREATE TEMPORARY TABLE sample_dist_stats AS
SELECT
  continent
  ,COUNT(*) AS city_tally
  ,10/COUNT(*) AS p
  ,10 AS mean
  ,SQRT(COUNT(*) * (10/COUNT(*)) * (1-10/COUNT(*))) AS std
FROM city_by_continent
GROUP BY continent
ORDER BY city_tally;

SET @sample_size = 10;

-- sampling pipeline
WITH 
city_group AS 
  (SELECT
    c.*
    ,COUNT(*) OVER (PARTITION BY continent) AS group_size
  FROM city_by_continent AS c)
,city_prob_assign AS 
  (SELECT
    c.*
    -- beaware expectation of sample size group_size * @sample_size / group_size AS mean = @sample_size
    ,SQRT(group_size * (@sample_size / group_size) * (1 - @sample_size / group_size)) AS std
    ,RAND() AS prob
  FROM city_group AS c)
,city_prob_cutoff AS 
  (SELECT
    c.*
    ,(@sample_size + CEIL(2 * std)) / group_size AS cutoff
  FROM city_prob_assign AS c)
-- filter by cuffoff
-- note that this step cannot be merged with previous
,city_sample AS 
  (SELECT 
    c.*
    -- window is evaluated after WHERE clause!
    -- ranking is cheap when performed on small group!
    ,RANK() OVER (PARTITION BY continent ORDER BY prob) AS group_row_num
  FROM city_prob_cutoff AS c
  WHERE prob < cutoff)
-- final, fixed size sample
SELECT * 
FROM city_sample
WHERE group_row_num <= @sample_size;