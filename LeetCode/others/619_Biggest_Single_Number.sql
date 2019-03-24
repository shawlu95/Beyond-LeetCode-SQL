SELECT
    MAX(num) AS num
FROM (
    SELECT
        num
    FROM number
    GROUP BY num
    HAVING COUNT(*) = 1) AS _;