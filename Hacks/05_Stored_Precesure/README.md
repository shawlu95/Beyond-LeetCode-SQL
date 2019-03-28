# Stored Precesure

---
### Building Procedure
For complex queries that are frequently reused, with a few changes in parameters, we can store it as a procedure, and run it like a function. The syntax to create stored procedure is:

```sql
DROP PROCEDURE IF EXISTS my_procedure;

DELIMITER //
CREATE PROCEDURE my_procedure
(IN arg1 INT(11), arg2 VARCHAR(10))

BEGIN

SELECT arg1, arg2;

END//
DELIMITER ;
```

The *DELIMITER //* statement simply tells SQL to treat *//* as marking the end of statement, so that when creating the procedure *SELECT arg1, arg2;*, SQL does not interpret it as a statement and execute it. After creating the procedure, we need to change back the delimiter to *;*.

---
### Calling Procedure
To call a procesure, simply substitute parameters.
```
CALL my_procedure(1, 'hello');

+------+-------+
| arg1 | arg2  |
+------+-------+
|    1 | hello |
+------+-------+
1 row in set (0.00 sec)
```

---
### Example Use Case
We can use custom procedure to store the random sampling [query](https://github.com/shawlu95/Beyond-LeetCode-SQL/tree/master/Topics/01_Random_Sampling). See implementation [here](stored_procedure.sql).

Using stored procesure, we can simly sample any desired number of rows we want, by passing sample size as an argument. For example, to draw 3 cities from each continent, we can simply call the procedure as follows:

```
mysql> CALL sample_by_continent(3);

+--------------+---------------------------+---------------+------------+--------------------+-----------------------+--------+---------------+
| city_name    | country_name              | continent     | group_size | std                | prob                  | cutoff | group_row_num |
+--------------+---------------------------+---------------+------------+--------------------+-----------------------+--------+---------------+
| Nazilli      | Turkey                    | Asia          |       1766 | 1.7305788923769574 |    0.7224973214068425 | 0.0040 |             1 |
| Semnan       | Iran                      | Asia          |       1766 | 1.7305788923769574 |    0.7094183831563391 | 0.0040 |             2 |
| Yuci         | China                     | Asia          |       1766 | 1.7305788923769574 |    0.3795999822948128 | 0.0040 |             3 |
| Manchester   | United Kingdom            | Europe        |        841 | 1.7289585538059709 |    0.7099240475426652 | 0.0083 |             1 |
| Vitebsk      | Belarus                   | Europe        |        841 | 1.7289585538059709 |   0.24038589023089585 | 0.0083 |             2 |
| Arzamas      | Russian Federation        | Europe        |        841 | 1.7289585538059709 |   0.07215733926012864 | 0.0083 |             3 |
| Saint-Pierre | Saint Pierre and Miquelon | North America |        581 | 1.7275732570756073 |    0.9816732946612623 | 0.0120 |             1 |
| Compton      | United States             | North America |        581 | 1.7275732570756073 |    0.9894793350151547 | 0.0120 |             2 |
| Grand Rapids | United States             | North America |        581 | 1.7275732570756073 | 0.0023768218256317282 | 0.0120 |             3 |
| al-Qadarif   | Sudan                     | Africa        |        366 | 1.7249376000117878 |    0.6935911212988115 | 0.0191 |             1 |
| Daloa        | Côte d’Ivoire             | Africa        |        366 | 1.7249376000117878 |   0.06386513827728586 | 0.0191 |             2 |
| Abidjan      | Côte d’Ivoire             | Africa        |        366 | 1.7249376000117878 |   0.23855235822363977 | 0.0191 |             3 |
| Adamstown    | Pitcairn                  | Oceania       |         55 |  1.684150708706428 |    0.2901749911626568 | 0.1273 |             1 |
| Yangor       | Nauru                     | Oceania       |         55 |  1.684150708706428 |   0.44737576548697033 | 0.1273 |             2 |
| Cairns       | Australia                 | Oceania       |         55 |  1.684150708706428 |    0.3663538846805262 | 0.1273 |             3 |
| Maracaíbo    | Venezuela                 | South America |        470 | 1.7265140393782532 |    0.8527891355126995 | 0.0149 |             1 |
| Guacara      | Venezuela                 | South America |        470 | 1.7265140393782532 |    0.2539973559360927 | 0.0149 |             2 |
| Corrientes   | Argentina                 | South America |        470 | 1.7265140393782532 |    0.7116194038760097 | 0.0149 |             3 |
+--------------+---------------------------+---------------+------------+--------------------+-----------------------+--------+---------------+
18 rows in set (0.01 sec)

Query OK, 0 rows affected (0.01 sec)
```

