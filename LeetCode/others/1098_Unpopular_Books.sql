select b.book_id, b.name
from (select * from Orders where dispatch_date > date_add('2019-06-23', interval -1 year)) a
right join Books b
on a.book_id = b.book_id
where b.available_from < date_add('2019-06-23',interval -1 month)
group by b.book_id, b.name
having coalesce(sum(quantity), 0) < 10
order by b.book_id
