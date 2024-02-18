
WITH average_price AS (
	SELECT
		`year`,
		round (AVG (annual_percentage_increase), 2) AS annual_increase_percent_all_food
		FROM v_annual_percentage_increase_food_price 
		GROUP BY `year`
), 
increase_food_branch AS (
	SELECT 
		ap. `year`,
		ap. annual_increase_percent_all_food,
		vp. annual_percent_increase_all_branch
		FROM average_price ap
		JOIN v_annual_percent_increase_all_branches vp
			ON ap.`year`=  vp.`year`
), 
connection_price_food_gdp AS (
	SELECT 
	 	tsn.country_eu,
	 	tsn.`year`,
	 	tsn.GDP_round,
	 	lag(tsn.GDP_round)OVER(PARTITION BY tsn.country_eu ORDER BY tsn.`year`) AS previous_gdp,
	 	aif.annual_increase_percent_all_food,
	 	aif.annual_percent_increase_all_branch
	FROM t_stepanka_neumannova_project_sql_secondary_final tsn
	LEFT JOIN increase_food_branch aif
		ON tsn.`year`= aif.`year`
		AND tsn.country_eu = 'Czech republic'	
)
SELECT 
	country_eu,
	`year`,
	GDP_round,
	previous_gdp,
	round ((GDP_round - previous_gdp)/previous_gdp*100, 2)  AS increase_gdp,
	annual_increase_percent_all_food,
 	annual_percent_increase_all_branch
FROM connection_price_food_gdp
WHERE 1=1
	AND country_eu = 'Czech republic'
	AND `year` BETWEEN 2006 AND 2018
	AND previous_gdp IS NOT null
ORDER BY `year` ASC;