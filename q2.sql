# 2. How many liters of milk and kilograms of bread can be purchased for the first and last comparable periods in the available price and wage data?

SELECT 
	year, 
	ROUND(AVG(avg_salary), 0) AS avg_salary,
	currency AS _currency,
	food,
	price,
	currency,
	ROUND(AVG(t.avg_salary) / price) AS purchase_quantity,
	price_unit
FROM t_Milan_Komurka_project_SQL_primary_final  
WHERE 
	year IN (2006, 2018)
	AND code IN (111301, 114201)
GROUP BY YEAR, food;

# 2. In first year there is a possibility of purchase 1482 liters of milk and 1297 kilograms of bread
# 2. In last year there is a possibility of purchase 1627 liters of milk and 1356 kilograms of bread