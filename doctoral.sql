/*
  Author: Chad Denaux
  Class: Datbase Management Systems
  Project: OracleSQL Doctoral Tracking
  version: 3.0
  This version utilizes a CREATE INDEX function that affects the statistical report from the execution plan
  generated by the list advisors and students query.
*/

-- drop table names in case pre-existing

DROP TABLE student CASCADE CONSTRAINTS;
DROP TABLE faculty CASCADE CONSTRAINTS;
DROP TABLE courses CASCADE CONSTRAINTS;
DROP TABLE committee CASCADE CONSTRAINTS;
DROP TABLE enrollment CASCADE CONSTRAINTS;
DROP TABLE committee_members CASCADE CONSTRAINTS;
-- Create Tables

CREATE TABLE FACULTY 
  ( FACULTYID NUMBER(5) NOT NULL PRIMARY KEY,
    LASTNAME VARCHAR(10) NOT NULL,
    FIRSTNAME VARCHAR(15) NOT NULL,
    OFFICENO  NUMBER(3),
    PNONENO NUMBER(13) NOT NULL
); 

CREATE TABLE STUDENT 
  ( STUDENTID NUMBER(5) NOT NULL  PRIMARY KEY,
  	LASTNAME VARCHAR(10) NOT NULL,
  	FIRSTNAME VARCHAR(15) NOT NULL,
  	STREETNAME VARCHAR(30) ,
  	CITY VARCHAR(15) NOT NULL,
  	STATE VARCHAR(15) NOT NULL,
  	COUNTRY VARCHAR(20) NOT NULL,
  	SPOUSE VARCHAR(30) ,
    STATUS VARCHAR(15) NOT NULL,
    STARTDATE DATE,
    ADVISOR NUMBER(5) NOT NULL,
    PHONENO NUMBER(13),
    THESISTITLE VARCHAR(30),
    THESISADVISOR NUMBER(5),
    COMMITTEEID NUMBER(2) 
);
--Add foreign key constraints to student table
ALTER TABLE student
ADD 
(CONSTRAINT facultyadv_fk FOREIGN KEY (advisor) REFERENCES faculty(facultyid) );

ALTER TABLE student
ADD 
(CONSTRAINT thesisadv_fk FOREIGN KEY (thesisadvisor) REFERENCES faculty(facultyid) );


CREATE TABLE COURSES 
  ( COURSENO NUMBER(3) NOT NULL PRIMARY KEY,
  	SECTION NUMBER(3) NOT NULL,
  	TITLE VARCHAR(30) NOT NULL,
    TERM VARCHAR(10) NOT NULL,
    FACULTY NUMBER(5) NOT NULL,
  	PREREQUISITE NUMBER(3)
);

ALTER TABLE courses
ADD 
(CONSTRAINT professor_fk FOREIGN KEY (faculty) REFERENCES faculty(facultyid) );

CREATE TABLE ENROLLMENT 
  ( COURSENO NUMBER(3) NOT NULL,
    SECTION NUMBER(3) NOT NULL,
    STUDENTID NUMBER(5) NOT NULL,
    COMPLETIONSTATUS VARCHAR(25) NOT NULL 
);
 
-- add Enrollment table constraints


ALTER TABLE enrollment
ADD 
(CONSTRAINT course_fk FOREIGN KEY (courseno) REFERENCES courses(courseno) );


ALTER TABLE enrollment
ADD
(CONSTRAINT student_enrollment_fk FOREIGN KEY (studentid) REFERENCES student(studentid) );

CREATE TABLE COMMITTEE
   ( COMMITTEEID NUMBER(2) NOT NULL PRIMARY KEY,
     STUDENT NUMBER(5) NOT NULL
);

ALTER TABLE committee
ADD
(CONSTRAINT student_committee_fk FOREIGN KEY (student) REFERENCES student(studentid) );

CREATE TABLE COMMITTEE_MEMBERS
  ( COMMITTEEID NUMBER(2) NOT NULL,
    EXAMINER NUMBER(5) NOT NULL,
  	CHAIR VARCHAR(3)	
 );

--committee member constraints

ALTER TABLE committee_members
ADD 
(CONSTRAINT examiner_fk FOREIGN KEY (examiner) REFERENCES faculty(facultyid) );
COMMIT;

-- add faculty

INSERT INTO faculty VALUES 
  (12345, 'Alonso', 'Alicia', 211, 8885554555);
INSERT INTO faculty VALUES 
  (23456, 'Tudor', 'Antony', 213, 8885554556);
INSERT INTO faculty VALUES 
  (34567, 'Byron', 'Lord', 215, 8885554557);
INSERT INTO faculty VALUES 
  (45678, 'Poe', 'Edgar A.', 217, 8885554558);


-- add students


INSERT INTO student VALUES 
  (55555, 'Baudelaire', 'Charles', '58 Rue de John', 'Paris', 'Ile-de-France', 'France', '', 'Full-time', '18-FEB-2013', 34567, 18434445678, 'Spleen', 45678, 10);
INSERT INTO student VALUES 
  (55556, 'Shelley', 'Mary', '58 Rue de John', 'Charleston', 'SC', 'USA', '', 'Full-time', '18-AUG-2010', 34567, 18434445679, 'Silly Poetry', 45678, 20);

--create committee

INSERT INTO committee VALUES
  (10, 55555);
INSERT INTO committee VALUES
  (20, 55556);
--create committee list

INSERT INTO committee_members VALUES 
  (10, 12345, NULL);
INSERT INTO committee_members VALUES 
  (10, 23456, 'yes');
INSERT INTO committee_members VALUES 
  (10, 34567, NULL);
INSERT INTO committee_members VALUES 
  (10, 45678, NULL);
INSERT INTO committee_members VALUES 
  (20, 45678, NULL);
INSERT INTO committee_members VALUES 
  (20, 34567, 'yes');
INSERT INTO committee_members VALUES 
  (20, 23456, NULL);
INSERT INTO committee_members VALUES 
  (20, 12345, NULL);
--course list

INSERT INTO courses VALUES 
  (313, 001, 'Creative Writing','Fall', 34567, null);
INSERT INTO courses VALUES 
  (413, 001, 'Poetry','Spring', 45678, 313);  

--enrollment list

INSERT INTO enrollment VALUES 
  (313, 001, 55555, 'A');
INSERT INTO enrollment VALUES 
  (413, 001, 55556, 'In Progress');

-- FACULTY LISTING

SELECT lastname || ', ' || firstname AS "Faculty Member"
  FROM faculty
    ORDER BY lastname; 

-- STUDENT/ADVISOR LISTING

SELECT student.lastname || ', ' || student.firstname AS "Student", faculty.lastname || ', ' || faculty.firstname AS "Advisor"
  FROM student 
    JOIN faculty 
      ON student.advisor = faculty.facultyid 
  ORDER BY student.lastname;

--STUDENT STATUS REPORT

SELECT student.lastname || ', ' || student.firstname AS "Student", student.status AS "Current Status", ROUND((SYSDATE-student.startdate)/365-1)  AS "YearsEnrolled", faculty.lastname || ', ' || faculty.firstname AS "Advisor"
  FROM student
    JOIN faculty 
      ON student.advisor = faculty.facultyid
  ORDER BY "YearsEnrolled" DESC;

--Enrollment Report

SELECT courses.courseno || '/' || courses.title AS "Course No/Name", faculty.lastname || ', ' || faculty.firstname AS "Professor", student.lastname || ', ' || student.firstname AS  "Student"
  FROM enrollment 
    JOIN courses
      ON enrollment.courseno = courses.courseno
    INNER 
      JOIN faculty
        ON courses.faculty = faculty.facultyid
    JOIN student
      ON enrollment.studentid = student.studentid
  WHERE LOWER(courses.term) LIKE LOWER('%&term%')
  ORDER BY courses.courseno;

--Course Completion Status Report

SELECT student.lastname || ', ' || student.firstname AS "Student", enrollment.courseno AS "Course Number", courses.title AS "Name", enrollment.completionstatus AS "Status"
  FROM enrollment
    JOIN student 
      ON enrollment.studentid = student.studentid
    JOIN courses
      ON enrollment.courseno = courses.courseno
  ORDER BY student.lastname, enrollment.courseno;

--Committee report

SELECT  student.lastname || ', '|| student.firstname AS "Student", faculty.lastname || ', '|| faculty.firstname AS "CommitteeMember", 
    CASE 
      WHEN committee_members.chair = 'yes'
         THEN 'Y'
         ELSE 'N'
    END AS "Chair?"
  FROM committee_members
    JOIN student 
      ON committee_members.committeeid= student.committeeid
    JOIN faculty
      ON committee_members.examiner = faculty.facultyid
  Order By student.lastname, faculty.lastname;

SET AUTOTRACE ON;



SELECT faculty.lastname AS advisor,
       student.lastname AS student
FROM faculty,
     student
WHERE student.advisor = faculty.facultyid;

CREATE INDEX advisor_index
  ON student (advisor);  

SELECT faculty.lastname AS advisor,
       student.lastname AS student
FROM faculty,
     student
WHERE student.advisor = faculty.facultyid;

SET AUTOTRACE OFF;



      
   