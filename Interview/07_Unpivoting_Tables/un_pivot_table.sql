-- un-pivot course_grade table
SELECT 
  name
  ,aux.course
  ,CASE aux.course
  WHEN 'CS106B' THEN CS106B
  WHEN 'CS229' THEN CS229
  WHEN 'CS224N' THEN CS224N
  END AS grade
FROM  course_grade_pivoted,
(
  SELECT 'CS106B' AS course
  UNION ALL
  SELECT 'CS229'
  UNION ALL
  SELECT 'CS224N' year
       ) aux;

-- un-pivot expenses table
SELECT 
  category
  ,aux.month
  ,CASE aux.month
  WHEN 'Jan' THEN Jan
  WHEN 'Feb' THEN Feb
  WHEN 'Mar' THEN Mar
  WHEN 'Apr' THEN Apr
  WHEN 'May' THEN May
  WHEN 'Jun' THEN Jun
  WHEN 'Jul' THEN Jul
  WHEN 'Aug' THEN Aug
  WHEN 'Sep' THEN Sep
  WHEN 'Oct' THEN Oct
  WHEN 'Nov' THEN Nov
  WHEN 'Dec' THEN Dec_
  END AS month
FROM expenses_pivoted,
(
  SELECT 'Jan' AS month
  UNION ALL
  SELECT 'Feb'
  UNION ALL
  SELECT 'Mar'
  UNION ALL
  SELECT 'Apr'
  UNION ALL
  SELECT 'May'
  UNION ALL
  SELECT 'Jun'
  UNION ALL
  SELECT 'Jul'
  UNION ALL
  SELECT 'Aug'
  UNION ALL
  SELECT 'Sep'
  UNION ALL
  SELECT 'Oct'
  UNION ALL
  SELECT 'Nov'
  UNION ALL
  SELECT 'Dec'
       ) AS aux
LIMIT 24;