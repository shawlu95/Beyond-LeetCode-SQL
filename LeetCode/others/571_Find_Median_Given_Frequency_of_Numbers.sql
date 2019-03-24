
SELECT 
  AVG(T1.Number) as median
FROM 
  (
    SELECT 
      Number, 
      @cum_freq AS lb, 
      (@cum_freq:=@cum_freq + Frequency) AS ub
    FROM Numbers, (SELECT @cum_freq:=0) init
    ORDER BY Number
  ) AS T1,
   (
    SELECT 
      SUM(Frequency) AS total_freq
    FROM Numbers
   ) AS T2
WHERE T1.lb < CEIL(T2.total_freq/2) 
  AND T1.ub >= CEIL(T2.total_freq/2)
  
/*      u l
1 NULL  1 0
2 1     3 1
1 2     4 3
4 1     8 4

If N is even: select avg(N/2, N/2 + 1)
If b is first occuring at frequency N/2 + 1, it has low bound N/2, upper bound doesn't matter
If c is last occuring at N/2, it has upper bound N/2, lower bound doesn't matter

If N is odd, select CEIL(N/2), lb < CEIL(N/2) <= ub

Not that lb cannot include CEIL(N/2), because it means previous number's range includes median

To share equal sign with even case, remove CEIL, lb <= N/2 <= CEIL(N/2), in odd case, lb <= N/2 < CEIL(N/2), lb can be as large as FLOOR(N/2)
*/
WITH lag AS (
  SELECT 
    Number
    ,Frequency AS cur
    ,LAG(Frequency, 1) OVER (ORDER BY Number) AS prev
  FROM Numbers
)
,bound AS (
  SELECT
    Number
    ,Frequency
    ,SUM(prev) OVER (ORDER BY Number) AS lb
    ,SUM(cur) OVER (ORDER BY Number) AS up
    ,SUM(Frequency) OVER () AS total
  FROM lag
)
SELECT
  AVG(Number) AS median
FROM bound
WHERE lb < CEIL(total / 2)
  AND up >= CEIL(total / 2)