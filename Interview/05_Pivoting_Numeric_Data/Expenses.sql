CREATE TABLE Expenses AS
SELECT
  CASE type
    WHEN "INV" THEN "Invest"
    WHEN "LOV" THEN "Family"
    WHEN "EDU" THEN "Education"
    WHEN "BOO" THEN "Book"
    WHEN "STA" THEN "Stationary"
    WHEN "PEN" THEN "Pen"
    WHEN "FOO" THEN "Food"
    WHEN "CLO" THEN "Clothes"
    WHEN "SAR" THEN "Sartorial"
    WHEN "SHO" THEN "Shoes"
    WHEN "ACC" THEN "Accessory"
    WHEN "HYG" THEN "Health"
    WHEN "FUR" THEN "Home"
    WHEN "ELE" THEN "Electronics"
    WHEN "COM" THEN "Communication"
    WHEN "SOC" THEN "Social"
    WHEN "TRA" THEN "Transportation"
    WHEN "HOU" THEN "Housing"
    WHEN "AUT" THEN "Automobile"
    WHEN "ENT" THEN "Entertainment"
    WHEN "SOF" THEN "Software"
    WHEN "LEG" THEN "Legal"
    WHEN "TAX" THEN "Tax"
    WHEN "INS" THEN "Insurance"
    WHEN "MIS" THEN "Miscellany"
    ELSE type
  END AS "category"
  ,ROUND(abs(priceCNY) / 6.6, 2) AS "cost"
  ,time
FROM items
WHERE userID LIKE "shaw%"
  AND deleted = 0
  AND time BETWEEN '2018-01-01 00:00:00' AND '2019-01-01 00:00:00';
