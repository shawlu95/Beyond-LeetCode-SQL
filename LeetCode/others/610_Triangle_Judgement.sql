# Write your MySQL query statement below
# let a > b > c
# 1. c + b > a
# 2. a - c < b (equivalent as above)

SELECT x, y, z,
    CASE
        WHEN x + y < z OR x + z < y OR y + z < x THEN 'No'
        ELSE 'Yes'
    END
    AS 'triangle'
    FROM triangle t;