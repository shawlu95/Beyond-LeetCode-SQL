# Bad Subquery
This notebook goes through several common types of bad subqueries. Subqueries are not always bad, and sometimes cannot be avoided. But they are often misused because analysts are too lazy to even think about why they need it.

### Not Using Having Clause
We want to select countries with more than 100 cities.

```sql
SELECT CountryCode, city_tally
FROM (
  SELECT
    CountryCode
    ,COUNT(*) AS city_tally
  FROM city
  GROUP BY CountryCode
) AS _
WHERE city_tally >= 100
ORDER BY city_tally DESC;
```
```
+-------------+------------+
| CountryCode | city_tally |
+-------------+------------+
| CHN         |        363 |
| IND         |        341 |
| USA         |        274 |
| BRA         |        250 |
| JPN         |        248 |
| RUS         |        189 |
| MEX         |        173 |
| PHL         |        136 |
+-------------+------------+
8 rows in set (0.00 sec)
```

The subquery can be avoided by moving the *WHERE* clause into the *HAVING* clause.

```sql
SELECT
  CountryCode
  ,COUNT(*) AS city_tally
FROM city
GROUP BY CountryCode
HAVING city_tally >= 100
ORDER BY city_tally DESC;
```
```
+-------------+------------+
| CountryCode | city_tally |
+-------------+------------+
| CHN         |        363 |
| IND         |        341 |
| USA         |        274 |
| BRA         |        250 |
| JPN         |        248 |
| RUS         |        189 |
| MEX         |        173 |
| PHL         |        136 |
+-------------+------------+
8 rows in set (0.00 sec)
```

If you don't need to return the city count, you can move the entire expression into *HAVING* clause.

```sql
SELECT
  CountryCode
FROM city
GROUP BY CountryCode
HAVING COUNT(*) >= 100;
```
```
+-------------+
| CountryCode |
+-------------+
| BRA         |
| CHN         |
| IND         |
| JPN         |
| MEX         |
| PHL         |
| RUS         |
| USA         |
+-------------+
8 rows in set (0.01 sec)
```