# 5. Does the level of GDP affect changes in wages and food prices? Or, if GDP increases more significantly in one year, will this be reflected in a more significant increase in food prices or wages in the same or the following year?


WITH gdp_changes AS (
    SELECT 
        year,
        ROUND(GDP, -5) AS GDP,
        ROUND(LAG(GDP) OVER (PARTITION BY country ORDER BY year), -5) AS prev_GDP,
        ROUND(GDP, -5) - ROUND(LAG(GDP) OVER (PARTITION BY country ORDER BY year), -5) AS gdp_change
    FROM t_milan_komurka_project_sql_secondary_final tmkpssf 
    WHERE country = 'Czech Republic' 
)
SELECT year, GDP, prev_GDP, gdp_change
FROM gdp_changes
ORDER BY year DESC;


WITH price_changes AS (
    SELECT 
        year,
        food,
        price,
        LAG(price) OVER (PARTITION BY food ORDER BY year) AS price_prev,
        LEAD(price) OVER (PARTITION BY food ORDER BY year) AS price_next
    FROM t_milan_komurka_project_sql_primary_final tmkpspf 
)
SELECT year, food, price, price_prev, price_next
FROM price_changes
GROUP BY YEAR, food;


# The Pearson correlation for individual monitored items over the years.
WITH price_changes AS (
    SELECT 
        year,
        food,
        price,
        LAG(price) OVER (PARTITION BY food ORDER BY year) AS price_prev,
        LEAD(price) OVER (PARTITION BY food ORDER BY year) AS price_next,
        price - LAG(price) OVER (PARTITION BY food ORDER BY year) AS price_change
    FROM t_milan_komurka_project_sql_primary_final
    WHERE year BETWEEN 2006 AND 2018
),
gdp_changes AS (
    SELECT 
        year,
        ROUND(GDP, -5) AS GDP,
        ROUND(LAG(GDP) OVER (PARTITION BY country ORDER BY year), -5) AS prev_GDP,
        ROUND(GDP, -5) - ROUND(LAG(GDP) OVER (PARTITION BY country ORDER BY year), -5) AS gdp_change
    FROM t_milan_komurka_project_sql_secondary_final 
    WHERE country = 'Czech Republic' 
    AND year BETWEEN 2006 AND 2018
)
SELECT
    g.year AS gdp_year,
    p.year AS price_year,
    g.gdp_change,
    p.food,
    p.price_change,
    ROUND((SUM((g.gdp_change - avg_gdp.avg_gdp_change) * (p.price_change - avg_price.avg_price_change)) / 
    (SQRT(SUM(POW(g.gdp_change - avg_gdp.avg_gdp_change, 2))) * SQRT(SUM(POW(p.price_change - avg_price.avg_price_change, 2))))), 2) AS pearson_correlation
FROM gdp_changes g
LEFT JOIN price_changes p 
    ON g.year = p.year  
    OR (g.year = p.year - 1)  
    OR (g.year = p.year + 1)  
JOIN (
    SELECT food, AVG(price_change) AS avg_price_change
    FROM price_changes
    GROUP BY food
) AS avg_price ON avg_price.food = p.food
JOIN (
    SELECT AVG(gdp_change) AS avg_gdp_change
    FROM gdp_changes
) AS avg_gdp
GROUP BY g.year, p.year, p.food
ORDER BY gdp_change DESC;



# The pearson correlation over the years.
WITH price_changes AS (
    SELECT 
        year,
        food,
        price,
        LAG(price) OVER (PARTITION BY food ORDER BY year) AS price_prev,
        LEAD(price) OVER (PARTITION BY food ORDER BY year) AS price_next,
        price - LAG(price) OVER (PARTITION BY food ORDER BY year) AS price_change
    FROM t_milan_komurka_project_sql_primary_final
),
gdp_changes AS (
    SELECT 
        year,
        ROUND(GDP, -5) AS GDP,
        ROUND(LAG(GDP) OVER (PARTITION BY country ORDER BY year), -5) AS prev_GDP,
        ROUND(GDP, -5) - ROUND(LAG(GDP) OVER (PARTITION BY country ORDER BY year), -5) AS gdp_change
    FROM t_milan_komurka_project_sql_secondary_final 
    WHERE country = 'Czech Republic' 
),
avg_price_changes AS (
    SELECT AVG(price_change) AS avg_price_change
    FROM price_changes
),
avg_gdp_changes AS (
    SELECT AVG(gdp_change) AS avg_gdp_change
    FROM gdp_changes
)
SELECT
    g.year AS year,
    g.gdp_change,
    p.price_change,
    ROUND((SUM((g.gdp_change - avg_gdp.avg_gdp_change) * (p.price_change - avg_price.avg_price_change)) / 
    (SQRT(SUM(POW(g.gdp_change - avg_gdp.avg_gdp_change, 2))) * SQRT(SUM(POW(p.price_change - avg_price.avg_price_change, 2))))), 2) AS pearson_correlation
FROM gdp_changes g
LEFT JOIN price_changes p 
    ON g.year = p.year  
    OR (g.year = p.year - 1)  
    OR (g.year = p.year + 1)  
CROSS JOIN avg_price_changes avg_price 
CROSS JOIN avg_gdp_changes avg_gdp 
GROUP BY g.year
ORDER BY g.year DESC;

# Pearson's correlation shows no connection between changes in GDP and food prices during the observed period.


WITH salary_changes AS (
    SELECT 
        year,
        industry,
        avg_salary,
        LAG(avg_salary) OVER (PARTITION BY industry ORDER BY year) AS salary_prev,
        LEAD(avg_salary) OVER (PARTITION BY industry ORDER BY year) AS salary_next,
        avg_salary - LAG(avg_salary) OVER (PARTITION BY industry ORDER BY year) AS salary_change
    FROM t_milan_komurka_project_sql_primary_final
),
gdp_changes AS (
    SELECT 
        year,
        ROUND(gdp, -5) AS gdp,
        ROUND(LAG(gdp) OVER (PARTITION BY country ORDER BY year), -5) AS prev_gdp,
        ROUND(gdp, -5) - ROUND(LAG(gdp) OVER (PARTITION BY country ORDER BY year), -5) AS gdp_change
    FROM t_milan_komurka_project_sql_secondary_final 
    WHERE country = 'Czech Republic' 
),
avg_salary_changes AS (
    SELECT AVG(salary_change) AS avg_salary_change
    FROM salary_changes
),
avg_gdp_changes AS (
    SELECT AVG(gdp_change) AS avg_gdp_change
    FROM gdp_changes
)
SELECT
    g.year AS year,
    g.gdp_change,
    s.salary_change,
    ROUND((
        SUM((g.gdp_change - avg_gdp.avg_gdp_change) * (s.salary_change - avg_salary.avg_salary_change)) / 
        (SQRT(SUM(POW(g.gdp_change - avg_gdp.avg_gdp_change, 2))) * SQRT(SUM(POW(s.salary_change - avg_salary.avg_salary_change, 2))))
    ), 2) AS pearson_correlation
FROM gdp_changes g
LEFT JOIN salary_changes s 
    ON g.year = s.year  
    OR (g.year = s.year - 1)  
    OR (g.year = s.year + 1)  
CROSS JOIN avg_salary_changes avg_salary 
CROSS JOIN avg_gdp_changes avg_gdp 
WHERE g.gdp_change IS NOT NULL AND s.salary_change IS NOT NULL
GROUP BY g.year
ORDER BY g.year DESC;

# Pearson correlation does not show a relationship between changes in GDP and average wages during the observed period.