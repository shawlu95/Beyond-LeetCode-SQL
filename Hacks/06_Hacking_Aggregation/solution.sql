-- global aggregate
SELECT Name
FROM country
WHERE GNP >= ALL(SELECT GNP FROM country);

SELECT Name
FROM country
WHERE GNP <= ALL(SELECT GNP FROM country);

SELECT Name
FROM country
WHERE GNP >= (SELECT AVG(GNP) FROM country);

SELECT Name
FROM country
WHERE GNP <= (SELECT AVG(GNP) FROM country);

-- group aggregate
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
