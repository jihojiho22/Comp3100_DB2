create table if not exists department
	(dept_name	varchar(100), 
	 location	varchar(100), 
	 primary key (dept_name)
	);

create table if not exists student
	(student_id		varchar(10), 
	 name			varchar(20) not null, 
	 email			varchar(50) not null,
	 dept_name		varchar(100), 
	 primary key (student_id),
	 foreign key (dept_name) references department (dept_name)
		on delete set null
	);

create table if not exists account
	(email		varchar(50),
	 password	varchar(20) not null,
	 type		varchar(20),
	 primary key(email)
	);

create table if not exists course
	(course_id		varchar(20), 
	 course_name		varchar(50) not null, 
	 credits		numeric(2,0) check (credits > 0),
	 primary key (course_id)
	);

create table if not exists instructor
	(instructor_id		varchar(10),
	 instructor_name	varchar(50) not null,
	 title 			varchar(30),
	 dept_name		varchar(100), 
	 email			varchar(50) not null,
	 primary key (instructor_id)
	);

create table if not exists time_slot
	(time_slot_id		varchar(12),
	 day			varchar(10) not null,
	 start_time		time not null,
	 end_time		time not null,
	 primary key (time_slot_id)
	);

create table if not exists section
	(course_id		varchar(20),
	 section_id		varchar(10), 
	 semester		varchar(6)
			check (semester in ('Fall', 'Winter', 'Spring', 'Summer')), 
	 year			numeric(4,0) check (year > 1990 and year < 2100), 
	 instructor_id		varchar(10),
	 classroom_id   	varchar(8),
	 time_slot_id		varchar(12),
	 capacity		numeric(3,0) default 15,
	 primary key (course_id, section_id, semester, year),
	 foreign key (course_id) references course (course_id)
		on delete cascade,
	 foreign key (instructor_id) references instructor (instructor_id)
		on delete set null,
	 foreign key (time_slot_id) references time_slot(time_slot_id)
		on delete set null
	);

create table if not exists take
	(student_id		varchar(10), 
	 course_id		varchar(8),
	 section_id		varchar(10), 
	 semester		varchar(6),
	 year			numeric(4,0),
	 grade		    	varchar(2)
		check (grade in ('A+', 'A', 'A-','B+', 'B', 'B-','C+', 'C', 'C-','D+', 'D', 'D-','F')), 
	 primary key (student_id, course_id, section_id, semester, year),
	 foreign key (course_id, section_id, semester, year) references 
	     section (course_id, section_id, semester, year)
		on delete cascade,
	 foreign key (student_id) references student (student_id)
		on delete cascade
	);

-- Create waitlist table
create table if not exists waitlist
	(student_id		varchar(10), 
	 course_id		varchar(20),
	 section_id		varchar(10), 
	 semester		varchar(6),
	 year			numeric(4,0),
	 waitlist_position INT,
	 waitlist_date	timestamp default current_timestamp,
	 primary key (student_id, course_id, section_id, semester, year),
	 foreign key (course_id, section_id, semester, year) references 
	     section (course_id, section_id, semester, year)
		on delete cascade,
	 foreign key (student_id) references student (student_id)
		on delete cascade
	);

create table if not exists classroom
	(classroom_id	varchar(8),
	 building		varchar(50),
	 room_number	varchar(10),
	 capacity		numeric(3,0) default 30,
	 primary key (classroom_id)
	);

create table if not exists prereq
	(course_id		varchar(20), 
	 prereq_id		varchar(20) not null,
	 primary key (course_id, prereq_id),
	 foreign key (course_id) references course (course_id)
		on delete cascade,
	 foreign key (prereq_id) references course (course_id)
	);

create table if not exists undergraduate
	(student_id		varchar(10), 
	 total_credits		int,
	 class_standing		varchar(10)
		check (class_standing in ('Freshman', 'Sophomore', 'Junior', 'Senior')), 	
	 primary key (student_id),
	 foreign key (student_id) references student (student_id)
		on delete cascade
	);
    
create table if not exists master
	(student_id		varchar(10), 
	 total_credits		int,	
	 primary key (student_id),
	 foreign key (student_id) references student (student_id)
		on delete cascade
	);

create table if not exists PhD
	(student_id			varchar(10), 
	 qualifier			varchar(30), 
	 proposal_defence_date		date,
	 dissertation_defence_date	date, 
	 primary key (student_id),
	 foreign key (student_id) references student (student_id)
		on delete cascade
	);
-- Add capacity column to existing section table if it doesn't exist
ALTER TABLE section ADD COLUMN IF NOT EXISTS capacity numeric(3,0) DEFAULT 15;

-- Inserting data with INSERT IGNORE to avoid duplicate key errors
INSERT IGNORE INTO course (course_id, course_name, credits)
VALUES 
('CS101', 'Introduction to Computer Science', 4),
('CS202', 'Data Structures and Algorithms', 3);

INSERT IGNORE INTO instructor (instructor_id, instructor_name, title, dept_name, email)
VALUES
('I001', 'Dr. John Doe', 'Professor', 'Computer Science', 'john.doe@example.com'),
('I002', 'Dr. Jane Smith', 'Assistant Professor', 'Computer Science', 'jane.smith@example.com');

INSERT IGNORE INTO time_slot (time_slot_id, day, start_time, end_time)
VALUES
('TS101', 'Monday', '09:00:00', '10:30:00'),
('TS102', 'Wednesday', '14:00:00', '15:30:00');

INSERT IGNORE INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id)
VALUES
('CS101', 'A01', 'Fall', 2025, 'I001', 'R101', 'TS101'),
('CS202', 'B01', 'Winter', 2025, 'I002', 'R202', 'TS102');

INSERT IGNORE INTO account(email, password, type) VALUES ('Abe_Lincoln@student.uml.edu', 'Lincoln12345!', 'student');
INSERT IGNORE INTO student(student_id, name, email, dept_name) VALUES('S3973011766', 'Abe Lincoln', 'Abe_Lincoln@student.uml.edu', 'Computer Science');
INSERT IGNORE INTO take(student_id, course_id, section_id, semester, year, grade) VALUES ('S3973011766', 'CS101', 'A01', 'Fall', 2025, Null);
UPDATE section SET capacity=capacity-1 WHERE (course_id = 'CS101')AND (section_id = 'A01');
INSERT IGNORE INTO account(email, password, type) VALUES ('John_Wayne@student.uml.edu', 'Wayne12345!', 'student');
INSERT IGNORE INTO student(student_id, name, email, dept_name) VALUES('S6934830240', 'John Wayne', 'John_Wayne@student.uml.edu', 'Computer Science');
INSERT IGNORE INTO take(student_id, course_id, section_id, semester, year, grade) VALUES ('S6934830240', 'CS101', 'A01', 'Fall', 2025, Null);
UPDATE section SET capacity=capacity-1 WHERE (course_id = 'CS101')AND (section_id = 'A01');
INSERT IGNORE INTO account(email, password, type) VALUES ('Mark_Yard@student.uml.edu', 'Yard12345!', 'student');
INSERT IGNORE INTO student(student_id, name, email, dept_name) VALUES('S6687589261', 'Mark Yard', 'Mark_Yard@student.uml.edu', 'Computer Science');
INSERT IGNORE INTO take(student_id, course_id, section_id, semester, year, grade) VALUES ('S6687589261', 'CS101', 'A01', 'Fall', 2025, Null);
UPDATE section SET capacity=capacity-1 WHERE (course_id = 'CS101')AND (section_id = 'A01');
INSERT IGNORE INTO account(email, password, type) VALUES ('Reggie_Palmer@student.uml.edu', 'Palmer12345!', 'student');
INSERT IGNORE INTO student(student_id, name, email, dept_name) VALUES('S4938311951', 'Reggie Palmer', 'Reggie_Palmer@student.uml.edu', 'Computer Science');
INSERT IGNORE INTO take(student_id, course_id, section_id, semester, year, grade) VALUES ('S4938311951', 'CS101', 'A01', 'Fall', 2025, Null);
UPDATE section SET capacity=capacity-1 WHERE (course_id = 'CS101')AND (section_id = 'A01');
INSERT IGNORE INTO account(email, password, type) VALUES ('Tom_Scran@student.uml.edu', 'Scran12345!', 'student');
INSERT IGNORE INTO student(student_id, name, email, dept_name) VALUES('S3009531222', 'Tom Scran', 'Tom_Scran@student.uml.edu', 'Computer Science');
INSERT IGNORE INTO take(student_id, course_id, section_id, semester, year, grade) VALUES ('S3009531222', 'CS101', 'A01', 'Fall', 2025, Null);
UPDATE section SET capacity=capacity-1 WHERE (course_id = 'CS101')AND (section_id = 'A01');
INSERT IGNORE INTO account(email, password, type) VALUES ('Grant_Fisher@student.uml.edu', 'Fisher12345!', 'student');
INSERT IGNORE INTO student(student_id, name, email, dept_name) VALUES('S9697663650', 'Grant Fisher', 'Grant_Fisher@student.uml.edu', 'Computer Science');
INSERT IGNORE INTO take(student_id, course_id, section_id, semester, year, grade) VALUES ('S9697663650', 'CS101', 'A01', 'Fall', 2025, Null);
UPDATE section SET capacity=capacity-1 WHERE (course_id = 'CS101')AND (section_id = 'A01');
INSERT IGNORE INTO account(email, password, type) VALUES ('Martha_Lime@student.uml.edu', 'Lime12345!', 'student');
INSERT IGNORE INTO student(student_id, name, email, dept_name) VALUES('S8553060731', 'Martha Lime', 'Martha_Lime@student.uml.edu', 'Computer Science');
INSERT IGNORE INTO take(student_id, course_id, section_id, semester, year, grade) VALUES ('S8553060731', 'CS101', 'A01', 'Fall', 2025, Null);
UPDATE section SET capacity=capacity-1 WHERE (course_id = 'CS101')AND (section_id = 'A01');
INSERT IGNORE INTO account(email, password, type) VALUES ('Bant_Jane@student.uml.edu', 'Jane12345!', 'student');
INSERT IGNORE INTO student(student_id, name, email, dept_name) VALUES('S8104631070', 'Bant Jane', 'Bant_Jane@student.uml.edu', 'Computer Science');
INSERT IGNORE INTO take(student_id, course_id, section_id, semester, year, grade) VALUES ('S8104631070', 'CS101', 'A01', 'Fall', 2025, Null);
UPDATE section SET capacity=capacity-1 WHERE (course_id = 'CS101')AND (section_id = 'A01');
INSERT IGNORE INTO account(email, password, type) VALUES ('Yan_Cran@student.uml.edu', 'Cran12345!', 'student');
INSERT IGNORE INTO student(student_id, name, email, dept_name) VALUES('S7545211217', 'Yan Cran', 'Yan_Cran@student.uml.edu', 'Computer Science');
INSERT IGNORE INTO take(student_id, course_id, section_id, semester, year, grade) VALUES ('S7545211217', 'CS101', 'A01', 'Fall', 2025, Null);
UPDATE section SET capacity=capacity-1 WHERE (course_id = 'CS101')AND (section_id = 'A01');
INSERT IGNORE INTO account(email, password, type) VALUES ('Dake_Lin@student.uml.edu', 'Lin12345!', 'student');
INSERT IGNORE INTO student(student_id, name, email, dept_name) VALUES('S3649993662', 'Dake Lin', 'Dake_Lin@student.uml.edu', 'Computer Science');
INSERT IGNORE INTO take(student_id, course_id, section_id, semester, year, grade) VALUES ('S3649993662', 'CS101', 'A01', 'Fall', 2025, Null);
UPDATE section SET capacity=capacity-1 WHERE (course_id = 'CS101')AND (section_id = 'A01');
INSERT IGNORE INTO account(email, password, type) VALUES ('Harry_Terr@student.uml.edu', 'Terr12345!', 'student');
INSERT IGNORE INTO student(student_id, name, email, dept_name) VALUES('S9039543029', 'Harry Terr', 'Harry_Terr@student.uml.edu', 'Computer Science');
INSERT IGNORE INTO take(student_id, course_id, section_id, semester, year, grade) VALUES ('S9039543029', 'CS101', 'A01', 'Fall', 2025, Null);
UPDATE section SET capacity=capacity-1 WHERE (course_id = 'CS101')AND (section_id = 'A01');
INSERT IGNORE INTO account(email, password, type) VALUES ('Boris_Johnson@student.uml.edu', 'Johnson12345!', 'student');
INSERT IGNORE INTO student(student_id, name, email, dept_name) VALUES('S4127207041', 'Boris Johnson', 'Boris_Johnson@student.uml.edu', 'Computer Science');
INSERT IGNORE INTO take(student_id, course_id, section_id, semester, year, grade) VALUES ('S4127207041', 'CS101', 'A01', 'Fall', 2025, Null);
UPDATE section SET capacity=capacity-1 WHERE (course_id = 'CS101')AND (section_id = 'A01');
INSERT IGNORE INTO account(email, password, type) VALUES ('Mark_Billson@student.uml.edu', 'Billson12345!', 'student');
INSERT IGNORE INTO student(student_id, name, email, dept_name) VALUES('S7317496443', 'Mark Billson', 'Mark_Billson@student.uml.edu', 'Computer Science');
INSERT IGNORE INTO take(student_id, course_id, section_id, semester, year, grade) VALUES ('S7317496443', 'CS101', 'A01', 'Fall', 2025, Null);
UPDATE section SET capacity=capacity-1 WHERE (course_id = 'CS101')AND (section_id = 'A01');
INSERT IGNORE INTO account(email, password, type) VALUES ('Cart_Fillson@student.uml.edu', 'Fillson12345!', 'student');
INSERT IGNORE INTO student(student_id, name, email, dept_name) VALUES('S4512850719', 'Cart Fillson', 'Cart_Fillson@student.uml.edu', 'Computer Science');
INSERT IGNORE INTO take(student_id, course_id, section_id, semester, year, grade) VALUES ('S4512850719', 'CS101', 'A01', 'Fall', 2025, Null);
UPDATE section SET capacity=capacity-1 WHERE (course_id = 'CS101')AND (section_id = 'A01');
INSERT IGNORE INTO account(email, password, type) VALUES ('Indi_Huff@student.uml.edu', 'Huff12345!', 'student');
INSERT IGNORE INTO student(student_id, name, email, dept_name) VALUES('S1958362369', 'Indi Huff', 'Indi_Huff@student.uml.edu', 'Computer Science');
INSERT IGNORE INTO take(student_id, course_id, section_id, semester, year, grade) VALUES ('S1958362369', 'CS101', 'A01', 'Fall', 2025, Null);
UPDATE section SET capacity=capacity-1 WHERE (course_id = 'CS101')AND (section_id = 'A01');


INSERT IGNORE course (course_id, course_name, credits) VALUES ('COMP1010', 'Computing I', 4);
INSERT IGNORE department (dept_name, location) VALUES ('Miner School of Computer & Information Sciences', 'Dandeneau Hall, 1 University Avenue, Lowell, MA 01854');
INSERT IGNORE account (email, password, type) VALUES ('Dane_Christensen@cs.uml.edu', '123456', 'instructor');
INSERT IGNORE instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('DChirstens', 'Dane Chirstensen', 'Professor', 'Miner School of Computer & Information Sciences', 'Dane_Christensen@cs.uml.edu');
INSERT IGNORE classroom (classroom_id, building, room_number, capacity) VALUES (30173110, 'Lydon Library', '110', 15);
INSERT IGNORE time_slot (time_slot_id, day, start_time, end_time) VALUES ('MWF0900_0950', 'MoWeFr', '09:00:00', '09:50:00');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '101', 'Fall', 2020, 'DChirstens', 30173110, 'MWF0900_0950');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '101', 'Fall', 2021, 'DChirstens', 30173110, 'MWF0900_0950');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '101', 'Fall', 2022, 'DChirstens', 30173110, 'MWF0900_0950');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '101', 'Fall', 2023, 'DChirstens', 30173110, 'MWF0900_0950');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '101', 'Fall', 2024, 'DChirstens', 30173110, 'MWF0900_0950');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '101', 'Fall', 2025, 'DChirstens', 30173110, 'MWF0900_0950');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '101', 'Fall', 2026, 'DChirstens', 30173110, 'MWF0900_0950');
INSERT IGNORE time_slot (time_slot_id, day, start_time, end_time) VALUES ('MWF1000_1050', 'MoWeFr', '10:00:00', '10:50:00');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '102', 'Fall', 2020, 'DChirstens', 30173110, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '102', 'Fall', 2021, 'DChirstens', 30173110, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '102', 'Fall', 2022, 'DChirstens', 30173110, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '102', 'Fall', 2023, 'DChirstens', 30173110, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '102', 'Fall', 2024, 'DChirstens', 30173110, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '102', 'Fall', 2025, 'DChirstens', 30173110, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '102', 'Fall', 2026, 'DChirstens', 30173110, 'MWF1000_1050');
INSERT IGNORE time_slot (time_slot_id, day, start_time, end_time) VALUES ('MWF1100_1150', 'MoWeFr', '11:00:00', '11:50:00');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '103', 'Fall', 2020, 'DChirstens', 30173110, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '103', 'Fall', 2021, 'DChirstens', 30173110, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '103', 'Fall', 2022, 'DChirstens', 30173110, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '103', 'Fall', 2023, 'DChirstens', 30173110, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '103', 'Fall', 2024, 'DChirstens', 30173110, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '103', 'Fall', 2025, 'DChirstens', 30173110, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '103', 'Fall', 2026, 'DChirstens', 30173110, 'MWF1100_1150');

INSERT IGNORE account (email, password, type) VALUES ('Yelena_Rykalova@cs.uml.edu', '123456', 'instructor');
INSERT IGNORE instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('YRykalova', 'Yelena Rykalova', 'Professor', 'Miner School of Computer & Information Sciences', 'Yelena_Rykalova@cs.uml.edu');
INSERT IGNORE classroom (classroom_id, building, room_number, capacity) VALUES (74275303, 'Shah Hall', '303', 15);
INSERT IGNORE time_slot (time_slot_id, day, start_time, end_time) VALUES ('TT1400_1515', 'TuTh', '14:00:00', '15:15:00');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '104', 'Fall', 2020, 'YRykalova', 74275303, 'TT1400_1515');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '104', 'Fall', 2021, 'YRykalova', 74275303, 'TT1400_1515');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '104', 'Fall', 2022, 'YRykalova', 74275303, 'TT1400_1515');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '104', 'Fall', 2023, 'YRykalova', 74275303, 'TT1400_1515');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '104', 'Fall', 2024, 'YRykalova', 74275303, 'TT1400_1515');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '104', 'Fall', 2025, 'YRykalova', 74275303, 'TT1400_1515');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '104', 'Fall', 2026, 'YRykalova', 74275303, 'TT1400_1515');

INSERT IGNORE account (email, password, type) VALUES ('Ryan_OConnell@cs.uml.edu', '123456', 'instructor');
INSERT IGNORE instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('ROConnell', 'Ryan OConnell', 'Professor', 'Miner School of Computer & Information Sciences', 'Ryan_OConnell@cs.uml.edu');
INSERT IGNORE classroom (classroom_id, building, room_number, capacity) VALUES (51328209, 'Falmouth Hall', '209', 15);
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '105', 'Fall', 2020, 'ROConnell', 51328209, 'MWF0900_0950');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '105', 'Fall', 2021, 'ROConnell', 51328209, 'MWF0900_0950');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '105', 'Fall', 2022, 'ROConnell', 51328209, 'MWF0900_0950');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '105', 'Fall', 2023, 'ROConnell', 51328209, 'MWF0900_0950');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '105', 'Fall', 2024, 'ROConnell', 51328209, 'MWF0900_0950');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '105', 'Fall', 2025, 'ROConnell', 51328209, 'MWF0900_0950');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '105', 'Fall', 2026, 'ROConnell', 51328209, 'MWF0900_0950');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '106', 'Fall', 2020, 'ROConnell', 51328209, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '106', 'Fall', 2021, 'ROConnell', 51328209, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '106', 'Fall', 2022, 'ROConnell', 51328209, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '106', 'Fall', 2023, 'ROConnell', 51328209, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '106', 'Fall', 2024, 'ROConnell', 51328209, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '106', 'Fall', 2025, 'ROConnell', 51328209, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '106', 'Fall', 2026, 'ROConnell', 51328209, 'MWF1000_1050');

INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '102', 'Spring', 2020, 'ROConnell', 51328209, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '102', 'Spring', 2021, 'ROConnell', 51328209, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '102', 'Spring', 2022, 'ROConnell', 51328209, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '102', 'Spring', 2023, 'ROConnell', 51328209, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '102', 'Spring', 2024, 'ROConnell', 51328209, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '102', 'Spring', 2025, 'ROConnell', 51328209, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '102', 'Spring', 2026, 'ROConnell', 51328209, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '103', 'Spring', 2020, 'ROConnell', 51328209, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '103', 'Spring', 2021, 'ROConnell', 51328209, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '103', 'Spring', 2022, 'ROConnell', 51328209, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '103', 'Spring', 2023, 'ROConnell', 51328209, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '103', 'Spring', 2024, 'ROConnell', 51328209, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '103', 'Spring', 2025, 'ROConnell', 51328209, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '103', 'Spring', 2026, 'ROConnell', 51328209, 'MWF1100_1150');

INSERT IGNORE course (course_id, course_name, credits) VALUES ('COMP1020', 'Computing II', 4);
INSERT IGNORE account (email, password, type) VALUES ('dadams@cs.uml.edu', '123456', 'instructor');
INSERT IGNORE instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('DAdams', 'David Adams', 'Professor', 'Miner School of Computer & Information Sciences', 'dadams@cs.uml.edu');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '101', 'Fall', 2020, 'DAdams', 74275303, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '101', 'Fall', 2021, 'DAdams', 74275303, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '101', 'Fall', 2022, 'DAdams', 74275303, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '101', 'Fall', 2023, 'DAdams', 74275303, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '101', 'Fall', 2024, 'DAdams', 74275303, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '101', 'Fall', 2025, 'DAdams', 74275303, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '101', 'Fall', 2026, 'DAdams', 74275303, 'MWF1100_1150');
INSERT IGNORE time_slot (time_slot_id, day, start_time, end_time) VALUES ('MWF1200_1250', 'MoWeFr', '12:00:00', '12:50:00');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '102', 'Fall', 2020, 'DAdams', 74275303, 'MWF1200_1250');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '102', 'Fall', 2021, 'DAdams', 74275303, 'MWF1200_1250');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '102', 'Fall', 2022, 'DAdams', 74275303, 'MWF1200_1250');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '102', 'Fall', 2023, 'DAdams', 74275303, 'MWF1200_1250');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '102', 'Fall', 2024, 'DAdams', 74275303, 'MWF1200_1250');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '102', 'Fall', 2025, 'DAdams', 74275303, 'MWF1200_1250');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '102', 'Fall', 2026, 'DAdams', 74275303, 'MWF1200_1250');

INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '101', 'Spring', 2020, 'YRykalova', 74275303, 'TT1400_1515');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '101', 'Spring', 2021, 'YRykalova', 74275303, 'TT1400_1515');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '101', 'Spring', 2022, 'YRykalova', 74275303, 'TT1400_1515');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '101', 'Spring', 2023, 'YRykalova', 74275303, 'TT1400_1515');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '101', 'Spring', 2024, 'YRykalova', 74275303, 'TT1400_1515');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '101', 'Spring', 2025, 'YRykalova', 74275303, 'TT1400_1515');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '101', 'Spring', 2026, 'YRykalova', 74275303, 'TT1400_1515');

INSERT IGNORE account (email, password, type) VALUES ('Johannes_Weis@cs.uml.edu', '123456', 'instructor');
INSERT IGNORE instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('JWeis', 'Johannes Weis', 'Professor', 'Miner School of Computer & Information Sciences', 'Johannes_Weis@cs.uml.edu');
INSERT IGNORE classroom (classroom_id, building, room_number, capacity) VALUES (12345503, 'Olsen', '503', 15);
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '102', 'Spring', 2020, 'JWeis', 12345503, 'MWF0900_0950');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '102', 'Spring', 2021, 'JWeis', 12345503, 'MWF0900_0950');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '102', 'Spring', 2022, 'JWeis', 12345503, 'MWF0900_0950');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '102', 'Spring', 2023, 'JWeis', 12345503, 'MWF0900_0950');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '102', 'Spring', 2024, 'JWeis', 12345503, 'MWF0900_0950');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '102', 'Spring', 2025, 'JWeis', 12345503, 'MWF0900_0950');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '102', 'Spring', 2026, 'JWeis', 12345503, 'MWF0900_0950');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '103', 'Spring', 2020, 'JWeis', 12345503, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '103', 'Spring', 2021, 'JWeis', 12345503, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '103', 'Spring', 2022, 'JWeis', 12345503, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '103', 'Spring', 2023, 'JWeis', 12345503, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '103', 'Spring', 2024, 'JWeis', 12345503, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '103', 'Spring', 2025, 'JWeis', 12345503, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '103', 'Spring', 2026, 'JWeis', 12345503, 'MWF1000_1050');

INSERT IGNORE prereq (course_id, prereq_id) VALUES ('COMP1020', 'COMP1010');
INSERT IGNORE course (course_id, course_name, credits) VALUES ('COMP2010', 'Computing III', 4);
INSERT IGNORE time_slot (time_slot_id, day, start_time, end_time) VALUES ('TT0930_1045', 'TuTh', '09:30:00', '10:45:00');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '101', 'Fall', 2020, 'YRykalova', 74275303, 'TT0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '101', 'Fall', 2021, 'YRykalova', 74275303, 'TT0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '101', 'Fall', 2022, 'YRykalova', 74275303, 'TT0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '101', 'Fall', 2023, 'YRykalova', 74275303, 'TT0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '101', 'Fall', 2024, 'YRykalova', 74275303, 'TT0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '101', 'Fall', 2025, 'YRykalova', 74275303, 'TT0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '101', 'Fall', 2026, 'YRykalova', 74275303, 'TT0930_1045');

INSERT IGNORE account (email, password, type) VALUES ('Sirong_Lin@cs.uml.edu', '123456', 'instructor');
INSERT IGNORE instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('SLin', 'Sirong Lin', 'Professor', 'Miner School of Computer & Information Sciences', 'Sirong_Lin@cs.uml.edu');
INSERT IGNORE classroom (classroom_id, building, room_number, capacity) VALUES (12345408, 'Olsen', '408', 15);
INSERT IGNORE time_slot (time_slot_id, day, start_time, end_time) VALUES ('TT1100_1215', 'TuTh', '11:00:00', '12:15:00');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '101', 'Spring', 2020, 'SLin', 12345408, 'TT1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '101', 'Spring', 2021, 'SLin', 12345408, 'TT1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '101', 'Spring', 2022, 'SLin', 12345408, 'TT1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '101', 'Spring', 2023, 'SLin', 12345408, 'TT1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '101', 'Spring', 2024, 'SLin', 12345408, 'TT1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '101', 'Spring', 2025, 'SLin', 12345408, 'TT1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '101', 'Spring', 2026, 'SLin', 12345408, 'TT1100_1215');

INSERT IGNORE account (email, password, type) VALUES ('Charles_Wilkes@cs.uml.edu', '123456', 'instructor');
INSERT IGNORE instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('CWilkes', 'Charles Wilkes', 'Professor', 'Miner School of Computer & Information Sciences', 'Charles_Wilkes@cs.uml.edu');
INSERT IGNORE classroom (classroom_id, building, room_number, capacity) VALUES (12345330, 'Olsen', '330', 15);
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '102', 'Spring', 2020, 'CWilkes', 12345330, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '102', 'Spring', 2021, 'CWilkes', 12345330, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '102', 'Spring', 2022, 'CWilkes', 12345330, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '102', 'Spring', 2023, 'CWilkes', 12345330, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '102', 'Spring', 2024, 'CWilkes', 12345330, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '102', 'Spring', 2025, 'CWilkes', 12345330, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '102', 'Spring', 2026, 'CWilkes', 12345330, 'MWF1000_1050');

INSERT IGNORE prereq (course_id, prereq_id) VALUES ('COMP2010', 'COMP1020');
INSERT IGNORE course (course_id, course_name, credits) VALUES ('COMP2040', 'Computing IV', 4);
INSERT IGNORE account (email, password, type) VALUES ('James_Daly@cs.uml.edu', '123456', 'instructor');
INSERT IGNORE instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('JDaly', 'James Daly', 'Professor', 'Miner School of Computer & Information Sciences', 'James_Daly@cs.uml.edu');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '201', 'Fall', 2020, 'JDaly', 51328209, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '201', 'Fall', 2021, 'JDaly', 51328209, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '201', 'Fall', 2022, 'JDaly', 51328209, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '201', 'Fall', 2023, 'JDaly', 51328209, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '201', 'Fall', 2024, 'JDaly', 51328209, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '201', 'Fall', 2025, 'JDaly', 51328209, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '201', 'Fall', 2026, 'JDaly', 51328209, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '202', 'Fall', 2020, 'JDaly', 51328209, 'MWF1200_1250');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '202', 'Fall', 2021, 'JDaly', 51328209, 'MWF1200_1250');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '202', 'Fall', 2022, 'JDaly', 51328209, 'MWF1200_1250');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '202', 'Fall', 2023, 'JDaly', 51328209, 'MWF1200_1250');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '202', 'Fall', 2024, 'JDaly', 51328209, 'MWF1200_1250');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '202', 'Fall', 2025, 'JDaly', 51328209, 'MWF1200_1250');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '202', 'Fall', 2026, 'JDaly', 51328209, 'MWF1200_1250');

INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '201', 'Spring', 2020, 'JDaly', 51328209, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '201', 'Spring', 2021, 'JDaly', 51328209, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '201', 'Spring', 2022, 'JDaly', 51328209, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '201', 'Spring', 2023, 'JDaly', 51328209, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '201', 'Spring', 2024, 'JDaly', 51328209, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '201', 'Spring', 2025, 'JDaly', 51328209, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '201', 'Spring', 2026, 'JDaly', 51328209, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '202', 'Spring', 2020, 'JDaly', 51328209, 'MWF1200_1250');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '202', 'Spring', 2021, 'JDaly', 51328209, 'MWF1200_1250');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '202', 'Spring', 2022, 'JDaly', 51328209, 'MWF1200_1250');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '202', 'Spring', 2023, 'JDaly', 51328209, 'MWF1200_1250');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '202', 'Spring', 2024, 'JDaly', 51328209, 'MWF1200_1250');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '202', 'Spring', 2025, 'JDaly', 51328209, 'MWF1200_1250');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '202', 'Spring', 2026, 'JDaly', 51328209, 'MWF1200_1250');

INSERT IGNORE classroom (classroom_id, building, room_number, capacity) VALUES (51328313, 'Falmouth Hall', '313', 15);
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '203', 'Spring', 2020, 'YRykalova', 51328313, 'TT0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '203', 'Spring', 2021, 'YRykalova', 51328313, 'TT0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '203', 'Spring', 2022, 'YRykalova', 51328313, 'TT0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '203', 'Spring', 2023, 'YRykalova', 51328313, 'TT0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '203', 'Spring', 2024, 'YRykalova', 51328313, 'TT0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '203', 'Spring', 2025, 'YRykalova', 51328313, 'TT0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '203', 'Spring', 2026, 'YRykalova', 51328313, 'TT0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '204', 'Spring', 2020, 'YRykalova', 51328313, 'TT1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '204', 'Spring', 2021, 'YRykalova', 51328313, 'TT1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '204', 'Spring', 2022, 'YRykalova', 51328313, 'TT1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '204', 'Spring', 2023, 'YRykalova', 51328313, 'TT1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '204', 'Spring', 2024, 'YRykalova', 51328313, 'TT1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '204', 'Spring', 2025, 'YRykalova', 51328313, 'TT1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '204', 'Spring', 2026, 'YRykalova', 51328313, 'TT1100_1215');

INSERT IGNORE prereq (course_id, prereq_id) VALUES ('COMP2040', 'COMP2010');
INSERT IGNORE course (course_id, course_name, credits) VALUES ('ENGL1010', 'College Writing I', 3);
INSERT IGNORE department (dept_name, location) VALUES ('English Department', 'OLeary Library, 61 Wilder Street, Lowell, MA 01854');
INSERT IGNORE account (email, password, type) VALUES ('Michael_Baron@uml.edu', '123456', 'instructor');
INSERT IGNORE instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('MBaron', 'Michael Baron', 'Professor', 'English Department', 'Michael_Baron@uml.edu');
INSERT IGNORE classroom (classroom_id, building, room_number, capacity) VALUES (12345353, 'Olsen', '353', 15);
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '202', 'Fall', 2020, 'MBaron', 12345353, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '202', 'Fall', 2021, 'MBaron', 12345353, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '202', 'Fall', 2022, 'MBaron', 12345353, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '202', 'Fall', 2023, 'MBaron', 12345353, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '202', 'Fall', 2024, 'MBaron', 12345353, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '202', 'Fall', 2025, 'MBaron', 12345353, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '202', 'Fall', 2026, 'MBaron', 12345353, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '203', 'Fall', 2020, 'MBaron', 12345353, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '203', 'Fall', 2021, 'MBaron', 12345353, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '203', 'Fall', 2022, 'MBaron', 12345353, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '203', 'Fall', 2023, 'MBaron', 12345353, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '203', 'Fall', 2024, 'MBaron', 12345353, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '203', 'Fall', 2025, 'MBaron', 12345353, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '203', 'Fall', 2026, 'MBaron', 12345353, 'MWF1100_1150');

INSERT IGNORE account (email, password, type) VALUES ('Jason_Bellipanni@uml.edu', '123456', 'instructor');
INSERT IGNORE instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('JBellipann', 'Jason Bellipanni', 'Professor', 'English Department', 'Jason_Bellipanni@uml.edu');
INSERT IGNORE classroom (classroom_id, building, room_number, capacity) VALUES (12345349, 'Olsen', '349', 15);
INSERT IGNORE time_slot (time_slot_id, day, start_time, end_time) VALUES ('MWF0800_0850', 'MoWeFr', '08:00:00', '08:50:00');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '204', 'Fall', 2020, 'JBellipann', 12345349, 'MWF0800_0850');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '204', 'Fall', 2021, 'JBellipann', 12345349, 'MWF0800_0850');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '204', 'Fall', 2022, 'JBellipann', 12345349, 'MWF0800_0850');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '204', 'Fall', 2023, 'JBellipann', 12345349, 'MWF0800_0850');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '204', 'Fall', 2024, 'JBellipann', 12345349, 'MWF0800_0850');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '204', 'Fall', 2025, 'JBellipann', 12345349, 'MWF0800_0850');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '204', 'Fall', 2026, 'JBellipann', 12345349, 'MWF0800_0850');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '205', 'Fall', 2020, 'JBellipann', 12345349, 'MWF0900_0950');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '205', 'Fall', 2021, 'JBellipann', 12345349, 'MWF0900_0950');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '205', 'Fall', 2022, 'JBellipann', 12345349, 'MWF0900_0950');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '205', 'Fall', 2023, 'JBellipann', 12345349, 'MWF0900_0950');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '205', 'Fall', 2024, 'JBellipann', 12345349, 'MWF0900_0950');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '205', 'Fall', 2025, 'JBellipann', 12345349, 'MWF0900_0950');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '205', 'Fall', 2026, 'JBellipann', 12345349, 'MWF0900_0950');

INSERT IGNORE account (email, password, type) VALUES ('Darrin_Berard@uml.edu', '123456', 'instructor');
INSERT IGNORE instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('DBerard', 'Darrin Berard', 'Professor', 'English Department', 'Darrin_Berard@uml.edu');
INSERT IGNORE classroom (classroom_id, building, room_number, capacity) VALUES (12345106, 'Olsen', '106', 15);
INSERT IGNORE time_slot (time_slot_id, day, start_time, end_time) VALUES ('MW0330_0445', 'MoWe', '03:30:00', '04:45:00');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '206', 'Fall', 2020, 'DBerard', 12345106, 'MW0330_0445');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '206', 'Fall', 2021, 'DBerard', 12345106, 'MW0330_0445');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '206', 'Fall', 2022, 'DBerard', 12345106, 'MW0330_0445');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '206', 'Fall', 2023, 'DBerard', 12345106, 'MW0330_0445');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '206', 'Fall', 2024, 'DBerard', 12345106, 'MW0330_0445');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '206', 'Fall', 2025, 'DBerard', 12345106, 'MW0330_0445');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '206', 'Fall', 2026, 'DBerard', 12345106, 'MW0330_0445');
INSERT IGNORE time_slot (time_slot_id, day, start_time, end_time) VALUES ('MW1700_1815', 'MoWe', '17:00:00', '18:15:00');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '207', 'Fall', 2020, 'DBerard', 12345106, 'MW1700_1815');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '207', 'Fall', 2021, 'DBerard', 12345106, 'MW1700_1815');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '207', 'Fall', 2022, 'DBerard', 12345106, 'MW1700_1815');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '207', 'Fall', 2023, 'DBerard', 12345106, 'MW1700_1815');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '207', 'Fall', 2024, 'DBerard', 12345106, 'MW1700_1815');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '207', 'Fall', 2025, 'DBerard', 12345106, 'MW1700_1815');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '207', 'Fall', 2026, 'DBerard', 12345106, 'MW1700_1815');

INSERT IGNORE classroom (classroom_id, building, room_number, capacity) VALUES (59237107, 'Perry Hall', '107', 15);
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '203', 'Spring', 2020, 'MBaron', 59237107, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '203', 'Spring', 2021, 'MBaron', 59237107, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '203', 'Spring', 2022, 'MBaron', 59237107, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '203', 'Spring', 2023, 'MBaron', 59237107, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '203', 'Spring', 2024, 'MBaron', 59237107, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '203', 'Spring', 2025, 'MBaron', 59237107, 'MWF1000_1050');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '203', 'Spring', 2026, 'MBaron', 59237107, 'MWF1000_1050');

INSERT IGNORE account (email, password, type) VALUES ('Theresa_DeFranzo@uml.edu', '123456', 'instructor');
INSERT IGNORE instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('TDeFranzo', 'Theresa DeFranzo', 'Professor', 'English Department', 'Theresa_DeFranzo@uml.edu');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '205', 'Spring', 2020, 'TDeFranzo', 12345349, 'TT0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '205', 'Spring', 2021, 'TDeFranzo', 12345349, 'TT0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '205', 'Spring', 2022, 'TDeFranzo', 12345349, 'TT0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '205', 'Spring', 2023, 'TDeFranzo', 12345349, 'TT0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '205', 'Spring', 2024, 'TDeFranzo', 12345349, 'TT0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '205', 'Spring', 2025, 'TDeFranzo', 12345349, 'TT0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '205', 'Spring', 2026, 'TDeFranzo', 12345349, 'TT0930_1045');

INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '207', 'Spring', 2020, 'MBaron', 59237107, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '207', 'Spring', 2021, 'MBaron', 59237107, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '207', 'Spring', 2022, 'MBaron', 59237107, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '207', 'Spring', 2023, 'MBaron', 59237107, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '207', 'Spring', 2024, 'MBaron', 59237107, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '207', 'Spring', 2025, 'MBaron', 59237107, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '207', 'Spring', 2026, 'MBaron', 59237107, 'MWF1100_1150');

INSERT IGNORE course (course_id, course_name, credits) VALUES ('MATH1310', 'Calculus I', 4);
INSERT IGNORE department (dept_name, location) VALUES ('Department of Mathematics and Statistics', 'Southwick Hall, 1 University Ave, Lowell, MA 01854');
INSERT IGNORE account (email, password, type) VALUES ('Theresa_Schille@uml.edu', '123456', 'instructor');
INSERT IGNORE instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('TSchille', 'Theresa Schille', 'Professor', 'Department of Mathematics and Statistics', 'Theresa_Schille@uml.edu');
INSERT IGNORE classroom (classroom_id, building, room_number, capacity) VALUES (12345407, 'Olsen', '407', 15);
INSERT IGNORE time_slot (time_slot_id, day, start_time, end_time) VALUES ('MWF0930_1045', 'MoWeFr', '09:30:00', '10:45:00');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '201', 'Fall', 2020, 'TSchille', 12345407, 'MWF0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '201', 'Fall', 2021, 'TSchille', 12345407, 'MWF0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '201', 'Fall', 2022, 'TSchille', 12345407, 'MWF0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '201', 'Fall', 2023, 'TSchille', 12345407, 'MWF0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '201', 'Fall', 2024, 'TSchille', 12345407, 'MWF0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '201', 'Fall', 2025, 'TSchille', 12345407, 'MWF0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '201', 'Fall', 2026, 'TSchille', 12345407, 'MWF0930_1045');

INSERT IGNORE account (email, password, type) VALUES ('Sunghye_Yeh@uml.edu', '123456', 'instructor');
INSERT IGNORE instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('SYeh', 'Sunghye Yeh', 'Professor', 'Department of Mathematics and Statistics', 'Sunghye_Yeh@uml.edu');
INSERT IGNORE time_slot (time_slot_id, day, start_time, end_time) VALUES ('MWF1100_1215', 'MoWeFr', '11:00:00', '12:15:00');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '202', 'Fall', 2020, 'SYeh', 12345407, 'MWF1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '202', 'Fall', 2021, 'SYeh', 12345407, 'MWF1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '202', 'Fall', 2022, 'SYeh', 12345407, 'MWF1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '202', 'Fall', 2023, 'SYeh', 12345407, 'MWF1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '202', 'Fall', 2024, 'SYeh', 12345407, 'MWF1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '202', 'Fall', 2025, 'SYeh', 12345407, 'MWF1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '202', 'Fall', 2026, 'SYeh', 12345407, 'MWF1100_1215');

INSERT IGNORE account (email, password, type) VALUES ('Jennifer_GonzalezZugasti@uml.edu', '123456', 'instructor');
INSERT IGNORE instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('JGonzalezZ', 'Jennifer GonzalezZugasti', 'Professor', 'Department of Mathematics and Statistics', 'Jennifer_GonzalezZugasti@uml.edu');
INSERT IGNORE time_slot (time_slot_id, day, start_time, end_time) VALUES ('MWF1230_1345', 'MoWeFr', '12:30:00', '13:45:00');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '203', 'Fall', 2020, 'JGonzalezZ', 51328313, 'MWF1230_1345');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '203', 'Fall', 2021, 'JGonzalezZ', 51328313, 'MWF1230_1345');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '203', 'Fall', 2022, 'JGonzalezZ', 51328313, 'MWF1230_1345');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '203', 'Fall', 2023, 'JGonzalezZ', 51328313, 'MWF1230_1345');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '203', 'Fall', 2024, 'JGonzalezZ', 51328313, 'MWF1230_1345');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '203', 'Fall', 2025, 'JGonzalezZ', 51328313, 'MWF1230_1345');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '203', 'Fall', 2026, 'JGonzalezZ', 51328313, 'MWF1230_1345');

INSERT IGNORE account (email, password, type) VALUES ('Jeanne_Derosa@uml.edu', '123456', 'instructor');
INSERT IGNORE instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('JDerosa', 'Jeanne Derosa', 'Professor', 'Department of Mathematics and Statistics', 'Jeanne_Derosa@uml.edu');
INSERT IGNORE time_slot (time_slot_id, day, start_time, end_time) VALUES ('MWF1700_1815', 'MoWeFr', '17:00:00', '18:15:00');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '204', 'Fall', 2020, 'JDerosa', 51328313, 'MWF1700_1815');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '204', 'Fall', 2021, 'JDerosa', 51328313, 'MWF1700_1815');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '204', 'Fall', 2022, 'JDerosa', 51328313, 'MWF1700_1815');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '204', 'Fall', 2023, 'JDerosa', 51328313, 'MWF1700_1815');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '204', 'Fall', 2024, 'JDerosa', 51328313, 'MWF1700_1815');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '204', 'Fall', 2025, 'JDerosa', 51328313, 'MWF1700_1815');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '204', 'Fall', 2026, 'JDerosa', 51328313, 'MWF1700_1815');

INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '201', 'Spring', 2020, 'SYeh', 51328313, 'MWF0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '201', 'Spring', 2021, 'SYeh', 51328313, 'MWF0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '201', 'Spring', 2022, 'SYeh', 51328313, 'MWF0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '201', 'Spring', 2023, 'SYeh', 51328313, 'MWF0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '201', 'Spring', 2024, 'SYeh', 51328313, 'MWF0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '201', 'Spring', 2025, 'SYeh', 51328313, 'MWF0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '201', 'Spring', 2026, 'SYeh', 51328313, 'MWF0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '202', 'Spring', 2020, 'SYeh', 51328313, 'MWF1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '202', 'Spring', 2021, 'SYeh', 51328313, 'MWF1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '202', 'Spring', 2022, 'SYeh', 51328313, 'MWF1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '202', 'Spring', 2023, 'SYeh', 51328313, 'MWF1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '202', 'Spring', 2024, 'SYeh', 51328313, 'MWF1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '202', 'Spring', 2025, 'SYeh', 51328313, 'MWF1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '202', 'Spring', 2026, 'SYeh', 51328313, 'MWF1100_1215');

INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '204', 'Spring', 2020, 'SYeh', 51328313, 'MWF1230_1345');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '204', 'Spring', 2021, 'SYeh', 51328313, 'MWF1230_1345');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '204', 'Spring', 2022, 'SYeh', 51328313, 'MWF1230_1345');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '204', 'Spring', 2023, 'SYeh', 51328313, 'MWF1230_1345');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '204', 'Spring', 2024, 'SYeh', 51328313, 'MWF1230_1345');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '204', 'Spring', 2025, 'SYeh', 51328313, 'MWF1230_1345');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '204', 'Spring', 2026, 'SYeh', 51328313, 'MWF1230_1345');

INSERT IGNORE course (course_id, course_name, credits) VALUES ('ENGL1020', 'College Writing II', 3);
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '201', 'Fall', 2020, 'TDeFranzo', 12345349, 'MWF1200_1250');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '201', 'Fall', 2021, 'TDeFranzo', 12345349, 'MWF1200_1250');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '201', 'Fall', 2022, 'TDeFranzo', 12345349, 'MWF1200_1250');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '201', 'Fall', 2023, 'TDeFranzo', 12345349, 'MWF1200_1250');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '201', 'Fall', 2024, 'TDeFranzo', 12345349, 'MWF1200_1250');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '201', 'Fall', 2025, 'TDeFranzo', 12345349, 'MWF1200_1250');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '201', 'Fall', 2026, 'TDeFranzo', 12345349, 'MWF1200_1250');

INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '204', 'Fall', 2020, 'JBellipann', 59237107, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '204', 'Fall', 2021, 'JBellipann', 59237107, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '204', 'Fall', 2022, 'JBellipann', 59237107, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '204', 'Fall', 2023, 'JBellipann', 59237107, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '204', 'Fall', 2024, 'JBellipann', 59237107, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '204', 'Fall', 2025, 'JBellipann', 59237107, 'MWF1100_1150');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '204', 'Fall', 2026, 'JBellipann', 59237107, 'MWF1100_1150');

INSERT IGNORE account (email, password, type) VALUES ('Timothy_Rogers@uml.edu', '123456', 'instructor');
INSERT IGNORE instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('TRogers', 'Timothy Rogers', 'Professor', 'English Department', 'Timothy_Rogers@uml.edu');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '208', 'Fall', 2020, 'TRogers', 12345353, 'TT1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '208', 'Fall', 2021, 'TRogers', 12345353, 'TT1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '208', 'Fall', 2022, 'TRogers', 12345353, 'TT1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '208', 'Fall', 2023, 'TRogers', 12345353, 'TT1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '208', 'Fall', 2024, 'TRogers', 12345353, 'TT1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '208', 'Fall', 2025, 'TRogers', 12345353, 'TT1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '208', 'Fall', 2026, 'TRogers', 12345353, 'TT1100_1215');

INSERT IGNORE account (email, password, type) VALUES ('Sara_Backer@uml.edu', '123456', 'instructor');
INSERT IGNORE instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('SBacker', 'Sara Backer', 'Professor', 'English Department', 'Sara_Backer@uml.edu');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '201', 'Spring', 2020, 'SBacker', 59237107, 'TT0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '201', 'Spring', 2021, 'SBacker', 59237107, 'TT0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '201', 'Spring', 2022, 'SBacker', 59237107, 'TT0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '201', 'Spring', 2023, 'SBacker', 59237107, 'TT0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '201', 'Spring', 2024, 'SBacker', 59237107, 'TT0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '201', 'Spring', 2025, 'SBacker', 59237107, 'TT0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '201', 'Spring', 2026, 'SBacker', 59237107, 'TT0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '202', 'Spring', 2020, 'SBacker', 59237107, 'TT1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '202', 'Spring', 2021, 'SBacker', 59237107, 'TT1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '202', 'Spring', 2022, 'SBacker', 59237107, 'TT1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '202', 'Spring', 2023, 'SBacker', 59237107, 'TT1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '202', 'Spring', 2024, 'SBacker', 59237107, 'TT1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '202', 'Spring', 2025, 'SBacker', 59237107, 'TT1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '202', 'Spring', 2026, 'SBacker', 59237107, 'TT1100_1215');

INSERT IGNORE prereq (course_id, prereq_id) VALUES ('ENGL1020', 'ENGL1010');
INSERT IGNORE course (course_id, course_name, credits) VALUES ('MATH1320', 'Calculus II', 4);
INSERT IGNORE account (email, password, type) VALUES ('Howard_Troughton@uml.edu', '123456', 'instructor');
INSERT IGNORE instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('HTroughton', 'Howard Troughton', 'Professor', 'Department of Mathematics and Statistics', 'Howard_Troughton@uml.edu');
INSERT IGNORE classroom (classroom_id, building, room_number, capacity) VALUES (12345405, 'Olsen', '405', 15);
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '201', 'Fall', 2020, 'HTroughton', 12345405, 'MWF0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '201', 'Fall', 2021, 'HTroughton', 12345405, 'MWF0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '201', 'Fall', 2022, 'HTroughton', 12345405, 'MWF0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '201', 'Fall', 2023, 'HTroughton', 12345405, 'MWF0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '201', 'Fall', 2024, 'HTroughton', 12345405, 'MWF0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '201', 'Fall', 2025, 'HTroughton', 12345405, 'MWF0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '201', 'Fall', 2026, 'HTroughton', 12345405, 'MWF0930_1045');

INSERT IGNORE account (email, password, type) VALUES ('Carly_Briggs@uml.edu', '123456', 'instructor');
INSERT IGNORE instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('CBriggs', 'Carly Briggs', 'Professor', 'Department of Mathematics and Statistics', 'Carly_Briggs@uml.edu');
INSERT IGNORE classroom (classroom_id, building, room_number, capacity) VALUES (51328309, 'Falmouth Hall', '309', 15);
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '202', 'Fall', 2020, 'CBriggs', 51328309, 'MWF1230_1345');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '202', 'Fall', 2021, 'CBriggs', 51328309, 'MWF1230_1345');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '202', 'Fall', 2022, 'CBriggs', 51328309, 'MWF1230_1345');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '202', 'Fall', 2023, 'CBriggs', 51328309, 'MWF1230_1345');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '202', 'Fall', 2024, 'CBriggs', 51328309, 'MWF1230_1345');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '202', 'Fall', 2025, 'CBriggs', 51328309, 'MWF1230_1345');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '202', 'Fall', 2026, 'CBriggs', 51328309, 'MWF1230_1345');

INSERT IGNORE account (email, password, type) VALUES ('Thoa_Tran@uml.edu', '123456', 'instructor');
INSERT IGNORE instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('TTran', 'Thoa Tran', 'Professor', 'Department of Mathematics and Statistics', 'Thoa_Tran@uml.edu');
INSERT IGNORE time_slot (time_slot_id, day, start_time, end_time) VALUES ('MWF1400_1515', 'MoWeFr', '14:00:00', '15:15:00');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '203', 'Fall', 2020, 'TTran', 51328313, 'MWF1400_1515');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '203', 'Fall', 2021, 'TTran', 51328313, 'MWF1400_1515');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '203', 'Fall', 2022, 'TTran', 51328313, 'MWF1400_1515');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '203', 'Fall', 2023, 'TTran', 51328313, 'MWF1400_1515');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '203', 'Fall', 2024, 'TTran', 51328313, 'MWF1400_1515');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '203', 'Fall', 2025, 'TTran', 51328313, 'MWF1400_1515');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '203', 'Fall', 2026, 'TTran', 51328313, 'MWF1400_1515');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '204', 'Fall', 2020, 'TTran', 51328313, 'MWF1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '204', 'Fall', 2021, 'TTran', 51328313, 'MWF1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '204', 'Fall', 2022, 'TTran', 51328313, 'MWF1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '204', 'Fall', 2023, 'TTran', 51328313, 'MWF1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '204', 'Fall', 2024, 'TTran', 51328313, 'MWF1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '204', 'Fall', 2025, 'TTran', 51328313, 'MWF1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '204', 'Fall', 2026, 'TTran', 51328313, 'MWF1100_1215');

INSERT IGNORE classroom (classroom_id, building, room_number, capacity) VALUES (12345109, 'Olsen', '109', 15);
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '202', 'Spring', 2020, 'HTroughton', 12345109, 'MWF0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '202', 'Spring', 2021, 'HTroughton', 12345109, 'MWF0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '202', 'Spring', 2022, 'HTroughton', 12345109, 'MWF0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '202', 'Spring', 2023, 'HTroughton', 12345109, 'MWF0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '202', 'Spring', 2024, 'HTroughton', 12345109, 'MWF0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '202', 'Spring', 2025, 'HTroughton', 12345109, 'MWF0930_1045');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '202', 'Spring', 2026, 'HTroughton', 12345109, 'MWF0930_1045');

INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '204', 'Spring', 2020, 'HTroughton', 12345109, 'MWF1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '204', 'Spring', 2021, 'HTroughton', 12345109, 'MWF1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '204', 'Spring', 2022, 'HTroughton', 12345109, 'MWF1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '204', 'Spring', 2023, 'HTroughton', 12345109, 'MWF1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '204', 'Spring', 2024, 'HTroughton', 12345109, 'MWF1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '204', 'Spring', 2025, 'HTroughton', 12345109, 'MWF1100_1215');
INSERT IGNORE section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '204', 'Spring', 2026, 'HTroughton', 12345109, 'MWF1100_1215');

INSERT IGNORE prereq (course_id, prereq_id) VALUES ('MATH1320', 'MATH1310');
INSERT IGNORE account (email, password, type) VALUES ('_ADMIN@admin.uml.edu', 'ADMIN12345!', 'admin');
INSERT IGNORE account (email, password, type) VALUES ('Reggie_Palmer@student.uml.edu', 'Palmer12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('5851120895', 'Reggie Palmer', 'Reggie_Palmer@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('5851120895', NULL, 'Freshman');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('5851120895', 'COMP1010', '102', 'Fall', 2024, 'A');
INSERT IGNORE account (email, password, type) VALUES ('Tom_Scran@student.uml.edu', 'Scran12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('7167426597', 'Tom Scran', 'Tom_Scran@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('7167426597', NULL, 'Freshman');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('7167426597', 'COMP1010', '102', 'Fall', 2024, 'A');
INSERT IGNORE account (email, password, type) VALUES ('Martha_Lime@student.uml.edu', 'Lime12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('9004953223', 'Martha Lime', 'Martha_Lime@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('9004953223', NULL, 'Freshman');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('9004953223', 'COMP1010', '102', 'Fall', 2024, 'A');
INSERT IGNORE account (email, password, type) VALUES ('Grant_Fisher@student.uml.edu', 'Fisher12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('2464803865', 'Grant Fisher', 'Grant_Fisher@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('2464803865', NULL, 'Freshman');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('2464803865', 'COMP1010', '102', 'Fall', 2024, 'A');
INSERT IGNORE account (email, password, type) VALUES ('Bant_Jane@student.uml.edu', 'Jane12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('3120045267', 'Bant Jane', 'Bant_Jane@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('3120045267', NULL, 'Freshman');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('3120045267', 'COMP1010', '102', 'Fall', 2024, 'A');
INSERT IGNORE account (email, password, type) VALUES ('Yan_Cran@student.uml.edu', 'Cran12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('8750034020', 'Yan Cran', 'Yan_Cran@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('8750034020', NULL, 'Freshman');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('8750034020', 'COMP1010', '102', 'Fall', 2024, 'B');
INSERT IGNORE account (email, password, type) VALUES ('Dake_Lin@student.uml.edu', 'Lin12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('3722584580', 'Dake Lin', 'Dake_Lin@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('3722584580', NULL, 'Freshman');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('3722584580', 'COMP1010', '102', 'Fall', 2024, 'B');
INSERT IGNORE account (email, password, type) VALUES ('Harry_Terr@student.uml.edu', 'Terr12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('4402123070', 'Harry Terr', 'Harry_Terr@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('4402123070', NULL, 'Freshman');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('4402123070', 'COMP1010', '102', 'Fall', 2024, 'B');
INSERT IGNORE account (email, password, type) VALUES ('Boris_Johnson@student.uml.edu', 'Johnson12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('3333945716', 'Boris Johnson', 'Boris_Johnson@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('3333945716', NULL, 'Freshman');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('3333945716', 'COMP1010', '102', 'Fall', 2024, 'B');
INSERT IGNORE account (email, password, type) VALUES ('Mark_Billson@student.uml.edu', 'Billson12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('3641545960', 'Mark Billson', 'Mark_Billson@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('3641545960', NULL, 'Freshman');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('3641545960', 'COMP1010', '102', 'Fall', 2024, 'B');
INSERT IGNORE account (email, password, type) VALUES ('Cart_Fillson@student.uml.edu', 'Fillson12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('2557216756', 'Cart Fillson', 'Cart_Fillson@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('2557216756', NULL, 'Freshman');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('2557216756', 'COMP1010', '102', 'Fall', 2024, 'C');
INSERT IGNORE account (email, password, type) VALUES ('Indi_Huff@student.uml.edu', 'Huff12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('8972228463', 'Indi Huff', 'Indi_Huff@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('8972228463', NULL, 'Freshman');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('8972228463', 'COMP1010', '102', 'Fall', 2024, 'C');
INSERT IGNORE account (email, password, type) VALUES ('Vart_Stinky@student.uml.edu', 'Stinky12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('9254208013', 'Vart Stinky', 'Vart_Stinky@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('9254208013', NULL, 'Freshman');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('9254208013', 'COMP1010', '102', 'Fall', 2024, 'C');
INSERT IGNORE account (email, password, type) VALUES ('Lois_Roberts@student.uml.edu', 'Roberts12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('1852669011', 'Lois Roberts', 'Lois_Roberts@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('1852669011', NULL, 'Freshman');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('1852669011', 'COMP1010', '102', 'Fall', 2024, 'D');
INSERT IGNORE account (email, password, type) VALUES ('Jake_Fake@student.uml.edu', 'Fake12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('6350407336', 'Jake Fake', 'Jake_Fake@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('6350407336', NULL, 'Freshman');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('6350407336', 'COMP1010', '102', 'Fall', 2024, 'D');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('5851120895', 'COMP1020', '102', 'Spring', 2024, Null);
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('7167426597', 'COMP1020', '102', 'Spring', 2024, Null);
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('9004953223', 'COMP1020', '102', 'Spring', 2024, Null);
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('2464803865', 'COMP1020', '102', 'Spring', 2024, Null);
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('3120045267', 'COMP1020', '102', 'Spring', 2024, Null);
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('8750034020', 'COMP1020', '102', 'Spring', 2024, Null);
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('3722584580', 'COMP1020', '102', 'Spring', 2024, Null);
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('4402123070', 'COMP1020', '102', 'Spring', 2024, Null);
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('3333945716', 'COMP1020', '102', 'Spring', 2024, Null);
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('3641545960', 'COMP1020', '102', 'Spring', 2024, Null);
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('2557216756', 'COMP1020', '102', 'Spring', 2024, Null);
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('8972228463', 'COMP1020', '102', 'Spring', 2024, Null);
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('9254208013', 'COMP1020', '102', 'Spring', 2024, Null);
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('1852669011', 'COMP1020', '102', 'Spring', 2024, Null);
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('6350407336', 'COMP1020', '102', 'Spring', 2024, Null);
INSERT IGNORE account (email, password, type) VALUES ('Swon_Lons@student.uml.edu', 'Lons12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('7765304653', 'Swon Lons', 'Swon_Lons@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('7765304653', NULL, 'Sophomore');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('7765304653', 'COMP1010', '102', 'Fall', 2022, 'C');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('7765304653', 'COMP1020', '102', 'Spring', 2023, 'B');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('7765304653', 'COMP2010', '101', 'Spring', 2024, Null);
INSERT IGNORE account (email, password, type) VALUES ('Hip_Campus@student.uml.edu', 'Campus12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('4850683053', 'Hip Campus', 'Hip_Campus@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('4850683053', NULL, 'Sophomore');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('4850683053', 'COMP1010', '102', 'Fall', 2022, 'A');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('4850683053', 'COMP1020', '102', 'Spring', 2023, 'C');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('4850683053', 'COMP2010', '101', 'Spring', 2024, Null);
INSERT IGNORE account (email, password, type) VALUES ('Jim_Milton@student.uml.edu', 'Milton12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('8703357058', 'Jim Milton', 'Jim_Milton@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('8703357058', NULL, 'Sophomore');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('8703357058', 'COMP1010', '102', 'Fall', 2022, 'A');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('8703357058', 'COMP1020', '102', 'Spring', 2023, 'B');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('8703357058', 'COMP2010', '101', 'Spring', 2024, Null);
INSERT IGNORE account (email, password, type) VALUES ('Jackie_Willis@student.uml.edu', 'Willis12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('8076609681', 'Jackie Willis', 'Jackie_Willis@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('8076609681', NULL, 'Sophomore');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('8076609681', 'COMP1010', '102', 'Fall', 2022, 'A');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('8076609681', 'COMP1020', '102', 'Spring', 2023, 'A');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('8076609681', 'COMP2010', '101', 'Spring', 2024, Null);
INSERT IGNORE account (email, password, type) VALUES ('Payton_Apple@student.uml.edu', 'Apple12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('5219511586', 'Payton Apple', 'Payton_Apple@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('5219511586', NULL, 'Sophomore');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('5219511586', 'COMP1010', '102', 'Fall', 2022, 'B');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('5219511586', 'COMP1020', '102', 'Spring', 2023, 'A');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('5219511586', 'COMP2010', '101', 'Spring', 2024, Null);
INSERT IGNORE account (email, password, type) VALUES ('Garff_Eild@student.uml.edu', 'Eild12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('1197533464', 'Garff Eild', 'Garff_Eild@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('1197533464', NULL, 'Sophomore');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('1197533464', 'COMP1010', '102', 'Fall', 2022, 'B');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('1197533464', 'COMP1020', '102', 'Spring', 2023, 'A');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('1197533464', 'COMP2010', '101', 'Spring', 2024, Null);
INSERT IGNORE account (email, password, type) VALUES ('Clark_Tent@student.uml.edu', 'Tent12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('8527177505', 'Clark Tent', 'Clark_Tent@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('8527177505', NULL, 'Junior');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('8527177505', 'COMP1010', '102', 'Fall', 2022, 'C');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('8527177505', 'COMP1020', '102', 'Spring', 2023, 'A');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('8527177505', 'COMP2010', '101', 'Fall', 2023, 'D');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('8527177505', 'COMP2040', '202', 'Spring', 2024, Null);
INSERT IGNORE account (email, password, type) VALUES ('John_Kins@student.uml.edu', 'Kins12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('3171894126', 'John Kins', 'John_Kins@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('3171894126', NULL, 'Freshman');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('3171894126', 'COMP1010', '102', 'Spring', 2024, Null);
INSERT IGNORE account (email, password, type) VALUES ('Kasse_Kins@student.uml.edu', 'Kins12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('6999316554', 'Kasse Kins', 'Kasse_Kins@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('6999316554', NULL, 'Freshman');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('6999316554', 'COMP1010', '102', 'Spring', 2024, Null);
INSERT IGNORE account (email, password, type) VALUES ('Marty_Kins@student.uml.edu', 'Kins12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('7696637995', 'Marty Kins', 'Marty_Kins@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('7696637995', NULL, 'Freshman');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('7696637995', 'COMP1010', '102', 'Spring', 2024, Null);
INSERT IGNORE account (email, password, type) VALUES ('Edward_Kins@student.uml.edu', 'Kins12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('3677845934', 'Edward Kins', 'Edward_Kins@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('3677845934', NULL, 'Freshman');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('3677845934', 'COMP1010', '102', 'Spring', 2024, Null);
INSERT IGNORE account (email, password, type) VALUES ('Dart_Kins@student.uml.edu', 'Kins12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('5066429174', 'Dart Kins', 'Dart_Kins@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('5066429174', NULL, 'Freshman');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('5066429174', 'COMP1010', '102', 'Spring', 2024, Null);
INSERT IGNORE account (email, password, type) VALUES ('Mary_Kins@student.uml.edu', 'Kins12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('6826984935', 'Mary Kins', 'Mary_Kins@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('6826984935', NULL, 'Freshman');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('6826984935', 'COMP1010', '102', 'Spring', 2024, Null);
INSERT IGNORE account (email, password, type) VALUES ('Stan_Upson@student.uml.edu', 'Upson12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('3771294616', 'Stan Upson', 'Stan_Upson@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE master (student_id, total_credits) VALUES ('3771294616', Null);
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('3771294616', 'COMP1010', '102', 'Fall', 2022, 'C');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('3771294616', 'COMP1020', '102', 'Spring', 2023, 'A');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('3771294616', 'COMP2010', '101', 'Fall', 2023, 'D');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('3771294616', 'COMP2040', '202', 'Spring', 2024, 'A');
INSERT IGNORE account (email, password, type) VALUES ('Kate_Upson@student.uml.edu', 'Upson12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('6255277526', 'Kate Upson', 'Kate_Upson@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE master (student_id, total_credits) VALUES ('6255277526', Null);
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('6255277526', 'COMP1010', '102', 'Fall', 2022, 'A');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('6255277526', 'COMP1020', '102', 'Spring', 2023, 'A');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('6255277526', 'COMP2010', '101', 'Fall', 2023, 'A');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('6255277526', 'COMP2040', '202', 'Spring', 2024, 'A');
INSERT IGNORE account (email, password, type) VALUES ('Phil_Yards@student.uml.edu', 'Yards12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('7288425937', 'Phil Yards', 'Phil_Yards@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE phd (student_id, qualifier, proposal_defence_date, dissertation_defence_date) VALUES ('7288425937', Null, Null, Null);
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('7288425937', 'COMP1010', '102', 'Fall', 2022, 'A');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('7288425937', 'COMP1020', '102', 'Spring', 2023, 'A');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('7288425937', 'COMP2010', '101', 'Fall', 2023, 'D');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('7288425937', 'COMP2040', '202', 'Spring', 2024, 'A');
INSERT IGNORE account (email, password, type) VALUES ('John_Bins@student.uml.edu', 'Bins12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('5592416897', 'John Bins', 'John_Bins@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('5592416897', NULL, 'Freshman');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('5592416897', 'COMP1010', '103', 'Spring', 2024, Null);
INSERT IGNORE account (email, password, type) VALUES ('Kasse_Bins@student.uml.edu', 'Bins12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('7979039027', 'Kasse Bins', 'Kasse_Bins@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('7979039027', NULL, 'Freshman');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('7979039027', 'COMP1010', '103', 'Spring', 2024, Null);
INSERT IGNORE account (email, password, type) VALUES ('Marty_Bins@student.uml.edu', 'Bins12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('9016899971', 'Marty Bins', 'Marty_Bins@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('9016899971', NULL, 'Freshman');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('9016899971', 'COMP1010', '103', 'Spring', 2024, Null);
INSERT IGNORE account (email, password, type) VALUES ('Edward_Bins@student.uml.edu', 'Bins12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('4262740246', 'Edward Bins', 'Edward_Bins@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('4262740246', NULL, 'Freshman');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('4262740246', 'COMP1010', '103', 'Spring', 2024, Null);
INSERT IGNORE account (email, password, type) VALUES ('Dart_Bins@student.uml.edu', 'Bins12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('3706790134', 'Dart Bins', 'Dart_Bins@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('3706790134', NULL, 'Freshman');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('3706790134', 'COMP1010', '103', 'Spring', 2024, Null);
INSERT IGNORE account (email, password, type) VALUES ('Mary_Bins@student.uml.edu', 'Bins12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('4216409386', 'Mary Bins', 'Mary_Bins@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('4216409386', NULL, 'Freshman');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('4216409386', 'COMP1010', '103', 'Spring', 2024, Null);
INSERT IGNORE account (email, password, type) VALUES ('admin@uml.edu', '123456', 'admin');
INSERT IGNORE account (email, password, type) VALUES ('Test_Johnson@student.uml.edu', 'Johnson12345!', 'student');
INSERT IGNORE student (student_id, name, email, dept_name) VALUES ('6397688065', 'Test Johnson', 'Test_Johnson@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT IGNORE undergraduate (student_id, total_credits, class_standing) VALUES ('6397688065', NULL, 'Freshman');
INSERT IGNORE take (student_id, course_id, section_id, semester, year, grade) VALUES ('6397688065', 'COMP1010', '101', 'Fall', 2024, 'A');
INSERT IGNORE INTO account(email, password, type) VALUES ('Abe_Lincoln@student.uml.edu', 'Lincoln12345!', 'student');
INSERT IGNORE INTO student(student_id, name, email, dept_name) VALUES('S1900127777', 'Abe Lincoln', 'Abe_Lincoln@student.uml.edu', 'Computer Science');
INSERT IGNORE INTO take(student_id, course_id, section_id, semester, year, grade) VALUES ('S1900127777', 'CS101', 'A01', 'Fall', 2025, Null);
UPDATE section SET capacity=capacity-1 WHERE (course_id = 'CS101')AND (section_id = 'A01');
INSERT IGNORE INTO account(email, password, type) VALUES ('John_Wayne@student.uml.edu', 'Wayne12345!', 'student');
INSERT IGNORE INTO student(student_id, name, email, dept_name) VALUES('S8937962031', 'John Wayne', 'John_Wayne@student.uml.edu', 'Computer Science');
INSERT IGNORE INTO take(student_id, course_id, section_id, semester, year, grade) VALUES ('S8937962031', 'CS101', 'A01', 'Fall', 2025, Null);
UPDATE section SET capacity=capacity-1 WHERE (course_id = 'CS101')AND (section_id = 'A01');
INSERT IGNORE INTO account(email, password, type) VALUES ('Mark_Yard@student.uml.edu', 'Yard12345!', 'student');
INSERT IGNORE INTO student(student_id, name, email, dept_name) VALUES('S2376695636', 'Mark Yard', 'Mark_Yard@student.uml.edu', 'Computer Science');
INSERT IGNORE INTO take(student_id, course_id, section_id, semester, year, grade) VALUES ('S2376695636', 'CS101', 'A01', 'Fall', 2025, Null);
UPDATE section SET capacity=capacity-1 WHERE (course_id = 'CS101')AND (section_id = 'A01');
INSERT IGNORE INTO account(email, password, type) VALUES ('Reggie_Palmer@student.uml.edu', 'Palmer12345!', 'student');
INSERT IGNORE INTO student(student_id, name, email, dept_name) VALUES('S5784105550', 'Reggie Palmer', 'Reggie_Palmer@student.uml.edu', 'Computer Science');
INSERT IGNORE INTO take(student_id, course_id, section_id, semester, year, grade) VALUES ('S5784105550', 'CS101', 'A01', 'Fall', 2025, Null);
UPDATE section SET capacity=capacity-1 WHERE (course_id = 'CS101')AND (section_id = 'A01');
INSERT IGNORE INTO account(email, password, type) VALUES ('Tom_Scran@student.uml.edu', 'Scran12345!', 'student');
INSERT IGNORE INTO student(student_id, name, email, dept_name) VALUES('S1271562228', 'Tom Scran', 'Tom_Scran@student.uml.edu', 'Computer Science');
INSERT IGNORE INTO take(student_id, course_id, section_id, semester, year, grade) VALUES ('S1271562228', 'CS101', 'A01', 'Fall', 2025, Null);
UPDATE section SET capacity=capacity-1 WHERE (course_id = 'CS101')AND (section_id = 'A01');
INSERT IGNORE INTO account(email, password, type) VALUES ('Grant_Fisher@student.uml.edu', 'Fisher12345!', 'student');
INSERT IGNORE INTO student(student_id, name, email, dept_name) VALUES('S4089263845', 'Grant Fisher', 'Grant_Fisher@student.uml.edu', 'Computer Science');
INSERT IGNORE INTO take(student_id, course_id, section_id, semester, year, grade) VALUES ('S4089263845', 'CS101', 'A01', 'Fall', 2025, Null);
UPDATE section SET capacity=capacity-1 WHERE (course_id = 'CS101')AND (section_id = 'A01');
INSERT IGNORE INTO account(email, password, type) VALUES ('Martha_Lime@student.uml.edu', 'Lime12345!', 'student');
INSERT IGNORE INTO student(student_id, name, email, dept_name) VALUES('S4557999593', 'Martha Lime', 'Martha_Lime@student.uml.edu', 'Computer Science');
INSERT IGNORE INTO take(student_id, course_id, section_id, semester, year, grade) VALUES ('S4557999593', 'CS101', 'A01', 'Fall', 2025, Null);
UPDATE section SET capacity=capacity-1 WHERE (course_id = 'CS101')AND (section_id = 'A01');
INSERT IGNORE INTO account(email, password, type) VALUES ('Bant_Jane@student.uml.edu', 'Jane12345!', 'student');
INSERT IGNORE INTO student(student_id, name, email, dept_name) VALUES('S1742727674', 'Bant Jane', 'Bant_Jane@student.uml.edu', 'Computer Science');
INSERT IGNORE INTO take(student_id, course_id, section_id, semester, year, grade) VALUES ('S1742727674', 'CS101', 'A01', 'Fall', 2025, Null);
UPDATE section SET capacity=capacity-1 WHERE (course_id = 'CS101')AND (section_id = 'A01');
INSERT IGNORE INTO account(email, password, type) VALUES ('Yan_Cran@student.uml.edu', 'Cran12345!', 'student');
INSERT IGNORE INTO student(student_id, name, email, dept_name) VALUES('S7636100652', 'Yan Cran', 'Yan_Cran@student.uml.edu', 'Computer Science');
INSERT IGNORE INTO take(student_id, course_id, section_id, semester, year, grade) VALUES ('S7636100652', 'CS101', 'A01', 'Fall', 2025, Null);
UPDATE section SET capacity=capacity-1 WHERE (course_id = 'CS101')AND (section_id = 'A01');
INSERT IGNORE INTO account(email, password, type) VALUES ('Dake_Lin@student.uml.edu', 'Lin12345!', 'student');
INSERT IGNORE INTO student(student_id, name, email, dept_name) VALUES('S2368333324', 'Dake Lin', 'Dake_Lin@student.uml.edu', 'Computer Science');
INSERT IGNORE INTO take(student_id, course_id, section_id, semester, year, grade) VALUES ('S2368333324', 'CS101', 'A01', 'Fall', 2025, Null);
UPDATE section SET capacity=capacity-1 WHERE (course_id = 'CS101')AND (section_id = 'A01');
INSERT IGNORE INTO account(email, password, type) VALUES ('Harry_Terr@student.uml.edu', 'Terr12345!', 'student');
INSERT IGNORE INTO student(student_id, name, email, dept_name) VALUES('S2762450658', 'Harry Terr', 'Harry_Terr@student.uml.edu', 'Computer Science');
INSERT IGNORE INTO take(student_id, course_id, section_id, semester, year, grade) VALUES ('S2762450658', 'CS101', 'A01', 'Fall', 2025, Null);
UPDATE section SET capacity=capacity-1 WHERE (course_id = 'CS101')AND (section_id = 'A01');
INSERT IGNORE INTO account(email, password, type) VALUES ('Boris_Johnson@student.uml.edu', 'Johnson12345!', 'student');
INSERT IGNORE INTO student(student_id, name, email, dept_name) VALUES('S8898332601', 'Boris Johnson', 'Boris_Johnson@student.uml.edu', 'Computer Science');
INSERT IGNORE INTO take(student_id, course_id, section_id, semester, year, grade) VALUES ('S8898332601', 'CS101', 'A01', 'Fall', 2025, Null);
UPDATE section SET capacity=capacity-1 WHERE (course_id = 'CS101')AND (section_id = 'A01');
INSERT IGNORE INTO account(email, password, type) VALUES ('Mark_Billson@student.uml.edu', 'Billson12345!', 'student');
INSERT IGNORE INTO student(student_id, name, email, dept_name) VALUES('S7859708318', 'Mark Billson', 'Mark_Billson@student.uml.edu', 'Computer Science');
INSERT IGNORE INTO take(student_id, course_id, section_id, semester, year, grade) VALUES ('S7859708318', 'CS101', 'A01', 'Fall', 2025, Null);
UPDATE section SET capacity=capacity-1 WHERE (course_id = 'CS101')AND (section_id = 'A01');
INSERT IGNORE INTO account(email, password, type) VALUES ('Cart_Fillson@student.uml.edu', 'Fillson12345!', 'student');
INSERT IGNORE INTO student(student_id, name, email, dept_name) VALUES('S9094228346', 'Cart Fillson', 'Cart_Fillson@student.uml.edu', 'Computer Science');
INSERT IGNORE INTO take(student_id, course_id, section_id, semester, year, grade) VALUES ('S9094228346', 'CS101', 'A01', 'Fall', 2025, Null);
UPDATE section SET capacity=capacity-1 WHERE (course_id = 'CS101')AND (section_id = 'A01');
INSERT IGNORE INTO account(email, password, type) VALUES ('Indi_Huff@student.uml.edu', 'Huff12345!', 'student');
INSERT IGNORE INTO student(student_id, name, email, dept_name) VALUES('S2554769520', 'Indi Huff', 'Indi_Huff@student.uml.edu', 'Computer Science');
INSERT IGNORE INTO take(student_id, course_id, section_id, semester, year, grade) VALUES ('S2554769520', 'CS101', 'A01', 'Fall', 2025, Null);
UPDATE section SET capacity=capacity-1 WHERE (course_id = 'CS101')AND (section_id = 'A01');