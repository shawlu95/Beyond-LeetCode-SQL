select top 1 with ties project_id
from Project
group by project_id
order by count(*) desc;
