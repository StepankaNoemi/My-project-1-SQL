

CREATE TABLE t_stepanka_neumannova_project_SQL_primary_final AS (
WITH basic_payroll AS (
	SELECT 
		cp.id,
		cp.value,
		cp.value_type_code,
		cpvt.name AS type_name_payroll,
		cp.unit_code,
		cpu.name AS unit_payroll, 
		cp.calculation_code, 
		cpc.name AS calculation_method,
		cp.industry_branch_code,
		CASE 
			WHEN cp.industry_branch_code IS NULL THEN 'all_branches'
			ELSE industry_branch_code
		END AS industry_branch_code_final,
		cpib.name AS branch_name,
		cp.payroll_year,
		cp.payroll_quarter 
	FROM czechia_payroll cp
	LEFT JOIN czechia_payroll_value_type cpvt 
		ON cp.value_type_code = cpvt.code 
	LEFT JOIN czechia_payroll_unit cpu 
		ON cp.unit_code = cpu.code 
	LEFT JOIN czechia_payroll_calculation cpc 
		ON cp.calculation_code = cpc.code 
	LEFT JOIN czechia_payroll_industry_branch cpib 
		ON cp.industry_branch_code = cpib.code 
	WHERE cp.value_type_code = '5958'
		AND cp.calculation_code = '200'				
),
avg_payroll_year AS (
	SELECT 
		industry_branch_code_final,
		payroll_year,
		round (avg(value), 2) AS average_payroll_year
	FROM basic_payroll
	GROUP BY industry_branch_code_final,
			payroll_year
),
final_select_payroll AS (
	SELECT 
		DISTINCT a.payroll_year AS final_year,
		a.value_type_code,
		a.type_name_payroll,
		a.unit_payroll, 
		a.calculation_method,
		a.industry_branch_code_final,
		a.branch_name,
		b.average_payroll_year
	FROM basic_payroll a 
	JOIN avg_payroll_year b 
		ON a.payroll_year = b.payroll_year
		AND a.industry_branch_code_final = b.industry_branch_code_final
	ORDER BY a.industry_branch_code ASC, final_year ASC
),
basic_price AS (
	SELECT 
		p.*,
		YEAR(date_from)AS price_year,
		p2.name,
		CONCAT (p2.price_value,p2.price_unit) AS price_value_unit
	FROM czechia_price p
	LEFT JOIN czechia_price_category p2
		ON p.category_code = p2.code 
	WHERE p.region_code IS NULL 
),
calculation_avg_price AS (
	SELECT 
		category_code,
		price_year,
		round(AVG(value), 2) AS average_price_year
	FROM basic_price
	GROUP BY category_code,
			price_year
	ORDER BY category_code ASC, price_year ASC
), 
final_select_price AS (
	SELECT 
		DISTINCT bc.category_code AS price_category,
		bc.name AS name_product,
		bc. price_value_unit,
		bc.price_year,
		bc.average_price_year
	FROM (
	SELECT
		bp.*,
		cap.average_price_year
	FROM basic_price  bp
	JOIN calculation_avg_price cap
		ON bp.price_year = cap.price_year
		AND bp.category_code = cap.category_code
	)bc
	ORDER BY price_category ASC, bc.price_year ASC
)
SELECT *
	FROM final_select_payroll e
	JOIN final_select_price g
		ON e.final_year = g.price_year
	ORDER BY e.final_year ASC,
		e.industry_branch_code_final ASC, 
		g.price_category ASC
;

