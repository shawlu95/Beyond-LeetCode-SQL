-- Step 1. Update existing advertiser
UPDATE Advertiser AS a
LEFT JOIN DailyPay AS d
  ON a.user_id = d.user_id
SET a.status = CASE 
  WHEN d.paid IS NULL THEN "CHURN" 
  WHEN a.status = "CHURN" AND d.paid IS NOT NULL THEN "RESURRECT"
  WHEN a.status != "CHURN" AND d.paid IS NOT NULL THEN "EXISTING"
  END;

-- Step 2. Insert new advertiser
INSERT INTO 
Advertiser (user_id, status)
SELECT d.user_id
  ,"NEW" as status
FROM DailyPay AS d
LEFT JOIN Advertiser AS a
  ON d.user_id = a.user_id
WHERE a.user_id IS NULL;