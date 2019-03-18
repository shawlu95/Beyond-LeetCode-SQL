-- MySQL
SELECT
  country, 
  num_search,
  ROUND(sum_zero_result / num_search, 2) AS zero_result_pct
FROM (
  SELECT
    country
    ,SUM(CASE WHEN zero_result_pct IS NOT NULL THEN num_search ELSE NULL END) AS num_search
    ,SUM(num_search * zero_result_pct) AS sum_zero_result
  FROM SearchCategory
  GROUP BY country) AS a;

-- MySQL8
WITH tmp AS (
SELECT
    country
    ,SUM(CASE WHEN zero_result_pct IS NOT NULL THEN num_search ELSE NULL END) AS num_search
    ,SUM(num_search * zero_result_pct) AS sum_zero_result
  FROM SearchCategory
  GROUP BY country
)
SELECT
  country, 
  num_search,
  ROUND(sum_zero_result / num_search, 2) AS zero_result_pct
FROM tmp;