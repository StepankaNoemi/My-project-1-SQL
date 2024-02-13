
CREATE TABLE t_stepanka_neumannova_project_SQL_secondary_final (
WITH basic AS (
	SELECT 
		continent,
		country AS country_eu, 
		currency_code,
		currency_name 
	FROM countries c 
	WHERE continent = 'Europe'
),
basic_2 AS (
	SELECT 
	 	b.*,
	 	e.*
	FROM basic b
	LEFT JOIN economies e
		ON b.country_eu = e.country
)
SELECT 
	country_eu,
	currency_code,
	currency_name,
	`year`,
	round (GDP,0) AS GDP_round,
	gini,
	population
FROM basic_2
WHERE country IS NOT NULL
	AND `year` BETWEEN '2006' AND '2018'
ORDER BY country_eu ASC,
		`year` ASC
)
;