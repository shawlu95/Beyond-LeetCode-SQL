select top 1 with ties project_id, a.employee_id
from Project a
join Employee b
on a.employee_id = b.employee_id
order by dense_rank() over 
        (partition by project_id order by experience_years desc);
