


WITH basic AS (
	SELECT 
		*,
		LAG(average_price_year) OVER (PARTITION BY price_category ORDER BY b.`year`) AS previous_avg_price
	FROM (
		SELECT 
			DISTINCT final_year AS `year`,
			price_category,
			name_product,
			price_value_unit,
			average_price_year 
		FROM t_stepanka_neumannova_project_sql_primary_final tsnpspf 
		ORDER BY name_product ASC,
			`year` ASC 	
	) b
	WHERE price_category <> '212101'
),
calculation AS (
	SELECT 
  		*,
  		round ((average_price_year  - previous_avg_price)/previous_avg_price*100, 2) AS annual_percentage_increase
  	FROM basic
  	WHERE previous_avg_price IS NOT NULL 
 )
-- SELECT 
	-- `year`,
	-- name_product,
	-- annual_percentage_increase
-- FROM calculation
SELECT 
	name_product,
 	round (AVG (annual_percentage_increase), 2) AS avg_annual_percent_increase
FROM calculation
GROUP BY name_product
ORDER BY avg_annual_percent_increase ASC
LIMIT 1 ;

