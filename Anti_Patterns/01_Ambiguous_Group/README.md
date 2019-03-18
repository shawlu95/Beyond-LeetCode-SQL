# Selecting Non-aggregated Columns

In a query with GROUP BY clause, you cannot select columns that are neither in the GROUP BY clause, nor aggregated over.

This notebook uses the *world* sample database. Suppose the task is to find the name, code, continent and population of the largest countries (highest population) on each continent. First we find the largest population for each continent:
```
SELECT
  a.Continent
  ,MAX(a.Population)
FROM country AS a
GROUP BY a.Continent;

+---------------+-------------------+
| Continent     | MAX(a.Population) |
+---------------+-------------------+
| North America |         278357000 |
| Asia          |        1277558000 |
| Africa        |         111506000 |
| Europe        |         146934000 |
| South America |         170115000 |
| Oceania       |          18886000 |
| Antarctica    |                 0 |
+---------------+-------------------+
7 rows in set (0.00 sec)
```

---
### Anti-Pattern
Next, we need to select columns. The naive wrong way is to do:

```
SELECT
  a.Continent
  ,a.Code
  ,a.Continent
  ,MAX(a.Population)
FROM country AS a
GROUP BY a.Continent;

ERROR 1055 (42000): Expression #2 of SELECT list is not in GROUP BY clause and contains nonaggregated column 'world.a.Code' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by
```

---
### The Right Way


```
SELECT
  Name
  ,Code
  ,Continent
  ,Population
FROM country
WHERE (Continent, Population) IN (
  SELECT
    a.Continent
    ,MAX(a.Population) AS Population
  FROM country AS a 
  GROUP BY a.Continent
);

+----------------------------------------------+------+---------------+------------+
| Name                                         | Code | Continent     | Population |
+----------------------------------------------+------+---------------+------------+
| Antarctica                                   | ATA  | Antarctica    |          0 |
| French Southern territories                  | ATF  | Antarctica    |          0 |
| Australia                                    | AUS  | Oceania       |   18886000 |
| Brazil                                       | BRA  | South America |  170115000 |
| Bouvet Island                                | BVT  | Antarctica    |          0 |
| China                                        | CHN  | Asia          | 1277558000 |
| Heard Island and McDonald Islands            | HMD  | Antarctica    |          0 |
| Nigeria                                      | NGA  | Africa        |  111506000 |
| Russian Federation                           | RUS  | Europe        |  146934000 |
| South Georgia and the South Sandwich Islands | SGS  | Antarctica    |          0 |
| United States                                | USA  | North America |  278357000 |
+----------------------------------------------+------+---------------+------------+
11 rows in set (0.00 sec)
```

The above query is equivalent to using two quality conditions.
```
SELECT
  a.Name
  ,a.Code
  ,a.Continent
  ,a.Population
FROM country AS a
JOIN (
  SELECT
    a.Continent
    ,MAX(a.Population) AS Population
  FROM country AS a 
  GROUP BY a.Continent
) AS b
ON a.Continent = b.Continent
AND a.Population = b.Population;

+----------------------------------------------+------+---------------+------------+
| Name                                         | Code | Continent     | Population |
+----------------------------------------------+------+---------------+------------+
| Antarctica                                   | ATA  | Antarctica    |          0 |
| French Southern territories                  | ATF  | Antarctica    |          0 |
| Australia                                    | AUS  | Oceania       |   18886000 |
| Brazil                                       | BRA  | South America |  170115000 |
| Bouvet Island                                | BVT  | Antarctica    |          0 |
| China                                        | CHN  | Asia          | 1277558000 |
| Heard Island and McDonald Islands            | HMD  | Antarctica    |          0 |
| Nigeria                                      | NGA  | Africa        |  111506000 |
| Russian Federation                           | RUS  | Europe        |  146934000 |
| South Georgia and the South Sandwich Islands | SGS  | Antarctica    |          0 |
| United States                                | USA  | North America |  278357000 |
+----------------------------------------------+------+---------------+------------+
11 rows in set (0.00 sec)
```

___
### Wrong Fix
The wrong way to fix is simply adding all columns to the GROUP BY clause. This only works if the selected columns __do not__ change the group memberships. In this example, it clearly does.
```
SELECT
  a.Name
  ,a.Code
  ,a.Continent
  ,MAX(a.Population)
FROM country AS a
GROUP BY 1, 2, 3;
```

When does this work? Only if the added columns to the GROUP BY clause are __functionally dependent__ on the original columns in the GROUP BY clause. For example, we want to find largest cities in each country. We are grouping the table by the *Code* column, equivalently, we can also group by *Name*, *Region*, any column from the country table! Because we are uniquely identifying a row in the country table, adding more columns does not make the group by clause __stricter__.

```
SELECT
  c.Code
  ,c.Name
  ,c.Region
  ,MAX(A.Population)
FROM city AS a
JOIN country AS c
ON a.CountryCode = c.Code
GROUP BY 1, 2, 3
ORDER BY c.Code
LIMIT 5;

+------+-------------+---------------------------+-------------------+
| Code | Name        | Region                    | MAX(A.Population) |
+------+-------------+---------------------------+-------------------+
| ABW  | Aruba       | Caribbean                 |             29034 |
| AFG  | Afghanistan | Southern and Central Asia |           1780000 |
| AGO  | Angola      | Central Africa            |           2022000 |
| AIA  | Anguilla    | Caribbean                 |               961 |
| ALB  | Albania     | Southern Europe           |            270000 |
+------+-------------+---------------------------+-------------------+
5 rows in set (0.01 sec)

```

Applying aggregate functions to functionally dependent columns also fixes the bug. Because each group has a unique value in functionally dependent column, it doesn't matter whether you apply *MAX()* or *MIN()*
```
SELECT
  c.Code
  ,MAX(c.Name)
  ,MAX(c.Region)
  ,MAX(A.Population)
FROM city AS a
JOIN country AS c
ON a.CountryCode = c.Code
GROUP BY c.Code
ORDER BY c.Code
LIMIT 5;

+------+-------------+---------------------------+-------------------+
| Code | MAX(c.Name) | MAX(c.Region)             | MAX(A.Population) |
+------+-------------+---------------------------+-------------------+
| ABW  | Aruba       | Caribbean                 |             29034 |
| AFG  | Afghanistan | Southern and Central Asia |           1780000 |
| AGO  | Angola      | Central Africa            |           2022000 |
| AIA  | Anguilla    | Caribbean                 |               961 |
| ALB  | Albania     | Southern Europe           |            270000 |
+------+-------------+---------------------------+-------------------+
5 rows in set (0.00 sec)

```

---
### Exception
__Note__: MySQL recognizes when the query tries to select columns that are functionally dependent on the GROUP BY column. It will not throw error or warning. This is not the case with other SQL server.
```
SELECT
  c.Code
  ,c.Name
  ,c.Region
  ,MAX(A.Population)
FROM city AS a
JOIN country AS c
ON a.CountryCode = c.Code
GROUP BY c.Code
ORDER BY c.Code
LIMIT 5;

+------+-------------+---------------------------+-------------------+
| Code | Name        | Region                    | MAX(A.Population) |
+------+-------------+---------------------------+-------------------+
| ABW  | Aruba       | Caribbean                 |             29034 |
| AFG  | Afghanistan | Southern and Central Asia |           1780000 |
| AGO  | Angola      | Central Africa            |           2022000 |
| AIA  | Anguilla    | Caribbean                 |               961 |
| ALB  | Albania     | Southern Europe           |            270000 |
+------+-------------+---------------------------+-------------------+
5 rows in set (0.00 sec)
```

When using a scalar query, you don't need to worry about functional dependency. The subquery returns a list of scalars.
```
SELECT
  a.Name
  ,a.Code
  ,a.Continent
  ,a.Region
FROM country AS a
WHERE a.Population = (SELECT MAX(Population) FROM country);

+-------+------+-----------+--------------+
| Name  | Code | Continent | Region       |
+-------+------+-----------+--------------+
| China | CHN  | Asia      | Eastern Asia |
+-------+------+-----------+--------------+
1 row in set (0.00 sec)
```