UPDATE salary
SET sex = CASE WHEN sex = "m" THEN "f"
                WHEN sex = "f" THEN "m"
                ELSE NULL 
                END;
                
UPDATE salary
SET sex = CASE WHEN sex = "m" THEN "f"
                WHEN sex = "f" THEN "m"
                END
WHERE sex IS NOT NULL;