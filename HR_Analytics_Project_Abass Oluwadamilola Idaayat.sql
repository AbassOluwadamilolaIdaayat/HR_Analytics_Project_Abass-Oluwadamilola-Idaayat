SELECT *
FROM [HR DATA]

-- DATA CLEANING

-- Renaming 'id' to 'empLoyee_id'
EXEC sp_rename '[HR DATA].id', 'employee_id', 'COLUMN';

-- Renaming 'birthdate' to 'birth_date'
EXEC sp_rename '[HR DATA].birthdate', 'birth_date', 'COLUMN';

-- Renaming 'jobtitle' to 'job_title'
EXEC sp_rename '[HR DATA].jobtitle', 'job_title', 'COLUMN';

-- Renaming 'termdate' to 'term_date'
EXEC sp_rename '[HR DATA].termdate', 'term_date', 'COLUMN';

-- Checking for duplicate employee IDs
SELECT employee_id, COUNT(*)
FROM [HR DATA]
GROUP BY employee_id
HAVING COUNT(*) > 1;

UPDATE [HR DATA]
SET birth_date =
    TRY_CONVERT(DATE, birth_date, 101);  -- mm/dd/yyyy

UPDATE [HR DATA]
SET hire_date =
    TRY_CONVERT(DATE, hire_date, 101);  -- mm/dd/yyyy

DELETE FROM [HR DATA]
WHERE birth_date > GETDATE();

DELETE FROM [HR DATA]
WHERE hire_date > GETDATE();

UPDATE [HR DATA]
SET term_date= TRY_CONVERT(DATE, LEFT(term_date, 10));

DELETE FROM [HR DATA]
WHERE term_date > GETDATE();

UPDATE [HR DATA]
SET term_date = NULL
WHERE term_date IS NULL OR term_date = '' OR term_date LIKE '  %';

SELECT DISTINCT gender FROM [HR DATA];
SELECT DISTINCT race FROM [HR DATA];
SELECT DISTINCT location_state FROM [HR DATA]

SELECT * FROM [HR DATA]
WHERE race IS NULL OR gender IS NULL;

SELECT * FROM [HR DATA]
WHERE birth_date IS NULL OR hire_date IS NULL;

SELECT * FROM [HR DATA]
WHERE department IS NULL OR job_title IS NULL;

ALTER TABLE [HR DATA] ADD age INT;

UPDATE [HR DATA]
SET age = DATEDIFF(YEAR, birth_date, GETDATE());

SELECT MIN(age), AVG(age), MAX(age) FROM [HR DATA];
SELECT COUNT(*) FROM [HR DATA] WHERE age < 18;

-- QUESTIONS
-- 1. What is the gender breakdown of employees in the company?
SELECT gender, COUNT(*) AS count
FROM [HR DATA]
GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?
SELECT race, COUNT(*) AS count
FROM [HR DATA]
GROUP BY race
ORDER BY count DESC;

-- 3. What is the age distribution of employees in the company?
SELECT 
    CASE 
        WHEN age < 30 THEN '20-29'
        WHEN age < 40 THEN '30-39'
        WHEN age < 50 THEN '40-49'
        ELSE '50-59'
    END AS age_group,
    COUNT(*) AS count
FROM [HR DATA]
GROUP BY 
    CASE 
        WHEN age < 30 THEN '20-29'
        WHEN age < 40 THEN '30-39'
        WHEN age < 50 THEN '40-49'
        ELSE '50-59'
    END
ORDER BY count DESC;

-- 4. How many employees work at headquarters versus remote locations?
SELECT location, COUNT(*) AS count
FROM [HR DATA]
GROUP BY location;

-- 5. What is the average length of employment for employees who have been terminated?
SELECT 
    AVG(DATEDIFF(YEAR, hire_date, term_date)) AS avg_emp_length
FROM [HR DATA]
WHERE term_date IS NOT NULL;

-- 6. How does the gender distribution vary across departments?
SELECT department, gender, COUNT(*) AS employees
FROM [HR DATA]
GROUP BY department, gender
ORDER BY department, employees DESC;

-- 7. What is the distribution of job titles across the company?
SELECT job_title, COUNT(*) AS employees
FROM [HR DATA]
GROUP BY job_title
ORDER BY employees DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

-- 8. Which department has the highest turnover rate?
WITH department_count AS (
    SELECT department,
           COUNT(*) AS total_count,
           SUM(CASE WHEN term_date IS NOT NULL THEN 1 ELSE 0 END) AS termination_count
    FROM [HR DATA]
    GROUP BY department
)
SELECT TOP 1 department,
       ROUND(CAST(termination_count AS FLOAT) / total_count * 100, 1) AS turnover_rate
FROM department_count
ORDER BY turnover_rate DESC;

-- 9. What is the turnover rate across jobtitles
WITH job_title_count AS (
    SELECT job_title,
           COUNT(*) AS total_count,
           SUM(CASE WHEN term_date IS NOT NULL THEN 1 ELSE 0 END) AS termination_count
    FROM [HR DATA]
    GROUP BY job_title
)
SELECT job_title,
       ROUND(CAST(termination_count AS FLOAT) / total_count * 100, 1) AS turnover_rate
FROM job_title_count
ORDER BY turnover_rate DESC;

-- 10. How have turnover rates changed each year?
WITH cte3 AS (
    SELECT YEAR(hire_date) AS hire_year,
           COUNT(*) AS total_count,
           SUM(CASE WHEN term_date IS NOT NULL THEN 1 ELSE 0 END) AS termination_count
    FROM [HR DATA]
    GROUP BY YEAR(hire_date)
)
SELECT hire_year,
       ROUND(CAST(termination_count AS FLOAT) / total_count * 100, 1) AS turnover_rate
FROM cte3
ORDER BY turnover_rate DESC;

-- 11. What is the distribution of employees across states
SELECT location_state, COUNT(*) AS employees
FROM [HR DATA]
GROUP BY location_state
ORDER BY employees DESC, location_state;