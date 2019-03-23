# Multi-column Partitioning

Just as GROUP BY can be applied to multiple columns, so can we PARTITION BY multiple columns. In the sample quiz [table](db.sql), we have one column for student_id, each student can take multiple classes, each classes can have multiple quizzes. To answer question such as "this is Mike's third quiz in deep learning class," we need to partition by both student_id and course.

Load the table.
```
mysql < db.sql -uroot -p
```

___
### Multiple-column Partition
```
SELECT *, ROW_NUMBER() OVER w AS quiz_number
FROM Quiz
WINDOW w AS (PARTITION BY user_id, course ORDER BY quiz_date);

+----+---------+--------+------------+-------------+
| id | user_id | course | quiz_date  | quiz_number |
+----+---------+--------+------------+-------------+
|  6 | john    | CS230  | 2019-02-01 |           1 |
|  7 | john    | CS230  | 2019-02-12 |           2 |
| 10 | john    | CS246  | 2019-03-06 |           1 |
|  8 | john    | CS246  | 2019-03-09 |           2 |
|  9 | john    | CS246  | 2019-03-29 |           3 |
|  1 | shaw    | CS229  | 2019-02-08 |           1 |
|  2 | shaw    | CS229  | 2019-03-01 |           2 |
|  3 | shaw    | CS230  | 2019-03-04 |           1 |
|  4 | shaw    | CS230  | 2019-03-14 |           2 |
|  5 | shaw    | CS231  | 2019-02-14 |           1 |
+----+---------+--------+------------+-------------+
10 rows in set (0.01 sec)
```

___
### Multiple-column Order
Similarly, we can ORDER BY multiple columns in the window function to break ties. This is useful in resolving edge cases.


```
SELECT *, ROW_NUMBER() OVER w AS quiz_number
FROM Quiz
WINDOW w AS (PARTITION BY user_id ORDER BY course, quiz_date);

+----+---------+--------+------------+-------------+
| id | user_id | course | quiz_date  | quiz_number |
+----+---------+--------+------------+-------------+
|  6 | john    | CS230  | 2019-02-01 |           1 |
|  7 | john    | CS230  | 2019-02-12 |           2 |
| 10 | john    | CS246  | 2019-03-06 |           3 |
|  8 | john    | CS246  | 2019-03-09 |           4 |
|  9 | john    | CS246  | 2019-03-29 |           5 |
|  1 | shaw    | CS229  | 2019-02-08 |           1 |
|  2 | shaw    | CS229  | 2019-03-01 |           2 |
|  3 | shaw    | CS230  | 2019-03-04 |           3 |
|  4 | shaw    | CS230  | 2019-03-14 |           4 |
|  5 | shaw    | CS231  | 2019-02-14 |           5 |
+----+---------+--------+------------+-------------+
10 rows in set (0.00 sec)
```

