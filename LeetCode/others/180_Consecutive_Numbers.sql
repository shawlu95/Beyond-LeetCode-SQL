-- analysis
-- three consecutive rows
-- join twice, each time offsetting id by 1
-- filter by equating three columns
-- NULL? use inner join

SELECT 
  DISTINCT n1.Num
FROM Number n1
JOIN Number n2
  ON n2.Id = n1.Id + 1
JOIN Number n3
  ON n3.Id = n2.Id + 1
WHERE n1.Num = n2.Num
  AND n2.Num = n3.Num;

-- n1.1 matches to n2.2
/*
1 1 1
1 1 2
1 2 1
2 1 2
1 2 2
2 2 -
2 -
*/

-- shift in the other direction also works
-- n1.2 matches to n2.1
SELECT 
  DISTINCT n1.Num
FROM Number n1
JOIN Number n2
  ON n2.Id = n1.Id - 1
JOIN Number n3
  ON n3.Id = n2.Id - 1
WHERE n1.Num = n2.Num
  AND n2.Num = n3.Num;

-- can use lead or lag
SELECT DISTINCT Num AS ConsecutiveNums
FROM (
    SELECT
        Num
        ,LAG(Num, 1) OVER (ORDER BY Id) AS next
        ,LAG(Num, 2) OVER (ORDER BY Id) AS next_next
    FROM Logs
) AS three_day_log
WHERE Num = next AND next = next_next;

-- ERROR: Windowed functions can only appear in the SELECT or ORDER BY clauses.
-- SELECT
--     Num
-- FROM Logs
-- WHERE Num = LAG(Num, 1) OVER (ORDER BY Id)
--   AND NUM = LAG(Num, 2) OVER (ORDER BY Id);

/* LAG_id, LAG_num REORDER
1 N 
2 1
3 2
4 3
5 4
6 5
7 6
*/
SELECT
    Id
    ,LAG(Num, 1) OVER (ORDER BY Id) lag_1
FROM Logs 
ORDER BY LAG(Num, 1) OVER (ORDER BY Id); -- NULL FIRST