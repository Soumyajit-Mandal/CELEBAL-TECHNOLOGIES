--Task - 1 :

WITH ProjectGroups AS (
    SELECT
        Task_ID,
        Start_Date,
        End_Date,
        ROW_NUMBER() OVER (ORDER BY Start_Date) - 
        ROW_NUMBER() OVER (PARTITION BY DATEADD(day, -ROW_NUMBER() OVER (ORDER BY Start_Date), Start_Date) ORDER BY Start_Date) AS Project_ID
    FROM Projects
)
SELECT 
    MIN(Start_Date) AS Start_Date,
    MAX(End_Date) AS End_Date,
    DATEDIFF(day, MIN(Start_Date), MAX(End_Date)) + 1 AS Duration
FROM ProjectGroups
GROUP BY Project_ID
ORDER BY Duration, MIN(Start_Date);


--Task - 2 : 

SELECT
    s1.Nome AS Student_Name,
    s2.Nome AS Best_Friend_Name,
    p2.Salary AS Best_Friend_Salary
FROM
    Students s1
JOIN
    Friends f ON s1.ID = f.ID
JOIN
    Students s2 ON f.Friend_ID = s2.ID
JOIN
    Packages p1 ON s1.ID = p1.ID
JOIN
    Packages p2 ON s2.ID = p2.ID
WHERE
    p2.Salary > p1.Salary
ORDER BY
    p2.Salary;

--Task - 3: 
SELECT DISTINCT
    f1.X AS X,
    f1.Y AS Y
FROM
    Functions f1
JOIN
    Functions f2 ON f1.X = f2.Y AND f1.Y = f2.X
WHERE
    f1.X < f1.Y
ORDER BY
    f1.X;


--Task - 4:

SELECT
    c.contest_id,
    c.hacker_id,
    h.name,
    COALESCE(SUM(v.total_views), 0) AS total_views,
    COALESCE(SUM(v.total_unique_views), 0) AS total_unique_views,
    COALESCE(SUM(s.total_submissions), 0) AS total_submissions,
    COALESCE(SUM(s.total_accepted_submissions), 0) AS total_accepted_submissions
FROM
    Contests c
JOIN
    Hackers h ON c.hacker_id = h.hacker_id
JOIN
    Colleges co ON c.contest_id = co.contest_id
JOIN
    Challenges ch ON co.college_id = ch.college_id
LEFT JOIN
    View_Stats v ON ch.challenge_id = v.challenge_id
LEFT JOIN
    Submission_Stats s ON ch.challenge_id = s.challenge_id
GROUP BY
    c.contest_id, c.hacker_id, h.name
HAVING
    SUM(v.total_views) > 0 OR
    SUM(v.total_unique_views) > 0 OR
    SUM(s.total_submissions) > 0 OR
    SUM(s.total_accepted_submissions) > 0
ORDER BY
    c.contest_id;

--Task - 5

WITH DateRange AS (
    SELECT DATE '2016-03-01' AS submission_date
    UNION ALL
    SELECT submission_date + INTERVAL '1' DAY
    FROM DateRange
    WHERE submission_date < DATE '2016-03-15'
),
DailySubmissions AS (
    SELECT
        dr.submission_date,
        s.hacker_id,
        COUNT(s.submission_id) AS submissions_count
    FROM
        DateRange dr
    LEFT JOIN
        Submissions s ON dr.submission_date = s.submission_date
    GROUP BY
        dr.submission_date, s.hacker_id
),
UniqueHackers AS (
    SELECT
        submission_date,
        COUNT(DISTINCT hacker_id) AS unique_hackers
    FROM
        DailySubmissions
    GROUP BY
        submission_date
),
MaxSubmissions AS (
    SELECT
        submission_date,
        hacker_id,
        submissions_count
    FROM (
        SELECT
            submission_date,
            hacker_id,
            submissions_count,
            ROW_NUMBER() OVER (PARTITION BY submission_date ORDER BY submissions_count DESC, hacker_id) AS rn
        FROM
            DailySubmissions
    ) AS ranked
    WHERE
        rn = 1
)
SELECT
    u.submission_date,
    u.unique_hackers,
    m.hacker_id,
    h.name,
    m.submissions_count
FROM
    UniqueHackers u
JOIN
    MaxSubmissions m ON u.submission_date = m.submission_date
JOIN
    Hackers h ON m.hacker_id = h.hacker_id
ORDER BY
    u.submission_date;


--Task - 6:

WITH Points AS (
    SELECT
        MIN(LAT_N) AS min_lat,
        MIN(LONG_W) AS min_long,
        MAX(LAT_N) AS max_lat,
        MAX(LONG_W) AS max_long
    FROM
        STATION
)
SELECT
    ROUND(ABS(min_lat - max_lat) + ABS(min_long - max_long), 4) AS manhattan_distance
FROM
    Points;


--Task - 7:

WITH RECURSIVE Numbers AS (
    SELECT 2 AS num
    UNION ALL
    SELECT num + 1
    FROM Numbers
    WHERE num < 1000
),
PrimeNumbers AS (
    SELECT num
    FROM Numbers
    WHERE num NOT IN (
        SELECT n.num
        FROM Numbers n
        JOIN Numbers m ON m.num <= SQRT(n.num) AND n.num % m.num = 0 AND m.num > 1
    )
)
SELECT STRING_AGG(CAST(num AS VARCHAR), '&') AS prime_numbers
FROM PrimeNumbers;


--Task - 8:

WITH OccupationRanks AS (
    SELECT
        Name,
        Occupation,
        ROW_NUMBER() OVER (PARTITION BY Occupation ORDER BY Name) AS row_num
    FROM
        OCCUPATIONS
),
Pivoted AS (
    SELECT
        MAX(CASE WHEN Occupation = 'Doctor' THEN Name END) AS Doctor,
        MAX(CASE WHEN Occupation = 'Professor' THEN Name END) AS Professor,
        MAX(CASE WHEN Occupation = 'Singer' THEN Name END) AS Singer,
        MAX(CASE WHEN Occupation = 'Actor' THEN Name END) AS Actor
    FROM
        OccupationRanks
    GROUP BY
        row_num
)
SELECT
    Doctor,
    Professor,
    Singer,
    Actor
FROM
    Pivoted;


--Task - 9 :

WITH NodeType AS (
    SELECT
        N,
        P,
        CASE
            WHEN P IS NULL THEN 'Root'
            WHEN N NOT IN (SELECT DISTINCT P FROM BST) THEN 'Leaf'
            ELSE 'Inner'
        END AS node_type
    FROM
        BST
)
SELECT
    N,
    node_type
FROM
    NodeType
ORDER BY
    N;

--Task - 10:

WITH EmployeeCounts AS (
    SELECT
        company_code,
        COUNT(DISTINCT CASE WHEN lead_manager_code IS NOT NULL THEN lead_manager_code END) AS lead_managers_count,
        COUNT(DISTINCT CASE WHEN senior_manager_code IS NOT NULL THEN senior_manager_code END) AS senior_managers_count,
        COUNT(DISTINCT CASE WHEN manager_code IS NOT NULL THEN manager_code END) AS managers_count,
        COUNT(DISTINCT employee_code) AS total_employees_count
    FROM
        Employee
    GROUP BY
        company_code
)
SELECT
    c.company_code,
    c.founder,
    COALESCE(ec.lead_managers_count, 0) AS lead_managers_count,
    COALESCE(ec.senior_managers_count, 0) AS senior_managers_count,
    COALESCE(ec.managers_count, 0) AS managers_count,
    COALESCE(ec.total_employees_count, 0) AS total_employees_count
FROM
    Company c
LEFT JOIN
    EmployeeCounts ec ON c.company_code = ec.company_code
ORDER BY
    c.company_code;


--Task - 11:

SELECT DISTINCT
    s.Name
FROM
    Students s
JOIN
    Friends f ON s.ID = f.ID
JOIN
    Packages p1 ON f.Friend_ID = p1.ID
JOIN
    Packages p2 ON s.ID = p2.ID
WHERE
    p1.Salary > p2.Salary
ORDER BY
    p1.Salary;

--Task - 12:

SELECT
    JobFamily,
    Country,
    SUM(CASE WHEN Country = 'India' THEN Cost ELSE 0 END) AS India_Cost,
    SUM(CASE WHEN Country = 'International' THEN Cost ELSE 0 END) AS International_Cost,
    (SUM(CASE WHEN Country = 'India' THEN Cost ELSE 0 END) / NULLIF(SUM(Cost), 0)) * 100 AS India_Percentage,
    (SUM(CASE WHEN Country = 'International' THEN Cost ELSE 0 END) / NULLIF(SUM(Cost), 0)) * 100 AS International_Percentage
FROM
    YourTable
GROUP BY
    JobFamily, Country;

--Task - 13:

SELECT BU, 
       MONTH, 
       SUM(Cost) AS Total_Cost, 
       SUM(Revenue) AS Total_Revenue, 
       SUM(Cost) / NULLIF(SUM(Revenue), 0) AS Cost_Revenue_Ratio
FROM YourTable
GROUP BY BU, MONTH;

--Task - 14 :

SELECT SubBand, 
       COUNT(EmployeeID) AS Headcount, 
       (COUNT(EmployeeID) / (SELECT COUNT(*) FROM YourTable)) * 100 AS Percentage_Headcount
FROM YourTable
GROUP BY SubBand;


--Task - 15:

SELECT EmployeeID, Salary
FROM YourTable
FETCH FIRST 5 ROWS ONLY;


--Task - 16:

UPDATE YourTable
SET Column1 = Column2,
    Column2 = Column1;


--Task - 17:

CREATE LOGIN prakash WITH PASSWORD = 'jyothiprakash@629';
USE YourDatabaseName;
CREATE USER balaji FOR LOGIN prakash;
ALTER ROLE db_owner ADD MEMBER khizar;

--Task - 18:

SELECT BU, 
       MONTH, 
       SUM(Cost * EmployeeCount) / SUM(EmployeeCount) AS Weighted_Average_Cost
FROM YourTable
GROUP BY BU, MONTH;

--Task - 19 :

SELECT CEIL(AVG(Salary) - AVG(NULLIF(SUBSTR(Salary, 1, LENGTH(Salary) - 1), 0))) AS Salary_Error
FROM YourTable;

--Task - 20:

INSERT INTO DestinationTable (Column1, Column2, ...)
SELECT Column1, Column2, ...
FROM SourceTable;
