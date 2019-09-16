with unordered as (
select top 1 with ties student_id, course_id, grade
from Enrollments
order by rank() over (partition by student_id order by grade desc, course_id)
)
select * from unordered order by student_id
