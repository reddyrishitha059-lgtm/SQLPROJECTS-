
create database Employee_Management_System;
use Employee_Management_System;

-- Table 1: Job Department --
CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);
select * from JobDepartment;

-- Table 2: Salary/Bonus --
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
select* from SalaryBonus;

-- Table 3: Employee --
CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
        REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);
select * from Employee;

-- Table 4: Qualification --
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
select * from Qualification;

-- Table 5: Leaves --
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
select * from Leaves;

-- Table 6: Payroll --
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);
select * from Payroll;

-- **************************************Analysis Questions************************************************---
-- 1. EMPLOYEE INSIGHTS --

-- ● How many unique employees are currently in the system? --
SELECT 
    COUNT(DISTINCT emp_ID) AS total_employees 
FROM
    Employee; 
    
----------------------------------------------------------------------  

-- ● Which departments have the highest number of employees? --
SELECT
    jobdepartment.jobdept,
    COUNT(employee.emp_id) AS Total_emp_dept
FROM
    employee
    INNER JOIN jobdepartment
        ON employee.job_id = jobdepartment.job_id
GROUP BY
    jobdepartment.jobdept
ORDER BY
    Total_emp_dept DESC
LIMIT 1;
      
----------------------------------------------------------------------

-- ● What is the average salary per department? --
SELECT
    jobdepartment.jobdept,
    ROUND(AVG(salarybonus.annual), 0) AS avg_salary
FROM
    salarybonus
    INNER JOIN jobdepartment
        ON salarybonus.job_id = jobdepartment.job_id
GROUP BY
    jobdepartment.jobdept;
    
------------------------------------------------------------------------

-- ● Who are the top 5 highest-paid employees? --
SELECT
    CONCAT(e.firstname, ' ', e.lastname) AS full_name,
    (sb.annual + sb.bonus) AS total_salary
FROM
    salarybonus sb
    INNER JOIN payroll p ON sb.salary_ID = p.salary_ID
    INNER JOIN employee e ON e.emp_Id = p.emp_id
ORDER BY
    total_salary DESC
LIMIT 5;

------------------------------------------------------------------------

-- ● What is the total salary expenditure across the company? --
SELECT 
   SUM(total_amount) AS total_salary_expenditure
FROM 
    Payroll;
    
-----------------------------------------------------------------------

-- 2. JOB ROLE AND DEPARTMENT ANALYSIS --

-- ● How many different job roles exist in each department? --
SELECT
    jobdept,
    COUNT(job_id) AS Total_roles
FROM
    jobdepartment
GROUP BY
    jobdept;
    
-----------------------------------------------------------------------------------

-- ● What is the average salary range per department? --
SELECT
    name,amount AS highest_salary
FROM
    jobdepartment
          INNER JOIN 
    salarybonus ON jobdepartment.job_id = salarybonus.job_id
ORDER BY highest_salary DESC
LIMIT 1;
-------------------------------------------------------------------------------------

-- ● Which job roles offer the highest salary? --
SELECT 
	jd.name AS job_role, 
	sb.amount
FROM 
	JobDepartment jd
INNER JOIN 
	SalaryBonus sb
	ON jd.job_ID = sb.Job_ID
ORDER BY
	sb.amount DESC
LIMIT 1;

------------------------------------------------------------------------------------

-- ● Which departments have the highest total salary allocation? --
SELECT
    jobdepartment.jobdept,
    SUM(salarybonus.annual + salarybonus.bonus) AS Total_Salary
FROM
    jobdepartment
    INNER JOIN 
    salarybonus ON jobdepartment.job_id = salarybonus.job_id
GROUP BY jobdepartment.jobdept
ORDER BY Total_Salary DESC
LIMIT 1;
    
-----------------------------------------------------------------------

-- 3. QUALIFICATION AND SKILLS ANALYSIS --

-- ● Which positions require the most qualifications? --
SELECT 
    Position, 
    COUNT(*) AS qualification_count
FROM
    Qualification
GROUP BY
	position
ORDER BY
    qualification_count DESC;

-------------------------------------------------------------------------

-- ● Which employees have the highest number of qualifications? --
SELECT e.emp_ID, 
       e.firstname, 
       e.lastname,
       COUNT(q.QualID) AS total_qualifications
FROM 
    Employee e
INNER JOIN 
    Qualification q 
    ON e.emp_ID = q.Emp_id
GROUP BY 
	e.emp_ID, 
    e.firstname,
    e.lastname
ORDER BY 
    total_qualifications DESC
LIMIT 	1;
    
-----------------------------------------------------------------------
-- 4. LEAVE AND ABSENCE PATTERNS --

-- ● Which year had the most employees taking leaves? --
SELECT
    YEAR(date) AS year,COUNT(emp_id) AS total_leaves
FROM
    leaves
GROUP BY YEAR(date)
LIMIT 1;

----------------------------------------------------------------------

-- ● What is the average number of leave days taken by its employees per department? --
SELECT
    jobdepartment.jobdept,
    COUNT(leaves.leave_id) / COUNT(DISTINCT employee.emp_id) AS avg_leaves_per_emp
FROM
    leaves
      INNER JOIN 
    employee ON leaves.emp_id = employee.emp_id
      INNER JOIN 
	jobdepartment ON employee.job_id = jobdepartment.job_id
GROUP BY jobdepartment.jobdept;

----------------------------------------------------------------------
    
-- ● Which employees have taken the most leaves?
SELECT
    CONCAT(e.firstname, ' ', e.lastname) AS FullName,
    COUNT(l.leave_ID) AS Total_Leaves
FROM
    leaves l
    INNER JOIN employee e ON l.emp_id = e.emp_id
GROUP BY l.emp_ID;

----------------------------------------------------------------------

-- ● What is the total number of leave days taken company-wide?
SELECT 
    COUNT(*) AS total_leave_days
FROM
    Leaves;
 -----------------------------------------------------------------------

-- ● How do leave days correlate with payroll amounts? --
 SELECT
    e.Emp_ID,
    CONCAT(e.FirstName, ' ', e.LastName) AS Full_name,
    COUNT(l.Leave_ID) AS LeaveDays,
    p.Total_Amount AS PayrollAmount
FROM
    Employee e
    LEFT JOIN leaves l ON e.Emp_ID = l.Emp_ID
    LEFT JOIN payroll p ON e.Emp_ID = p.Emp_ID
GROUP BY
    e.Emp_ID, Full_name, p.Total_Amount
ORDER BY
    LeaveDays DESC;  
-----------------------------------------------------------------------

-- 5. PAYROLL AND COMPENSATION ANALYSIS --

-- ● What is the total monthly payroll processed? --
SELECT
    SUM(total_amount) AS Monthly_payroll
FROM
    payroll;
-----------------------------------------------------------------------

-- ● What is the average bonus given per department? --
SELECT
    jb.jobdept,
    ROUND(AVG(sb.bonus), 0) AS Avg_bonus
FROM
    jobdepartment jb
    INNER JOIN salarybonus sb ON jb.job_id = sb.job_id
GROUP BY
    jb.jobdept;
    
---------------------------------------------------------------------

-- ● Which department receives the highest total bonuses?---
SELECT
    jb.jobdept,
    SUM(sb.bonus) AS Highest_bounses
FROM
    jobdepartment jb
    INNER JOIN salarybonus sb ON jb.job_id = sb.job_id
GROUP BY
    jb.jobdept
ORDER BY
    Highest_bounses DESC
LIMIT 1;
------------------------------------------------------------------------

-- ● What is the average value of total_amount after considering leave deductions? --
SELECT
     round(AVG(total_amount),0) AS avg_total_salary
FROM 
    Payroll;