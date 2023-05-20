drop table if exists exam;
drop table if exists exam_reservation;
drop table if exists students;
drop table if exists course;

create table students(
	student_name varchar, 
	birthdate varchar, 
	student_ID varchar primary key, 
	enrollment varchar, 
	city varchar,
	address varchar
);

insert into students values 
('John Smith', '2000-01-01', 'S001', '2020', 'New York', '123 Main St'),
('Sarah Johnson', '1999-04-15', 'S002', '2020', 'Los Angeles', '456 Elm St'),
('David Lee', '2001-02-28', 'S003', '2020', 'Chicago', '789 Oak St'),
('Emily Brown', '2002-07-12', 'S004', '2020', 'Houston', '1011 Pine St'),
('Daniel Kim', '1998-11-22', 'S005', '2020', 'San Francisco', '1213 Maple St'),
('Olivia Rodriguez', '2000-09-05', 'S006', '2020', 'Miami', '1415 Cedar St'),
('William Thompson', '1999-01-30', 'S007', '2020', 'Seattle', '1617 Birch St'),
('Ava Martinez', '2003-03-17', 'S008', '2020', 'Boston', '1819 Spruce St'),
('James Hernandez', '2001-05-21', 'S009', '2020', 'Dallas', '2021 Walnut St'),
('Sophia Nguyen', '1997-12-07', 'S010', '2020', 'Washington, D.C.', '2223 Chestnut St');

insert into students values
('Pasquale Aliperta', '1997-12-07', 'S011', '2020', 'Rome', 'San Pietro in Vincoli'),
('Daniel Gigliotti', '1997-12-07', 'S012', '2020', 'Rome', 'San Pietro in Vincoli'),
('Iacopo Modica', '1997-12-07', 'S013', '2020', 'Rome', 'San Pietro in Vincoli'),
('Emmanuel Gallotta', '1997-12-07', 'S014', '2020', 'Rome', 'San Pietro in Vincoli'),
('Francesco di Genova', '1997-12-07', 'S015', '2020', 'Rome', 'San Pietro in Vincoli');

select * from students;

create table course(
	course_name varchar, 
	cfu numeric,
	course_year varchar,
	semester numeric,
	professor varchar,
	PRIMARY KEY (course_name, course_year)
);

insert into course values 
('Mathematics', 8, '2022', 1, 'John Doe'),
('Physics', 6, '2022', 2, 'Jane Smith'),
('History', 6, '2023', 1, 'Adam Jones'),
('English Literature', 4, '2023', 2, 'Emily Davis'),
('Computer Science', 8, '2024', 1, 'Michael Lee'),
('Biology', 6, '2024', 2, 'Samantha Brown'),
('Chemistry', 8, '2025', 1, 'David Kim'),
('Geography', 6, '2025', 2, 'Michelle Chen'),
('Psychology', 8, '2026', 1, 'Andrew Lee'),
('Sociology', 6, '2026', 2, 'Christine Wang');

select * from course;

create table exam(
	student_ID varchar,
	course_name varchar,
	course_year varchar,
	grade numeric,
	PRIMARY KEY (student_ID, course_name, course_year),
	FOREIGN KEY (student_ID) REFERENCES Students
      (student_ID),
  	FOREIGN KEY (course_name, course_year) REFERENCES Course
      (course_name, course_year)
);

insert into exam values 
('S001', 'Mathematics', '2022', 85),
('S001', 'Physics', '2022', 75),
('S002', 'History', '2023', 90),
('S002', 'English Literature', '2023', 80),
('S003', 'Computer Science', '2024', 95),
('S003', 'Biology', '2024', 85),
('S004', 'Chemistry', '2025', 70),
('S004', 'Geography', '2025', 80),
('S005', 'Psychology', '2026', 90),
('S005', 'Sociology', '2026', 85);

select * from exam;

create table exam_reservation (
	student_ID varchar,
	course_name varchar,
	course_year varchar,
	PRIMARY KEY (student_ID, course_name, course_year),
	FOREIGN KEY (student_ID) REFERENCES Students
      (student_ID),
  	FOREIGN KEY (course_name, course_year) REFERENCES Course
      (course_name, course_year)
);

insert into exam_reservation values 
('S001', 'Mathematics', '2022'),
('S001', 'Physics', '2022'),
('S002', 'History', '2023'),
('S002', 'English Literature', '2023'),
('S003', 'Computer Science', '2024'),
('S003', 'Biology', '2024'),
('S004', 'Chemistry', '2025'),
('S004', 'Geography', '2025'),
('S005', 'Psychology', '2026'),
('S005', 'Sociology', '2026');

select * from exam_reservation;

-- Return the name of all the students living in Rome
select * from students where students.city = 'Rome'

-- Return exam name and year of the exams passed by John Doe in 2021
insert into students values
('John Doe', '1997-12-07', 'S016', '2020', 'New York', 'Brooklin avenue');

insert into exam values
('S016', 'Psychology', '2026', 90);

insert into exam values
('S016', 'Chemistry', '2025', 50);

select ex.course_name, ex.course_year
from exam ex, students s
where ex.student_id = s.student_id and
	s.student_name = 'John Doe' and
	ex.course_year = '2021';

-- Return the name of the professors of the exams passed by John Doe
select co.professor
from exam ex, students s, course co
where ex.student_id = s.student_id and
	s.student_name = 'John Doe' and
	ex.course_name = co.course_name and 
	ex.course_year = co.course_year;
	
-- Return the ID and the birth date of all the students that have passed at least
-- an exam in 2021
select s.student_id, s.birthdate
from students s
where s.student_id in (select distinct exam.student_id from exam where exam.course_year = '2025');

-- Return name and number of CFUs of all the courses that were passed by students
-- enrolled in 2020
insert into students values
('Marco Nacca', '1997-12-07', 'S017', '2021', 'Caserta', 'Via Napoli');

insert into course values
('Data Management', 6, '2026', 2, 'Riccardo Rosati');

insert into exam values
('S017', 'Data Management', '2026', 90);

select co.course_name, co.cfu
from course co
where (co.course_name, co.course_year) in (
	-- table containing all the exams passed by at least one student enrolled in 2020
	select ex.course_name, ex.course_year
	from exam ex, students s
	where ex.student_id = s.student_id and 
		s.enrollment = '2020'
);

-- Return the name of professors that have registered exams that were not reserved by students
insert into students values
('Gerardo Loffredo', '1997-01-18', 'S018', '2021', 'Avellino', 'Via Avellino');

insert into exam_reservation values
('S018', 'Chemistry', '2025');

insert into exam values
('S018', 'Chemistry', '2025', 90);

select ex.student_id
from exam ex
where ex.student_id not in (
	select er.student_id 
	from exam_reservation er
);

-- For every student, return the name and the number of the exams passed by the student

-- The GROUP BY statement groups rows that have the same values into summary rows, like 
-- "find the number of customers in each country".
-- The GROUP BY statement is often used with aggregate functions 
-- (COUNT(), MAX(), MIN(), SUM(), AVG()) to group the result-set by one or more columns.

select s.student_name, count(ex.course_name)
from students s, exam ex
where s.student_id = ex.student_id
group by s.student_id

-- For every student, return the name and the average grade of the of exams passed
-- by the student

select s.student_name, avg(ex.grade)
from students s, exam ex
where s.student_id = ex.student_id
group by s.student_id

--For every student, return the name and the number of exams that were reserved 
-- but not passed by the student

insert into course values 
('Robotics 1', 6, '2025', 2, 'Alessandro De Luca');

insert into exam_reservation values 
('S018', 'Robotics 1', '2025');

insert into exam values 
('S004', 'Robotics 1', '2025', 90);

select s.student_name, s.student_id, count(er.course_name)
from students s, exam_reservation er
where s.student_id = er.student_id and not exists (
		-- exams passed by the student
		select ex.student_id
		from exam ex
		where ex.student_id = s.student_id and
			ex.course_name = er.course_name and
			ex.course_year = er.course_year
	)
group by s.student_id;

-- all pairs (student_id, booked course_name, course_year)
select s.student_name, er.course_name, er.course_year
from students s, exam_reservation er
where s.student_id = er.student_id
except
-- all pairs (student_id, passed course_name, course_year)
select s.student_name, ex.course_name, ex.course_year
from students s, exam ex
where s.student_id = ex.student_id;

-- this gives (student_id, course_name, course_year) of the exams
-- booked but not passed by the student

select s.student_name, s.student_id, count(exres.student_id)
from students s, exam_reservation exres
WHERE s.student_id = exres.student_id and NOT EXISTS (	
	SELECT  *
	FROM  exam ex
	WHERE exres.course_name = ex.course_name and 
 		exres.course_year = ex.course_year and 
 		exres.student_id=ex.student_id
)
group by s.student_id;

select * from exam order by course_year, student_id;
select * from exam_reservation order by student_id;

-- Return the ID and the birthdate of every student such that the total amount of
-- CFUs of the exams passed by the student in 2021 is less than 20;

select students.student_id, students.birthdate
from students, exam, course
where
	exam.student_id = students.student_id and
	exam.course_name = course.course_name and
	exam.course_year = course.course_year and
	course.course_year = '2021'
group by students.student_id
having sum(course.cfu) < 20;

-- Return the professor(s) who registered the maximum number of exams with the
-- maximum grade (either 30 or 30 cum laude).

select co.professor
from course co, exam ex
where 
	ex.course_name = co.course_name and
	ex.course_year = co.course_year and
	co.professor in (
		select course.professor
		from
		where
	)

-- exams with maximum grade
select exam.course_name, exam.course_year
from exam
where 
	exam.grade = 90 or 
	exam.grade = 31
	
-- professors with the number of exams with the maximum grade
select co.professor, count(co.professor)
from exam ex, course co
where
	ex.course_name = co.course_name and
	ex.course_year = co.course_year and
	ex.grade = 90
group by co.professor;

-- finally
with professor_grade_count as (
	select co.professor as professor, count(co.professor) as count_grade
	from exam ex, course co
	where
		ex.course_name = co.course_name and
		ex.course_year = co.course_year and
		ex.grade = 90
	group by co.professor
)
select 
	professor
from professor_grade_count
where count_grade = (select max(count_grade) from professor_grade_count);
