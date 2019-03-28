# Pivoting Numeric Data

We've seen a LeetCode problem on pivoting *VARCHAR* data [here](https://github.com/shawlu95/Beyond-LeetCode-SQL/tree/master/LeetCode/618_Students_Report_by_Geography). This notebook introduces the more common pivoting method: over *NUMERIC* data.

The trouble with pivoting *VARCHAR* data is that they cannot be aggregated over, and hence their position (row numebr) in the pivoted table must be determined by a *RANK()* function. For *Numeric* data, the process is much easier: 

* Let's call the left most column of the pivoted table as the *index* column, and call the column that gets pivoted to __multiple__ columns *pivoted* column.
* Note that the *cardinality* of the *pivoted* column determines how many more columns get added to the pivoted table. We must add those column one by one, either manually, or using dynamic query (more on that later).


The pivoting process is accomplished in two stages:
1. Adding columns: breaking the *pivoted* column into multiple columns. This can be accomplished using either *CASE* statement or *self join*. In this case, it is unrealistic to do self-join, because the number of rows is much greater than the cardinalities of the *index* and *pivoted* columns multiplied. See thie [notebook](https://github.com/shawlu95/Beyond-LeetCode-SQL/tree/master/Interview/06_Pivoting_Text_Data) for an example of using self-join to pivot data.
2. Aggregation: reduce the number of rows. The number of rows will be __equal__ to the cardinality of the *index* column.

---
### Data
In this example, we'll use real data on how I spent my money. The data are recorded using an iOS app, which conencts to a PHP server on my localhost, which interfaces with MySQL database. The data file contains one Expenses table, with a subset of the columns from the original table, covering one year of transaction data. You can see how I created the table [here](Expenses.sql).

Load the database file [db.sql](db.sql) to localhost MySQL. The *Expenses* table will be created in the Grocery database. 

```bash
mysql < db.sql -uroot -p
```

Here is the schematic and a few rows of the table.
```
mysql> describe expenses;
+----------+---------------+------+-----+---------+-------+
| Field    | Type          | Null | Key | Default | Extra |
+----------+---------------+------+-----+---------+-------+
| category | varchar(14)   | NO   |     |         |       |
| cost     | decimal(12,2) | YES  |     | NULL    |       |
| time     | datetime      | NO   | MUL | NULL    |       |
+----------+---------------+------+-----+---------+-------+
3 rows in set (0.01 sec)

mysql> SELECT * FROM expenses LIMIT 5;
+------------+-------+---------------------+
| category   | cost  | time                |
+------------+-------+---------------------+
| Social     | 19.84 | 2018-01-02 13:30:27 |
| Book       | 83.97 | 2018-01-03 13:30:27 |
| Food       | 11.31 | 2018-01-03 13:30:27 |
| Stationary |  1.20 | 2018-01-03 13:30:27 |
| Food       |  5.05 | 2018-01-03 13:30:27 |
+------------+-------+---------------------+
5 rows in set (0.00 sec)
```

---
## Objective
The unpivoted table contains 1083 rows (1083 records of transactions in year 2018). We want to pivot the table to have *category* as index column, abd the *time* column as *pivoted* column, binned into 12 months. The cardinality of the category column is 25, The cardinality of the *time* column is 12 (12 months). The resulting table will have dimension 25 * 12.

```
mysql> SELECT COUNT(DISTINCT category) FROM expenses;
+--------------------------+
| COUNT(DISTINCT category) |
+--------------------------+
|                       25 |
+--------------------------+
1 row in set (0.00 sec)
```

---
#### Step 1. Adding Columns
Because there are too many rows, let's look at a few of them to get a sense of how it works. I'll take two days' data from November, and two days' data from December.

```
SELECT * FROM Expenses
WHERE time BETWEEN "2018-12-01" AND "2018-12-02"
  OR time BETWEEN "2018-11-01" AND "2018-11-03")

+---------------+-------+---------------------+
| category      | cost  | time                |
+---------------+-------+---------------------+
| Insurance     | 66.82 | 2018-11-02 12:30:27 |
| Automobile    | 45.71 | 2018-11-02 12:30:27 |
| Food          | 18.16 | 2018-12-01 13:30:27 |
| Communication |  6.98 | 2018-12-01 13:30:27 |
| Food          |  1.66 | 2018-12-01 13:30:27 |
| Food          |  5.92 | 2018-12-01 13:30:27 |
| Food          |  6.24 | 2018-12-01 13:30:27 |
| Miscellany    |  0.26 | 2018-12-01 13:30:27 |
+---------------+-------+---------------------+
8 rows in set (0.00 sec)
```

Using __one__ *CASE* statement for __each__ distinct value in the pivoted column ('Nov' and 'Dec' in this case). This creates two columns. For the 'Nov' column, we only want to retain data from November. For 'Dec' column, only retain data from December.

```sql
WITH tmp AS (
SELECT * FROM Expenses
WHERE time BETWEEN "2018-12-01" AND "2018-12-02"
  OR time BETWEEN "2018-11-01" AND "2018-11-03")

SELECT
  category
  ,CASE WHEN EXTRACT(MONTH FROM time) = 12 THEN cost ELSE 0 END AS 'Dec'
  ,CASE WHEN EXTRACT(MONTH FROM time) = 11 THEN cost ELSE 0 END AS 'Nov'
FROM tmp
ORDER BY time;
```
```
+---------------+-------+-------+
| category      | Dec   | Nov   |
+---------------+-------+-------+
| Insurance     |     0 | 66.82 |
| Automobile    |     0 | 45.71 |
| Food          | 18.16 |     0 |
| Communication |  6.98 |     0 |
| Food          |  1.66 |     0 |
| Food          |  5.92 |     0 |
| Food          |  6.24 |     0 |
| Miscellany    |  0.26 |     0 |
+---------------+-------+-------+
8 rows in set (0.00 sec)
``` 

#### Step 2. Aggregation
Now, to calculate the total amount of money spent in each category, we simply aggregate over the category column!

```sql
WITH tmp AS (
SELECT * FROM Expenses
WHERE time BETWEEN "2018-12-01" AND "2018-12-02"
  OR time BETWEEN "2018-11-01" AND "2018-11-03")

SELECT
  category
  ,SUM(CASE WHEN EXTRACT(MONTH FROM time) = 12 THEN cost ELSE 0 END) AS 'Dec'
  ,SUM(CASE WHEN EXTRACT(MONTH FROM time) = 11 THEN cost ELSE 0 END) AS 'Nov'
FROM tmp
GROUP BY category
ORDER BY category;
```
```
+---------------+-------+-------+
| category      | Dec   | Nov   |
+---------------+-------+-------+
| Automobile    |  0.00 | 45.71 |
| Communication |  6.98 |  0.00 |
| Food          | 31.98 |  0.00 |
| Insurance     |  0.00 | 66.82 |
| Miscellany    |  0.26 |  0.00 |
+---------------+-------+-------+
5 rows in set (0.00 sec)

```

---
#### Pivot Full Table
Now we can apply the procedure to all 12 months! Sadly, as shown in the table below, I lost $14224.24 on the stock market when Nasdaq took a nose dive in October 2018.

```sql
SELECT
  category
  ,SUM(CASE WHEN EXTRACT(MONTH FROM time) = 12 THEN cost ELSE 0 END) AS 'Dec'
  ,SUM(CASE WHEN EXTRACT(MONTH FROM time) = 11 THEN cost ELSE 0 END) AS 'Nov'
  ,SUM(CASE WHEN EXTRACT(MONTH FROM time) = 10 THEN cost ELSE 0 END) AS 'Oct'
  ,SUM(CASE WHEN EXTRACT(MONTH FROM time) = 09 THEN cost ELSE 0 END) AS 'Sep'
  ,SUM(CASE WHEN EXTRACT(MONTH FROM time) = 08 THEN cost ELSE 0 END) AS 'Aug'
  ,SUM(CASE WHEN EXTRACT(MONTH FROM time) = 07 THEN cost ELSE 0 END) AS 'Jul'
  ,SUM(CASE WHEN EXTRACT(MONTH FROM time) = 06 THEN cost ELSE 0 END) AS 'Jun'
  ,SUM(CASE WHEN EXTRACT(MONTH FROM time) = 05 THEN cost ELSE 0 END) AS 'May'
  ,SUM(CASE WHEN EXTRACT(MONTH FROM time) = 04 THEN cost ELSE 0 END) AS 'Apr'
  ,SUM(CASE WHEN EXTRACT(MONTH FROM time) = 03 THEN cost ELSE 0 END) AS 'Mar'
  ,SUM(CASE WHEN EXTRACT(MONTH FROM time) = 02 THEN cost ELSE 0 END) AS 'Feb'
  ,SUM(CASE WHEN EXTRACT(MONTH FROM time) = 01 THEN cost ELSE 0 END) AS 'Jan'
FROM Expenses
GROUP BY category
ORDER BY category;
```
```
+----------------+---------+---------+----------+---------+---------+---------+---------+---------+---------+---------+---------+---------+
| category       | Dec     | Nov     | Oct      | Sep     | Aug     | Jul     | Jun     | May     | Apr     | Mar     | Feb     | Jan     |
+----------------+---------+---------+----------+---------+---------+---------+---------+---------+---------+---------+---------+---------+
| Accessory      |    9.83 |    0.00 |    90.80 |   21.38 |    0.00 |    0.00 |  159.31 |  477.91 |  165.19 |  459.42 |  328.35 |    0.00 |
| Automobile     |   59.57 |   94.20 |   347.99 | 1063.32 | 9877.37 |   58.88 |    0.00 |    3.11 |    0.00 |    0.00 |    0.00 |  209.50 |
| Book           |    8.93 |   20.58 |     0.00 |    0.00 |   20.04 |   24.57 |    0.00 |   29.09 |   52.72 |    0.00 |  511.56 |  110.61 |
| Clothes        |    0.00 |  202.03 |     0.00 |    0.00 |  131.19 |   10.36 |  726.79 |  213.45 |  671.34 |   83.73 |   58.76 |   67.16 |
| Communication  |   23.62 |   16.64 |    16.64 |   15.18 | 5956.31 |   15.18 |   15.18 |   19.73 |   15.18 |   45.48 |   15.18 |   18.95 |
| Education      | 4164.96 | 4164.96 |  4158.73 |    0.00 | 2222.32 |  588.82 | 3598.64 | 3598.64 | 3934.81 | 3881.69 | 3815.70 | 3815.70 |
| Electronics    |  630.44 |  223.30 |   424.22 |    0.00 |  114.38 |  171.61 |  239.60 |   64.64 |    0.00 |    7.58 |    0.00 |    0.00 |
| Entertainment  |   25.92 |   42.38 |     0.00 |    0.00 |   29.03 |   22.10 |    0.00 |   10.93 |   32.45 |   47.81 |  139.41 |    5.05 |
| Family         |  104.50 |   22.85 |   126.04 |    0.00 |    0.00 |    1.50 |    0.00 |    0.00 |    0.00 |   64.77 |   20.78 |   63.98 |
| Food           |  330.15 |  572.95 |   299.21 |  220.65 |  153.06 |  157.18 |  227.39 |   84.66 |  130.70 |  278.13 |   93.44 |  414.18 |
| Health         |   44.87 |   35.91 |    40.60 |   71.11 |  586.95 |  159.73 |   87.45 |   64.08 |   81.52 |   64.12 |  307.01 |  139.65 |
| Home           |  101.50 |  106.80 |    18.72 |  109.74 | 1656.58 |  296.79 |  813.37 |   88.71 |    0.00 |  154.45 |   35.39 |   18.12 |
| Housing        |    0.00 | 1264.03 |  1295.14 | 1247.27 | 2571.53 | 2573.26 | 1037.91 | 1037.91 | 1061.77 | 1233.07 | 1233.07 | 1372.74 |
| Insurance      |  150.81 |  150.81 |   150.81 |  150.81 |  251.01 |    0.00 |  526.91 |  526.91 |  526.91 |  558.69 |  558.69 |  771.24 |
| Invest         |  587.29 | 2555.41 | 14224.24 |  731.55 |  768.84 |    0.00 |    0.00 |    0.00 |    0.00 |    0.00 |    0.00 |    0.00 |
| Legal          |    0.00 |    0.00 |     0.00 |    0.00 |    0.00 |    6.24 |   26.92 |    0.00 |  505.45 |    1.81 |    0.00 |    0.00 |
| Miscellany     |    6.48 |   76.25 |    26.61 |    0.00 |    0.26 |    0.00 |  762.15 |  138.07 |    0.00 |   10.12 |    0.00 |   47.61 |
| Pen            |    0.00 |    0.00 |     0.00 |    0.00 |    0.00 |    0.00 |   75.47 |  105.11 |    0.00 |    0.00 |    0.00 |    0.00 |
| Sartorial      |    0.00 |   72.09 |     0.00 |    0.00 |    4.54 |    0.00 |   81.15 |  125.37 |   88.36 |  135.86 |   21.53 |    0.00 |
| Shoes          |  497.89 |    0.00 |     0.00 |    0.00 |    0.00 |    0.00 |  580.91 |    0.00 |   81.09 |    0.00 |    0.00 |   12.79 |
| Social         |   86.14 |  265.27 |   120.58 |  167.03 |  165.50 |   49.41 |  286.32 |  109.33 |  228.65 |  185.25 |   71.38 |  279.38 |
| Software       |  117.37 |   40.73 |    66.60 |   40.73 |   41.83 |  318.07 |   51.68 |   46.48 |   46.48 |   39.24 |   20.24 |   90.08 |
| Stationary     |    0.00 |    0.00 |    14.57 |    4.05 |   25.99 |    0.00 |   84.61 |   17.56 |   20.77 |   29.64 |    3.33 |   13.52 |
| Tax            |   49.49 |    0.00 |     4.72 |    0.46 |  102.29 |   51.91 |  122.77 |   20.19 |   71.93 |   19.17 |    8.15 |    6.07 |
| Transportation | 1694.83 |    0.00 |    14.55 |    0.00 |   81.97 |  248.49 |   86.60 |   89.61 |   45.31 |  303.49 |   14.32 |  148.53 |
+----------------+---------+---------+----------+---------+---------+---------+---------+---------+---------+---------+---------+---------+
25 rows in set (0.00 sec)
```

See solution [here](pivot.sql).