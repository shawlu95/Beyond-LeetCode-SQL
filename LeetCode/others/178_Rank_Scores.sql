-- MS SQL
SELECT 
    Score
    ,DENSE_RANK() over (ORDER BY Score DESC) AS Rank
FROM scores
ORDER BY Score DESC;

-- MYSQL
SELECT Scores.Score, Rank
FROM Scores 
Left join (Select Score, @Rank:=@Rank+1 as Rank
        From (Select Distinct Score From Scores Order by Score DESC) S1, (Select @Rank:=0) var) S2 on Scores.Score=S2.Score
order by Scores.Score desc
