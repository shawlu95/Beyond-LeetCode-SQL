# Failure to Use Index

In this notebook we use *sakila* database. Specifically, we want to count how many movies each actor has starred. We obviously need to group by the first name and last name of the actor.

```sql
SELECT actor.first_name, actor.last_name, COUNT(*)
FROM sakila.film_actor
INNER JOIN sakila.actor USING(actor_id)
GROUP BY actor.first_name, actor.last_name
ORDER BY 1, 2
LIMIT 5;
```
```
+------------+-----------+----------+
| first_name | last_name | COUNT(*) |
+------------+-----------+----------+
| ADAM       | GRANT     |       18 |
| ADAM       | HOPPER    |       22 |
| AL         | GARLAND   |       26 |
| ALAN       | DREYFUSS  |       27 |
| ALBERT     | JOHANSSON |       33 |
+------------+-----------+----------+
5 rows in set (0.01 sec)
```

But we can do much better by grouping by index. Notice that index uniquely identifies an actor, just as first name and last name uniquely identify an actor.

```sql
SELECT actor.first_name, actor.last_name, COUNT(*)
FROM sakila.film_actor
INNER JOIN sakila.actor USING(actor_id)
GROUP BY film_actor.actor_id
ORDER BY 1, 2
LIMIT 5;
```
```
+------------+-----------+----------+
| first_name | last_name | COUNT(*) |
+------------+-----------+----------+
| ADAM       | GRANT     |       18 |
| ADAM       | HOPPER    |       22 |
| AL         | GARLAND   |       26 |
| ALAN       | DREYFUSS  |       27 |
| ALBERT     | JOHANSSON |       33 |
+------------+-----------+----------+
5 rows in set (0.00 sec)
```

You may notice that the first two columns are neither in the GROUP BY clause nor aggregated over. This does not throw an error in MySQL, because it recognizes they are functionally dependent on the GROUP BY column.

The most correct version is to do one of the following:

```sql
SELECT MAX(actor.first_name), MAX(actor.last_name), COUNT(*)
FROM sakila.film_actor
INNER JOIN sakila.actor USING(actor_id)
GROUP BY film_actor.actor_id
ORDER BY 1, 2
LIMIT 5;

SELECT actor.first_name, actor.last_name, COUNT(*)
FROM sakila.film_actor
INNER JOIN sakila.actor USING(actor_id)
GROUP BY film_actor.actor_id, 1, 2
ORDER BY 1, 2
LIMIT 5;

SELECT actor.first_name, actor.last_name, c.cnt FROM sakila.actor
INNER JOIN (
  SELECT actor_id, COUNT(*) AS cnt FROM sakila.film_actor
  GROUP BY actor_id
) AS c USING(actor_id)
ORDER BY 1, 2
LIMIT 5;
```

In the last case, be careful that temporary table does not have index, and the *INNER* join could be slow.