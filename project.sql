SELECT 
    da.department_name,
    da.num_employees,
    da.avg_salary
FROM 
    (
        SELECT 
            d.department_name,
            COUNT(e.id) AS num_employees,
            AVG(e.salary) AS avg_salary
        FROM 
            employees e
        JOIN 
            departments d ON e.department_id = d.department_id
        GROUP BY 
            d.department_name
    ) da
JOIN 
    (
        SELECT 
            AVG(salary) AS overall_avg_salary
        FROM 
            employees
    ) oa 
ON 
    da.avg_salary > oa.overall_avg_salary;