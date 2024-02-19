
/* 
No1. - creating view
 */
 
CREATE OR REPLACE VIEW v_annual_percent_increase_all_branches AS
	WITH basic_payroll AS (
		SELECT 
			a.*,
			LAG(a.average_payroll_value) OVER (PARTITION BY a.industry_branch_code_final ORDER BY a.`year`) AS previous_payroll
		FROM (
			SELECT 
				DISTINCT final_year AS `year`,
				CONCAT(type_name_payroll,'  ','v',' ',unit_payroll) AS type_payroll,
				industry_branch_code_final,
				branch_name,
				average_payroll_value 
			FROM t_stepanka_neumannova_project_sql_primary_final tsnpspf
			WHERE industry_branch_code_final = 'všechna odvětví'
			ORDER BY industry_branch_code_final
		)a
	)
	SELECT 
		*,
		round ((average_payroll_value - previous_payroll)/previous_payroll*100, 2) AS annual_percent_increase_all_branch
	FROM basic_payroll
	WHERE previous_payroll IS NOT NULL;
	
/* 
No2.- connection of views and final SELECT
 */
	

SELECT 
	cp.`year`,
	cp.annual_percent_increase_all_branch,
	ai.annual_increase_percent_all_food,	
	(ai.annual_increase_percent_all_food - cp.annual_percent_increase_all_branch) AS difference
FROM v_annual_percent_increase_all_branches cp
JOIN (
	SELECT
		`year`,
		round (AVG (annual_percentage_increase), 2) AS annual_increase_percent_all_food
FROM v_annual_percentage_increase_food_price
WHERE price_category <> 2000001
GROUP BY `year`
)ai
	ON cp.`year` = ai.`year`;


	/*
 Additional query - overview of the development of the annual increase for each food item 
 compared to the gross wage
 */

WITH connection_food_branch AS (
	SELECT 
		cp.`year`,
		cp.annual_percent_increase_all_branch,
		fp.price_category,
		fp.name_product,
		fp.price_value_unit,
		fp.annual_percentage_increase
	FROM (
		SELECT
			*
		FROM v_annual_percentage_increase_food_price 
		WHERE price_category <> 2000001
	)fp
	LEFT JOIN v_annual_percent_increase_all_branches cp
		ON cp.`year` = fp.`year`
)
SELECT 
	*,
	(annual_percentage_increase - annual_percent_increase_all_branch) AS difference
FROM connection_food_branch
WHERE (annual_percentage_increase - annual_percent_increase_all_branch)>10
ORDER BY `year` ASC;