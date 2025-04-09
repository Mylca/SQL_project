# 3. Which food category is increasing in price the slowest (has the lowest percentage year-on-year increase)?

WITH price_changes AS (
    SELECT 
        food,
        year,
        price,
        LAG(price) OVER (PARTITION BY food ORDER BY year) AS previous_price
    FROM t_milan_komurka_project_sql_primary_final
)
SELECT 
    food,
    ROUND(AVG((price - previous_price) / previous_price * 100), 3) AS avg_annual_growth_perc
FROM price_changes
WHERE previous_price IS NOT NULL
GROUP BY food
ORDER BY avg_annual_growth_perc ASC
LIMIT 1;


# 3. The lowest percentage increase was not for any food, even a decrease was recorded for granulated sugar of 0.095 %.