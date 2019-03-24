
SELECT
  ROUND(SUM(TIV_2016), 2) AS TIV_2016
FROM insurance 
WHERE TIV_2015 IN
(SELECT TIV_2015 
 FROM insurance
 GROUP BY TIV_2015
 HAVING COUNT(*) > 1)
  AND (LAT, LON) NOT IN
(SELECT lat, lon
 FROM insurance
 GROUP BY lat, lon
 HAVING COUNT(*) > 1);

-- use IN is faster than NOT IN
select
round(sum(tiv_2016),2) as tiv_2016
from
insurance
where
tiv_2015 in (select tiv_2015 from insurance group by 1 having count(*) > 2)
and (lat, lon) in (select lat, lon from insurance group by 1, 2 having count(*) = 1)
 

SELECT ROUND(SUM(i1.TIV_2016), 2) AS TIV_2016
FROM insurance i1
WHERE EXISTS (
	SELECT *
	FROM insurance i2
	WHERE i1.PID != i2.PID 
		AND i1.TIV_2015 = i2.TIV_2015)
AND NOT EXISTS(
	SELECT *
	FROM insurance i3
	WHERE i1.PID != i3.PID 
		AND i1.LAT = i3.LAT 
		AND i1.LON = i3.LON);
