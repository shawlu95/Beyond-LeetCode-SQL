-- There is a case when people vote for someone who is not in the candidate. 
-- The solution is finding out the winner id from vote and match to candidate. 
-- correct solution
SELECT Name
FROM Candidate
WHERE id = (
	SELECT CandidateID 
	FROM Vote
	GROUP BY CandidateID
	ORDER BY COUNT(*) DESC 
	LIMIT 1);

-- incorrect: return most voted candidate that exists in Candidate
-- if most voted does not exist in Candidate, it is missed (orphaned rows)
SELECT
  c.Name
FROM Candidate AS c
LEFT JOIN Vote AS v
ON c.id = v.CandidateId
GROUP BY c.Name
ORDER BY COUNT(v.id) DESC
LIMIT 1;

-- incorrect: return null if most voted candidate does not exist in Candidate
-- at least show something!
SELECT
  c.Name
FROM Candidate AS c
RIGHT JOIN Vote AS v
ON c.id = v.CandidateId
GROUP BY c.Name
ORDER BY COUNT(v.id) DESC
LIMIT 1;