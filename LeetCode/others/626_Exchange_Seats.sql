SELECT
  id
  ,CASE
    -- for odd id, match to next row (may be null)
    WHEN id % 2 = 1 THEN (
      -- put scalar value in bracket!
      IFNULL(SELECT student FROM seat s2 WHERE s1.id = s2.id - 1, s1.student)
    )
    -- for even id, match to previous row (not null)
    ELSE (SELECT student FROM seat s3 WHERE s1.id = s3.id + 1)
    END AS student
FROM seat s1;

/*
1 2 abbot
2 1 dories
3 4 doris
4 3 green
5 6 james (missing 5!, need to fix ids)
*/
select 
  case 
    when s.id is null then stg.id-1 
    else stg.id 
  end id
  ,stg.student
from
(
select id+1 id,student
from seat
where id%2=1
union all
select id-1 id,student
from seat
where id%2=0
order by id) stg
left join seat s 
using (id);