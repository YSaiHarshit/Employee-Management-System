create database employee_management_system;

use employee_management_system;

CREATE TABLE JobDepartment (
Job_ID INT PRIMARY KEY,
jobdept VARCHAR(50),
name VARCHAR(100),
description TEXT,
salaryrange VARCHAR(50)
);
select *from JobDepartment;
-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
salary_ID INT PRIMARY KEY,
Job_ID INT,
amount DECIMAL(10,2),
annual DECIMAL(10,2),
bonus DECIMAL(10,2),
CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
ON DELETE CASCADE ON UPDATE CASCADE
);
select * from SalaryBonus;
-- Table 3: Employee
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
-- Table 4: Qualification
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
-- Table 5: Leaves
CREATE TABLE Leaves (
leave_ID INT PRIMARY KEY,
emp_ID INT,
date DATE,
reason TEXT,
CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
ON DELETE CASCADE ON UPDATE CASCADE
);
select * from Leaves;
-- Table 6: Payroll
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
CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES
SalaryBonus(salary_ID)
ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
ON DELETE SET NULL ON UPDATE CASCADE
);
select * from payroll;

-- Analysis Questions

-- 1)Employee Insights

-- ●  1)How many unique employees are currently in the system?
select count(distinct emp_id) as unique_emp_count
from Employee;

-- ●  2)Which departments have the highest number of employees?
select jd.jobdept,
	   count(e.emp_ID) as emp_count
From Employee e
join JobDepartment jd
     on e.Job_ID = jd.Job_ID
group by jd.jobdept
order by emp_count desc;

-- ●  3)What is the average salary per department?
select jd.jobdept,
	   avg(sb.amount) as avg_salary
from JobDepartment jd
join SalaryBonus sb
     on jd.Job_ID = sb.Job_ID
group by jd.jobdept;

-- ●  4)Who are the top 5 highest-paid employees?
select e.emp_ID,
       e.firstname,
       e.lastname, 
       p.total_amount
from Payroll p
join Employee e
     on e.emp_ID = p.emp_ID
order by p.total_amount desc
limit 5;

-- ●  5)What is the total salary expenditure across the company?
select sum(total_amount) 
from Payroll;

-- 2. JOB ROLE AND DEPARTMENT ANALYSIS

-- 1)How many different job roles exist in each department?
select name from jobdepartment;

--  2)What is the average salary range per department?

select jd.jobdept,
       avg(sb.amount) as avg_salary
from JobDepartment jd
join SalaryBonus as sb
       on jd.job_ID = sb.job_ID
group by jd.jobdept;

--  3)Which job roles offer the highest salary?

select jd.name,
	   sb.amount
from JobDepartment jd
join SalaryBonus sb
     on jd.job_ID = sb.job_ID
where sb.amount = (
     select max(amount)
     from SalaryBonus
);

--  4)Which departments have the highest total salary allocation?

select jd.jobdept,
       sum(sb.amount) as total_salary
from JobDepartment jd
join SalaryBonus sb
     on jd.job_ID = sb.job_ID
group by jd.jobdept
order by total_salary desc;

-- 3. QUALIFICATION AND SKILLS ANALYSIS

--  1)How many employees have at least one qualification listed?

SELECT e.emp_ID,
       CONCAT(e.firstname, ' ', e.lastname) AS full_name,
       COUNT(q.QualID) AS qualification_count
FROM Employee e
JOIN Qualification q
     ON e.emp_ID = q.Emp_ID
GROUP BY e.emp_ID, e.firstname, e.lastname
HAVING COUNT(q.QualID) >= 1;

--  2)Which positions require the most qualifications?

select Position,
       count(*) as qualification_count
from Qualification
group by Position
order by qualification_count desc;

--  3)Which employees have the highest number of qualifications?

select e.emp_ID,
      concat(e.firstname,' ',e.lastname) as full_name,
      count(*) as qualification_count
from Employee e
join Qualification q
     on e.emp_ID = q.emp_ID
group by emp_ID
order by qualification_count desc
limit 1;

-- 4. LEAVE AND ABSENCE PATTERNS

--  1)Which year had the most employees taking leaves?

select year(date) as leave_year,
       count(distinct emp_ID) as employee_count
from Leaves
group by leave_year
order by employee_count desc;

--  2)What is the average number of leave days taken by its employees per department?
select e.Job_ID,
       avg(leave_count) as avg_leave_days
from (
    select emp_ID,
		   count(*) as leave_count
	from Leaves
    group by emp_ID
) t
join Employee e
     on t.emp_ID = e.emp_ID
group by e.job_ID;

--  3)Which employees have taken the most leaves?
select e.emp_ID,
       concat(e.firstname,' ',e.lastname) as full_name,
       count(*) as leave_count
from Employee e
join Leaves l
     on e.emp_ID = l.emp_ID
group by e.emp_ID,e.firstname,e.lastname
order by leave_count desc;

--  4)What is the total number of leave days taken company-wide?

select sum(leave_count) as total_leave_days
from (
    select emp_ID,
    count(*) as leave_count
    from Leaves
    group by emp_ID
) t; 
select * from jobdepartment;
select* from employee;
select * from qualification;	

--  5)How do leave days correlate with payroll amounts?

select e.emp_ID,
       count(l.leave_ID) as leave_count,
       p.total_amount
from Employee e
join Leaves l
     on e.emp_ID = l.emp_ID
join Payroll p
     on e.emp_ID = p.emp_ID
group by e.emp_ID,p.total_amount
order by leave_count desc;

-- 5. PAYROLL AND COMPENSATION ANALYSIS

--  1)What is the total monthly payroll processed?

select month(date) as payroll_month,
       sum(total_amount) as total_monthly_payroll
from payroll
group by payroll_month
order by total_monthly_payroll;
select date from payroll;

--  2)What is the average bonus given per department?

select Job_ID,
	   avg(bonus) as avg_bonus
from SalaryBonus sb
group by Job_ID;

--  3)Which department receives the highest total bonuses?

select jd.jobdept,
	   sum(sb.bonus) as total_bonus
from JobDepartment jd
join SalaryBonus sb
     on jd.Job_ID = sb.Job_ID
group by jd.jobdept
order by total_bonus desc;

--  4)What is the average value of total_amount after considering leave deductions?

select avg(adjusted_amount) as avg_amount_after_deduction
from (
	select p.emp_ID,
           p.total_amount - (COUNT(l.leave_ID) * 500) AS adjusted_amount
	from Payroll p
    left join Leaves l
         on p.emp_ID = l.emp_ID
	group by p.emp_ID,p.total_amount
) t;

select Job_ID,avg(amount)
from SalaryBonus sb
join JobDepartment jd,
   sb.Job_ID = jd.Job_ID 
group by 