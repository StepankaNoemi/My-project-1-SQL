
WITH basic_payroll AS (
	SELECT 
		a.*,
		LAG(a.average_payroll_year) OVER (PARTITION BY a.industry_branch_code_final ORDER BY a.`year`) AS previous_payroll
	FROM (
		SELECT 
			DISTINCT final_year AS `year`,
			CONCAT(type_name_payroll,'  ','v',' ',unit_payroll) AS type_payroll,
			industry_branch_code_final,
			branch_name,
			average_payroll_year 
		FROM t_stepanka_neumannova_project_sql_primary_final tsnpspf
		WHERE industry_branch_code_final = 'all_branches'
		ORDER BY industry_branch_code_final
	)a
),
increase_all_branch AS (
	SELECT 
		*,
		round ((average_payroll_year - previous_payroll)/previous_payroll*100, 2) AS annual_percent_increase_all_branch
	FROM basic_payroll
	WHERE previous_payroll IS NOT NULL 		
)
SELECT 
	cp.`year`,
	cp.annual_percent_increase_all_branch,
	ai.annual_increase_percent_all_food,	
	(cp.annual_percent_increase_all_branch - ai.annual_increase_percent_all_food) AS difference
FROM increase_all_branch cp
JOIN (
	SELECT
		`year`,
		round (AVG (annual_percentage_increase), 2) AS annual_increase_percent_all_food
	FROM v_annual_percentage_increase_food_price 
	GROUP BY `year`
	) ai
	ON cp.`year` = ai.`year`;

		
		
