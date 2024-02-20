
WITH average_price AS (
	SELECT
		`year`,
		round (AVG (annual_percentage_increase), 2) AS annual_increase_percent_all_food
		FROM v_annual_percentage_increase_food_price 
		WHERE price_category <> 2000001
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
	 	tsn.gdp_round,
	 	LAG(tsn.gdp_round)OVER(PARTITION BY tsn.country_eu ORDER BY tsn.`year`) AS previous_gdp,
	 	aif.annual_increase_percent_all_food,
	 	aif.annual_percent_increase_all_branch
	FROM t_stepanka_neumannova_project_sql_secondary_final tsn
	LEFT JOIN increase_food_branch aif
		ON tsn.`year`= aif.`year`
		AND tsn.country_eu = 'Czech republic'	
)
SELECT 
	`year`,
	-- gdp_round,
	-- previous_gdp,
	round ((gdp_round - previous_gdp)/previous_gdp*100, 2)  AS increase_gdp,
	annual_increase_percent_all_food,
	LEAD(annual_increase_percent_all_food) OVER (ORDER BY `year`)  AS following_year_food,
 	annual_percent_increase_all_branch,
 	LEAD(annual_percent_increase_all_branch) OVER (ORDER BY `year`)  AS following_year_all_branch
FROM connection_price_food_gdp
WHERE 1=1
	AND country_eu = 'Czech republic'
	AND `year` BETWEEN 2006 AND 2018
	AND previous_gdp IS NOT null
ORDER BY `year` ASC;