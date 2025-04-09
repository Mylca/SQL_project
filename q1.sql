# 1. Are wages increasing in all sectors over the years, or are they decreasing in some?

WITH salary_trend AS (
    SELECT 
        year,
        industry,
        AVG(avg_salary) AS avg_salary,
        LAG(AVG(avg_salary)) OVER (PARTITION BY industry ORDER BY year) AS prev_salary
    FROM t_milan_komurka_project_sql_primary_final
    GROUP BY year, industry
)
SELECT 
    industry,
    COUNT(*) AS count_years,
    SUM(CASE WHEN avg_salary > prev_salary THEN 1 ELSE 0 END) AS salary_growth_years,
    SUM(CASE WHEN avg_salary < prev_salary THEN 1 ELSE 0 END) AS salary_decline_years,
    ROUND((SUM(CASE WHEN avg_salary > prev_salary THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS percent_growth,
    ROUND((SUM(CASE WHEN avg_salary < prev_salary THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS percent_decline
FROM salary_trend
WHERE prev_salary IS NOT NULL
GROUP BY industry
ORDER BY percent_growth DESC;

# The manufacturing industry and health and social care sectors did not show wage decreases in any of the observed years. 

WITH years_of_decline AS (
    SELECT
        year,
        industry,
        avg_salary,
        LAG(avg_salary, 1) OVER (PARTITION BY industry ORDER BY year) AS prev_salary
    FROM t_milan_komurka_project_sql_primary_final tmkpspf 
)
SELECT
    industry,
    year AS year_of_decline,
    avg_salary AS salary_year_of_decline,
    prev_salary AS prev_salary_year_of_decline
FROM
    years_of_decline
WHERE
    avg_salary < prev_salary
    AND prev_salary IS NOT NULL 
ORDER BY
    industry,
    year;

# The year 2013 appears to be a year in which wages decreased in a large number of industries.
# The Mining and quarrying sector shows decreases in the highest number of years (4).
# The Professional, scientific and technical activities, Public administration and defence; compulsory social security, 
# and Accommodation and food service activities sectors showed decreases in two years.
# The Electricity, gas, steam and air conditioning supply sector showed decreases in two years.