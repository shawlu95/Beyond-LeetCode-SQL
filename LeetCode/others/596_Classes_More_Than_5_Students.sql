# ask if there is duplicate student in class
-- if so, use DISTINCT
SELECT
  class 
FROM courses
GROUP BY class
HAVING COUNT(DISTINCT student) >= 5;