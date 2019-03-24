-- do not use sub-clause or IN clause
-- it does not work when something is deleted
DELETE p2.*
FROM Person p1
JOIN Person p2
ON p1.Email = p2.Email
WHERE p1.Id < p2.Id;


# DELETE p1 
# FROM Person p1,
#     Person p2
# WHERE
#     p1.Email = p2.Email 
#     AND p1.Id > p2.Id;