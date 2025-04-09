# 4. Is there a year in which the year-on-year increase in food prices was significantly higher than wage growth (greater than 10%)?

WITH yearly_changes AS (
    SELECT 
        year,
        AVG(price) AS avg_price,
        AVG(avg_salary) AS avg_salary,
        LAG(AVG(price)) OVER (ORDER BY year) AS prev_price,
        LAG(AVG(avg_salary)) OVER (ORDER BY year) AS prev_salary
    FROM t_milan_komurka_project_sql_primary_final
    GROUP BY year
)
SELECT 
    year,
    ROUND((((avg_price - prev_price) / prev_price) * 100), 2) AS food_price_growth,
    ROUND((((avg_salary - prev_salary) / prev_salary) * 100), 2) AS salary_growth,
    ROUND((((avg_price - prev_price) / prev_price) * 100), 2) - ROUND((((avg_salary - prev_salary) / prev_salary) * 100), 2) AS difference_growth
FROM yearly_changes
WHERE prev_price IS NOT NULL AND prev_salary IS NOT NULL
HAVING difference_growth > 10
ORDER BY difference_growth DESC;

# 4. There is no year where the year-on-year increase in food prices is greater than wage growth of 10% or more. The maximum price increase was 6.52 % in 2013.