
WITH basic_table AS (
	SELECT 
		a.*,
		LAG(a.average_payroll_year) OVER (PARTITION BY a.industry_branch_code_final ORDER BY a.`year`) AS previous_payroll
	FROM (
		SELECT 
			DISTINCT final_year AS `year`,
			type_name_payroll,
			unit_payroll,
			industry_branch_code_final,
			branch_name,
			average_payroll_year 
		FROM t_stepanka_neumannova_project_sql_primary_final tsnpspf
		WHERE industry_branch_code_final <> 'all_branches'
		ORDER BY industry_branch_code_final
	)a
),
calculation_table AS (
	SELECT 
		*,
		round ((average_payroll_year - previous_payroll)/previous_payroll*100, 2) AS annual_percentage_increase
	FROM basic_table
	WHERE previous_payroll IS NOT NULL 
)
SELECT 
	`year`,
	CONCAT(type_name_payroll,'  ','v',' ',unit_payroll) AS type_payroll,
	industry_branch_code_final,
	branch_name,
	-- average_payroll_year,
	-- previous_payroll,
	annual_percentage_increase
FROM calculation_table
WHERE industry_branch_code_final NOT IN (
	SELECT 
		industry_branch_code_final
	FROM calculation_table
	WHERE annual_percentage_increase <0
	);
