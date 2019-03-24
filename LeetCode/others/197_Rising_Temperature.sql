# 1 matches 2
# Id matches to date
SELECT
  w1.Id
FROM Weather w1
JOIN Weather w2
  ON w1.Id = w2.Id - 1
WHERE w1.Temperature < w2.Temperature;

# trap: ask for clarification! 
# whether 1 day maps to 1 record!
# whether every day has record!
# DATEDIFF(later date, earlier date)

SELECT w2.Id
FROM Weather w1
JOIN Weather w2
ON DATEDIFF(w2.RecordDate, w1.RecordDate) = 1
AND w2.Temperature > w1.Temperature;

# no function in ON clause, check query plan
SELECT w2.Id
FROM Weather w1, Weather w2
WHERE DATEDIFF(w2.RecordDate, w1.RecordDate) = 1
  AND w2.Temperature > w1.Temperature;