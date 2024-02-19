
SELECT
	final_year,
	type_name_payroll,
	average_payroll_value,
	name_product,
	price_value_unit,
	average_price_year,
	CONCAT (round((average_payroll_value/average_price_year), 2),'  ', (substring(price_value_unit,2))) AS amount_for_salary
FROM t_stepanka_neumannova_project_sql_primary_final tsnpspf  
WHERE 1=1
	AND industry_branch_code_final = 'všechna odvětví'
	AND price_category IN (111301,114201)
	AND final_year IN (2006, 2018)
ORDER BY name_product ASC;



/* 
supplementary query - calculation to explain the evolution of wages and prices, 
which affects the amount of food for the average gross wage of the selected year
 */

SELECT 
	final_year,
	type_name_payroll,
	average_payroll_value,
	round((salary_2018-average_payroll_value)/average_payroll_value*100, 2) AS increase_percent_payroll,
	name_product,
	price_value_unit,
	average_price_year,
	round((price_2018-average_price_year)/average_price_year*100, 2) AS increase_percent_price,
	amount_for_salary
FROM (
	SELECT
		final_year,
		type_name_payroll,
		industry_branch_code_final,
		average_payroll_value,
		LEAD(average_payroll_value) OVER (PARTITION BY name_product ORDER BY final_year) AS salary_2018,
		name_product,
		price_value_unit,
		average_price_year,
		LEAD(average_price_year) OVER (PARTITION BY name_product ORDER BY final_year) AS price_2018,
		CONCAT (round((average_payroll_value/average_price_year), 2),'  ', (substring(price_value_unit,2))) AS amount_for_salary
	FROM t_stepanka_neumannova_project_sql_primary_final tsnpspf  
	WHERE 1=1
		AND industry_branch_code_final = 'všechna odvětví'
		AND price_category IN (111301,114201)
		AND final_year IN (2006, 2018)
	ORDER BY name_product ASC,
		final_year ASC	
)a;