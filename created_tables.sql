# The intersection of the food price and average wage tables exists only in the years 2006–2018
# t_Milan_Komurka_project_SQL_primary_final

CREATE OR REPLACE TABLE t_milan_komurka_project_sql_primary_final AS
SELECT 
	cp.payroll_year AS year,
	czpc.code,
	czpc.name AS food,
	czpc.price_value, 
	czpc.price_unit,
	ROUND(AVG(cpr.value), 0) AS price,
	cpu.name AS currency,
	cpib.name AS industry,	
	ROUND(AVG(cp.value), -2) AS avg_salary,
	cpu.name AS _currency
FROM czechia_payroll cp
JOIN czechia_payroll_unit cpu 
	ON cp.unit_code = cpu.code
	AND cpu.code = 200
JOIN czechia_payroll_industry_branch cpib 
	ON cp.industry_branch_code = cpib.code
JOIN czechia_price cpr
	ON YEAR(cpr.date_from) = cp.payroll_year
	AND cp.value_type_code = 5958
RIGHT JOIN czechia_price_category czpc 
	ON cpr.category_code = czpc.code
	AND cp.payroll_year BETWEEN 2006 AND 2018
	AND czpc.code IS NOT NULL
GROUP BY YEAR, food, industry
ORDER BY YEAR, industry, food;


# t_Milan_Komurka_project_SQL_secondary_final
# ~ 21 % of values missing in gini column

CREATE OR REPLACE TABLE t_milan_komurka_project_sql_secondary_final AS
SELECT 
	c.country,
	e.year,
	e.population,
	e.gini,
	e.GDP
FROM countries c
JOIN economies e ON e.country = c.country
WHERE c.continent = 'Europe'
	AND e.year BETWEEN 2006 AND 2018
ORDER BY c.country, e.year;