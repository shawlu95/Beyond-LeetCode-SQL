# Full Join

MySQL does not support full join. There are two ways to simulate it.

Load the database file [db.sql](db.sql) to localhost MySQL. Two simple tables will be created in the Practice database. 
```
mysql < db.sql -uroot -p
```

Let's take a look at the tables we want to join. Eveidently, *letter1* table does not contain C; *letter2* table does not contain B.

```
mysql> SELECT * FROM letter1;
+----+--------+
| id | letter |
+----+--------+
|  1 | A      |
|  2 | B      |
|  3 | A      |
+----+--------+
3 rows in set (0.01 sec)

mysql> SELECT * FROM letter2;
+----+--------+
| id | letter |
+----+--------+
|  1 | A      |
|  2 | C      |
|  3 | A      |
+----+--------+
3 rows in set (0.00 sec)
```

---
### Hack
```sql
SELECT 
  l1.id
  ,l1.letter
  ,l2.id
  ,l2.letter 
FROM letter1 l1
LEFT JOIN letter2 l2 ON l1.letter = l2.letter
UNION ALL
SELECT
  l1.id
  ,l1.letter
  ,l2.id
  ,l2.letter 
FROM letter1 l1
RIGHT JOIN letter2 l2 ON l1.letter = l2.letter
WHERE l1.letter IS NULL;
```
```
+------+--------+------+--------+
| id   | letter | id   | letter |
+------+--------+------+--------+
|    1 | A      |    1 | A      |
|    3 | A      |    1 | A      |
|    1 | A      |    3 | A      |
|    3 | A      |    3 | A      |
|    2 | B      | NULL | NULL   |
| NULL | NULL   |    2 | C      |
+------+--------+------+--------+
6 rows in set (0.00 sec)
```

```sql
SELECT 
  l1.id
  ,l1.letter
  ,l2.id
  ,l2.letter 
FROM letter1 l1
RIGHT JOIN letter2 l2 ON l1.letter = l2.letter
UNION ALL
SELECT
  l1.id
  ,l1.letter
  ,l2.id
  ,l2.letter 
FROM letter1 l1
LEFT JOIN letter2 l2 ON l1.letter = l2.letter
WHERE l2.letter IS NULL;
```
```
+------+--------+------+--------+
| id   | letter | id   | letter |
+------+--------+------+--------+
|    1 | A      |    1 | A      |
|    1 | A      |    3 | A      |
|    3 | A      |    1 | A      |
|    3 | A      |    3 | A      |
| NULL | NULL   |    2 | C      |
|    2 | B      | NULL | NULL   |
+------+--------+------+--------+
6 rows in set (0.00 sec)
```

---
### Warning
Do not use *UNION*, which creates a hashset. If the returned rows are not distinct, you get fewer rows than expected!

```sql
SELECT l1.letter, l2.letter
FROM letter1 l1
LEFT JOIN letter2 l2
ON l1.letter=l2.letter
UNION
SELECT l1.letter, l2.letter
FROM letter1 l1
RIGHT JOIN letter2 l2 
ON l1.letter=l2.letter;
```
```
+--------+--------+
| letter | letter |
+--------+--------+
| A      | A      |
| B      | NULL   |
| NULL   | C      |
+--------+--------+
3 rows in set (0.01 sec)
```

The answer should be:
```sql
SELECT l1.letter, l2.letter FROM letter1 l1
LEFT JOIN letter2 l2 ON l1.letter = l2.letter
UNION ALL
SELECT l1.letter, l2.letter FROM letter1 l1
RIGHT JOIN letter2 l2 ON l1.letter = l2.letter
WHERE l1.letter IS NULL;
```
```
+--------+--------+
| letter | letter |
+--------+--------+
| A      | A      |
| A      | A      |
| A      | A      |
| A      | A      |
| B      | NULL   |
| NULL   | C      |
+--------+--------+
6 rows in set (0.00 sec)
```