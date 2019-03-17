DROP PROCEDURE IF EXISTS sample_by_continent;
DELIMITER //
CREATE PROCEDURE sample_by_continent
(IN sample_size INT(11))
BEGIN

	WITH 
	city_group AS 
	  (SELECT
	    c.*
	    ,COUNT(*) OVER (PARTITION BY continent) AS group_size
	  FROM city_by_continent AS c)
	,city_prob_assign AS 
	  (SELECT
	    c.*
	    -- beaware expectation of sample size group_size * sample_size / group_size AS mean = sample_size
	    ,SQRT(group_size * (sample_size / group_size) * (1 - sample_size / group_size)) AS std
	    ,RAND() AS prob
	  FROM city_group AS c)
	,city_prob_cutoff AS 
	  (SELECT
	    c.*
	    ,(sample_size + CEIL(2 * std)) / group_size AS cutoff
	  FROM city_prob_assign AS c)
	-- filter by cuffoff
	-- note that this step cannot be merged with previous
	,city_sample AS 
	  (SELECT 
	    c.*
	    -- window is evaluated after WHERE clause!
	    -- ranking is cheap when performed on small group!
	    ,RANK() OVER (PARTITION BY continent ORDER BY prob) AS group_row_num
	  FROM city_prob_cutoff AS c
	  WHERE prob < cutoff)
	-- final, fixed size sample
	SELECT * 
	FROM city_sample
	WHERE group_row_num <= sample_size;

END//
DELIMITER ;