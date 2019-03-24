SELECT question_id AS survey_log
FROM (
  SELECT
    question_id
    ,SUM(action="answer") / SUM(action="show") AS ans_rate
  FROM survey_log
  GROUP BY question_id
  ORDER BY ans_rate DESC
  LIMIT 1
) AS _;