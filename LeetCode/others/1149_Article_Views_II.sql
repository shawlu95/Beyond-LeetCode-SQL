select distinct viewer_id as id
from Views
group by viewer_id, view_date
having count(distinct viewer_id, article_id) > 1
