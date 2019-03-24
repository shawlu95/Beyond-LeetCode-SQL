SELECT 
    Id, Company, Salary
FROM
    (SELECT 
        e.Id,
            e.Salary,
            e.Company,
            IF(@prev = e.Company, @Rank:=@Rank + 1, @Rank:=1) AS rank,
            @prev:=e.Company
    FROM
        Employee e, (SELECT @Rank:=0, @prev:=0) AS temp
    ORDER BY e.Company , e.Salary , e.Id) Ranking
        INNER JOIN
    (SELECT 
        COUNT(*) AS totalcount, Company AS name
    FROM
        Employee e2
    GROUP BY e2.Company) companycount ON companycount.name = Ranking.Company
WHERE
    Rank = FLOOR((totalcount + 1) / 2)
        OR Rank = FLOOR((totalcount + 2) / 2)
;

-- total count even: select two
-- total count odd: select one
WITH ranking AS (
SELECT
  Id
  ,Company
  ,Salary
  ,COUNT(*) OVER (PARTITION BY Company) AS total_count
  ,RANK() OVER (PARTITION BY Company ORDER BY Salary DESC) AS rank 
FROM Employee)
SELECT 
  Id
  ,Company
  ,Salary
FROM ranking
WHERE rank = FLOOR((total_count + 1) / 2)
  OR rank = FLOOR((total_count + 2) / 2);

