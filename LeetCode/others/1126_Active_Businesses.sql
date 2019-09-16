with tmp as (
select business_id, occurences, avg(occurences) over (partition by event_type) as average
from Events
)
select business_id
from tmp
where occurences > average
group by business_id
having count(*) > 1
