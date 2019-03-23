-- multi-column partition
SELECT *, ROW_NUMBER() OVER w AS quiz_number
FROM Quiz
WINDOW w AS (PARTITION BY user_id, course ORDER BY quiz_date);

-- multi-column order
SELECT *, ROW_NUMBER() OVER w AS quiz_number
FROM Quiz
WINDOW w AS (PARTITION BY user_id ORDER BY course, quiz_date);
