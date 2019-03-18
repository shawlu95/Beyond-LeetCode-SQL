# Hacking Aggregation

This notebook go through several ways to find maximum (and conversely minimum) without using aggregate function. We'll use the world database.

#### Global Aggregate: Select Country with the Largest GNP
This is easy with a scalar subquery, using *MAX()* function.
```
SELECT Name
FROM country
WHERE GNP = (SELECT MAX(GNP) FROM country);

+---------------+
| Name          |
+---------------+
| United States |
+---------------+
1 row in set (0.00 sec)
```

Without aggregate function, we can hack it by using *ALL*.
```
SELECT Name
FROM country
WHERE GNP >= ALL(SELECT GNP FROM country);

+---------------+
| Name          |
+---------------+
| United States |
+---------------+
1 row in set (0.00 sec)
```

__Warning__: if any country has __NULL__ in the *GNP* column, the query will return an empty set. See [this](https://github.com/shawlu95/Beyond-LeetCode-SQL/tree/master/Hacks/02_NULL_pathology) notebook for more pathological examples of __NULL__ behavior. To prevent such behavior, remove __NULL__ from the set.

```
SELECT Name
FROM country
WHERE GNP >= ALL(SELECT GNP FROM country);
```

Similarly, we can find country with lowest GNP, country whose GNP is above / below average.

```
SELECT Name
FROM country
WHERE GNP <= ALL(SELECT GNP FROM country);

SELECT Name
FROM country
WHERE GNP >= (SELECT AVG(GNP) FROM country);

SELECT Name
FROM country
WHERE GNP <= (SELECT AVG(GNP) FROM country);
```

#### Group Aggregate: Find Largest Country on Each Continent
Here we normally need to group by continent. 
```
SELECT
  Name
  ,Continent
  ,SurfaceArea
FROM country
WHERE (Continent, SurfaceArea) IN (
  SELECT Continent, MAX(SurfaceArea) AS SurfaceArea
  FROM country GROUP BY Continent
);
+--------------------+---------------+-------------+
| Name               | Continent     | SurfaceArea |
+--------------------+---------------+-------------+
| Antarctica         | Antarctica    | 13120000.00 |
| Australia          | Oceania       |  7741220.00 |
| Brazil             | South America |  8547403.00 |
| Canada             | North America |  9970610.00 |
| China              | Asia          |  9572900.00 |
| Russian Federation | Europe        | 17075400.00 |
| Sudan              | Africa        |  2505813.00 |
+--------------------+---------------+-------------+
7 rows in set (0.00 sec)
```

Without using *GROUP BY*, we can simply add a condition on *Continent*, turning the scalar subquery into a __correlated subquery__.
```
SELECT 
  a.Name
  ,a.Continent
  ,a.SurfaceArea
FROM country AS a
WHERE a.SurfaceArea >= ALL(
  SELECT b.SurfaceArea 
  FROM country AS b 
  WHERE a.Continent = b.Continent
);
+--------------------+---------------+-------------+
| Name               | Continent     | SurfaceArea |
+--------------------+---------------+-------------+
| Antarctica         | Antarctica    | 13120000.00 |
| Australia          | Oceania       |  7741220.00 |
| Brazil             | South America |  8547403.00 |
| Canada             | North America |  9970610.00 |
| China              | Asia          |  9572900.00 |
| Russian Federation | Europe        | 17075400.00 |
| Sudan              | Africa        |  2505813.00 |
+--------------------+---------------+-------------+
7 rows in set (0.01 sec)
```

Just as before, we can find country whose surface area is smallest, and whose area is above/below average, comparing to other countries in the same continent.

```
SELECT 
  a.Name
  ,a.Continent
  ,a.SurfaceArea
FROM country AS a
WHERE a.SurfaceArea <= ALL(
  SELECT b.SurfaceArea 
  FROM country AS b 
  WHERE a.Continent = b.Continent
);

SELECT 
  a.Name
  ,a.Continent
  ,a.SurfaceArea
FROM country AS a
WHERE a.SurfaceArea >= ALL(
  SELECT AVG(b.SurfaceArea)
  FROM country AS b 
  WHERE a.Continent = b.Continent
);

SELECT 
  a.Name
  ,a.Continent
  ,a.SurfaceArea
FROM country AS a
WHERE a.SurfaceArea <= ALL(
  SELECT AVG(b.SurfaceArea)
  FROM country AS b 
  WHERE a.Continent = b.Continent
);
```
---
### Parting Thoughts
There are 30 countries whose GNP is above average, and 209 countries who GNP is below average. This is a positively skewed distirbution, whose mean is significantly above median.

