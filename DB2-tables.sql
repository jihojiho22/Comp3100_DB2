create table account
	(email		varchar(50),
	 password	varchar(20) not null,
	 type		varchar(20),
	 primary key(email)
	);


create table department
	(dept_name	varchar(100), 
	 location	varchar(100), 
	 primary key (dept_name)
	);

create table instructor
	(instructor_id		varchar(10),
	 instructor_name	varchar(50) not null,
	 title 			varchar(30),
	 dept_name		varchar(100), 
	 email			varchar(50) not null,
	 primary key (instructor_id)
	);

CREATE TABLE instructor_rating (
    instructor_id VARCHAR(10),
    rating NUMERIC(3,1),
    student_id VARCHAR(10),
    section_id VARCHAR(10),
    course_id VARCHAR(20),
    PRIMARY KEY (instructor_id, student_id, section_id, course_id)
	);

create table student
	(student_id		varchar(10), 
	 name			varchar(20) not null, 
	 email			varchar(50) not null,
	 dept_name		varchar(100), 
	 primary key (student_id),
	 foreign key (dept_name) references department (dept_name)
		on delete set null
	);

create table PhD
	(student_id			varchar(10), 
	 qualifier			varchar(30), 
	 proposal_defence_date		date,
	 dissertation_defence_date	date, 
	 primary key (student_id),
	 foreign key (student_id) references student (student_id)
		on delete cascade
	);

create table master
	(student_id		varchar(10), 
	 total_credits		int,	
	 primary key (student_id),
	 foreign key (student_id) references student (student_id)
		on delete cascade
	);

create table undergraduate
	(student_id		varchar(10), 
	 total_credits		int,
	 class_standing		varchar(10)
		check (class_standing in ('Freshman', 'Sophomore', 'Junior', 'Senior')), 	
	 primary key (student_id),
	 foreign key (student_id) references student (student_id)
		on delete cascade
	);

create table classroom
	(classroom_id 		varchar(8),
	 building		varchar(15) not null,
	 room_number		varchar(7) not null,
	 capacity		numeric(4,0),
	 primary key (classroom_id)
	);

create table time_slot
	(time_slot_id		varchar(12),
	 day			varchar(10) not null,
	 start_time		time not null,
	 end_time		time not null,
	 primary key (time_slot_id)
	);

create table course
	(course_id		varchar(20), 
	 course_name		varchar(50) not null, 
	 credits		numeric(2,0) check (credits > 0),
	 primary key (course_id)
	);

create table section
	(course_id		varchar(20),
	 section_id		varchar(10), 
	 semester		varchar(6)
			check (semester in ('Fall', 'Winter', 'Spring', 'Summer')), 
	 year			numeric(4,0) check (year > 1990 and year < 2100), 
	 instructor_id		varchar(10),
	 classroom_id   	varchar(8),
	 time_slot_id		varchar(12),	
	 primary key (course_id, section_id, semester, year),
	 foreign key (course_id) references course (course_id)
		on delete cascade,
	 foreign key (instructor_id) references instructor (instructor_id)
		on delete set null,
	 foreign key (time_slot_id) references time_slot(time_slot_id)
		on delete set null
	);

create table prereq
	(course_id		varchar(20), 
	 prereq_id		varchar(20) not null,
	 primary key (course_id, prereq_id),
	 foreign key (course_id) references course (course_id)
		on delete cascade,
	 foreign key (prereq_id) references course (course_id)
	);

create table advise
	(instructor_id		varchar(8),
	 student_id		varchar(10),
	 start_date		date not null,
	 end_date		date,
	 primary key (instructor_id, student_id),
	 foreign key (instructor_id) references instructor (instructor_id)
		on delete  cascade,
	 foreign key (student_id) references PhD (student_id)
		on delete cascade
);

create table TA
	(student_id		varchar(10),
	 course_id		varchar(8),
	 section_id		varchar(10), 
	 semester		varchar(6),
	 year			numeric(4,0),
	 primary key (student_id, course_id, section_id, semester, year),
	 foreign key (student_id) references PhD (student_id)
		on delete cascade,
	 foreign key (course_id, section_id, semester, year) references 
	     section (course_id, section_id, semester, year)
		on delete cascade
);

create table masterGrader
	(student_id		varchar(10),
	 course_id		varchar(8),
	 section_id		varchar(10), 
	 semester		varchar(6),
	 year			numeric(4,0),
	 primary key (student_id, course_id, section_id, semester, year),
	 foreign key (student_id) references master (student_id)
		on delete cascade,
	 foreign key (course_id, section_id, semester, year) references 
	     section (course_id, section_id, semester, year)
		on delete cascade
);

create table undergraduateGrader
	(student_id		varchar(10),
	 course_id		varchar(8),
	 section_id		varchar(10), 
	 semester		varchar(6),
	 year			numeric(4,0),
	 primary key (student_id, course_id, section_id, semester, year),
	 foreign key (student_id) references undergraduate (student_id)
		on delete cascade,
	 foreign key (course_id, section_id, semester, year) references 
	     section (course_id, section_id, semester, year)
		on delete cascade
);

create table take
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
	
CREATE TABLE waitlist (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id VARCHAR(10) NOT NULL,
  course_id VARCHAR(20) NOT NULL,
  section_id VARCHAR(10) NOT NULL,
  semester VARCHAR(6) NOT NULL,
  year INT NOT NULL,
  request_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY unique_waitlist (student_id, course_id, section_id, semester, year),
  FOREIGN KEY (student_id) REFERENCES student(student_id) ON DELETE CASCADE,
  FOREIGN KEY (course_id) REFERENCES course(course_id) ON DELETE CASCADE
);

INSERT INTO course (course_id, course_name, credits) VALUES ('COMP1010', 'Computing I', 4);
INSERT INTO department (dept_name, location) VALUES ('Miner School of Computer & Information Sciences', 'Dandeneau Hall, 1 University Avenue, Lowell, MA 01854');
INSERT INTO account (email, password, type) VALUES ('Dane_Christensen@cs.uml.edu', '123456', 'instructor');
INSERT INTO instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('DChirstens', 'Dane Chirstensen', 'Professor', 'Miner School of Computer & Information Sciences', 'Dane_Christensen@cs.uml.edu');
INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES (30173110, 'Lydon Library', '110', 15);
INSERT INTO time_slot (time_slot_id, day, start_time, end_time) VALUES ('MWF0900_0950', 'MoWeFr', '09:00:00', '09:50:00');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '101', 'Fall', 2020, 'DChirstens', 30173110, 'MWF0900_0950');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '101', 'Fall', 2021, 'DChirstens', 30173110, 'MWF0900_0950');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '101', 'Fall', 2022, 'DChirstens', 30173110, 'MWF0900_0950');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '101', 'Fall', 2023, 'DChirstens', 30173110, 'MWF0900_0950');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '101', 'Fall', 2024, 'DChirstens', 30173110, 'MWF0900_0950');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '101', 'Fall', 2025, 'DChirstens', 30173110, 'MWF0900_0950');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '101', 'Fall', 2026, 'DChirstens', 30173110, 'MWF0900_0950');
INSERT INTO time_slot (time_slot_id, day, start_time, end_time) VALUES ('MWF1000_1050', 'MoWeFr', '10:00:00', '10:50:00');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '102', 'Fall', 2020, 'DChirstens', 30173110, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '102', 'Fall', 2021, 'DChirstens', 30173110, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '102', 'Fall', 2022, 'DChirstens', 30173110, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '102', 'Fall', 2023, 'DChirstens', 30173110, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '102', 'Fall', 2024, 'DChirstens', 30173110, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '102', 'Fall', 2025, 'DChirstens', 30173110, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '102', 'Fall', 2026, 'DChirstens', 30173110, 'MWF1000_1050');
INSERT INTO time_slot (time_slot_id, day, start_time, end_time) VALUES ('MWF1100_1150', 'MoWeFr', '11:00:00', '11:50:00');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '103', 'Fall', 2020, 'DChirstens', 30173110, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '103', 'Fall', 2021, 'DChirstens', 30173110, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '103', 'Fall', 2022, 'DChirstens', 30173110, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '103', 'Fall', 2023, 'DChirstens', 30173110, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '103', 'Fall', 2024, 'DChirstens', 30173110, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '103', 'Fall', 2025, 'DChirstens', 30173110, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '103', 'Fall', 2026, 'DChirstens', 30173110, 'MWF1100_1150');

INSERT INTO account (email, password, type) VALUES ('Yelena_Rykalova@cs.uml.edu', '123456', 'instructor');
INSERT INTO instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('YRykalova', 'Yelena Rykalova', 'Professor', 'Miner School of Computer & Information Sciences', 'Yelena_Rykalova@cs.uml.edu');
INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES (74275303, 'Shah Hall', '303', 15);
INSERT INTO time_slot (time_slot_id, day, start_time, end_time) VALUES ('TT1400_1515', 'TuTh', '14:00:00', '15:15:00');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '104', 'Fall', 2020, 'YRykalova', 74275303, 'TT1400_1515');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '104', 'Fall', 2021, 'YRykalova', 74275303, 'TT1400_1515');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '104', 'Fall', 2022, 'YRykalova', 74275303, 'TT1400_1515');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '104', 'Fall', 2023, 'YRykalova', 74275303, 'TT1400_1515');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '104', 'Fall', 2024, 'YRykalova', 74275303, 'TT1400_1515');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '104', 'Fall', 2025, 'YRykalova', 74275303, 'TT1400_1515');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '104', 'Fall', 2026, 'YRykalova', 74275303, 'TT1400_1515');

INSERT INTO account (email, password, type) VALUES ('Ryan_OConnell@cs.uml.edu', '123456', 'instructor');
INSERT INTO instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('ROConnell', 'Ryan OConnell', 'Professor', 'Miner School of Computer & Information Sciences', 'Ryan_OConnell@cs.uml.edu');
INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES (51328209, 'Falmouth Hall', '209', 15);
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '105', 'Fall', 2020, 'ROConnell', 51328209, 'MWF0900_0950');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '105', 'Fall', 2021, 'ROConnell', 51328209, 'MWF0900_0950');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '105', 'Fall', 2022, 'ROConnell', 51328209, 'MWF0900_0950');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '105', 'Fall', 2023, 'ROConnell', 51328209, 'MWF0900_0950');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '105', 'Fall', 2024, 'ROConnell', 51328209, 'MWF0900_0950');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '105', 'Fall', 2025, 'ROConnell', 51328209, 'MWF0900_0950');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '105', 'Fall', 2026, 'ROConnell', 51328209, 'MWF0900_0950');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '106', 'Fall', 2020, 'ROConnell', 51328209, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '106', 'Fall', 2021, 'ROConnell', 51328209, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '106', 'Fall', 2022, 'ROConnell', 51328209, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '106', 'Fall', 2023, 'ROConnell', 51328209, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '106', 'Fall', 2024, 'ROConnell', 51328209, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '106', 'Fall', 2025, 'ROConnell', 51328209, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '106', 'Fall', 2026, 'ROConnell', 51328209, 'MWF1000_1050');

INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '102', 'Spring', 2020, 'ROConnell', 51328209, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '102', 'Spring', 2021, 'ROConnell', 51328209, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '102', 'Spring', 2022, 'ROConnell', 51328209, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '102', 'Spring', 2023, 'ROConnell', 51328209, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '102', 'Spring', 2024, 'ROConnell', 51328209, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '102', 'Spring', 2025, 'ROConnell', 51328209, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '102', 'Spring', 2026, 'ROConnell', 51328209, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '103', 'Spring', 2020, 'ROConnell', 51328209, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '103', 'Spring', 2021, 'ROConnell', 51328209, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '103', 'Spring', 2022, 'ROConnell', 51328209, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '103', 'Spring', 2023, 'ROConnell', 51328209, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '103', 'Spring', 2024, 'ROConnell', 51328209, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '103', 'Spring', 2025, 'ROConnell', 51328209, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1010', '103', 'Spring', 2026, 'ROConnell', 51328209, 'MWF1100_1150');

INSERT INTO course (course_id, course_name, credits) VALUES ('COMP1020', 'Computing II', 4);
INSERT INTO account (email, password, type) VALUES ('dadams@cs.uml.edu', '123456', 'instructor');
INSERT INTO instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('DAdams', 'David Adams', 'Professor', 'Miner School of Computer & Information Sciences', 'dadams@cs.uml.edu');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '101', 'Fall', 2020, 'DAdams', 74275303, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '101', 'Fall', 2021, 'DAdams', 74275303, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '101', 'Fall', 2022, 'DAdams', 74275303, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '101', 'Fall', 2023, 'DAdams', 74275303, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '101', 'Fall', 2024, 'DAdams', 74275303, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '101', 'Fall', 2025, 'DAdams', 74275303, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '101', 'Fall', 2026, 'DAdams', 74275303, 'MWF1100_1150');
INSERT INTO time_slot (time_slot_id, day, start_time, end_time) VALUES ('MWF1200_1250', 'MoWeFr', '12:00:00', '12:50:00');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '102', 'Fall', 2020, 'DAdams', 74275303, 'MWF1200_1250');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '102', 'Fall', 2021, 'DAdams', 74275303, 'MWF1200_1250');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '102', 'Fall', 2022, 'DAdams', 74275303, 'MWF1200_1250');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '102', 'Fall', 2023, 'DAdams', 74275303, 'MWF1200_1250');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '102', 'Fall', 2024, 'DAdams', 74275303, 'MWF1200_1250');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '102', 'Fall', 2025, 'DAdams', 74275303, 'MWF1200_1250');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '102', 'Fall', 2026, 'DAdams', 74275303, 'MWF1200_1250');

INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '101', 'Spring', 2020, 'YRykalova', 74275303, 'TT1400_1515');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '101', 'Spring', 2021, 'YRykalova', 74275303, 'TT1400_1515');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '101', 'Spring', 2022, 'YRykalova', 74275303, 'TT1400_1515');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '101', 'Spring', 2023, 'YRykalova', 74275303, 'TT1400_1515');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '101', 'Spring', 2024, 'YRykalova', 74275303, 'TT1400_1515');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '101', 'Spring', 2025, 'YRykalova', 74275303, 'TT1400_1515');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '101', 'Spring', 2026, 'YRykalova', 74275303, 'TT1400_1515');

INSERT INTO account (email, password, type) VALUES ('Johannes_Weis@cs.uml.edu', '123456', 'instructor');
INSERT INTO instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('JWeis', 'Johannes Weis', 'Professor', 'Miner School of Computer & Information Sciences', 'Johannes_Weis@cs.uml.edu');
INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES (12345503, 'Olsen', '503', 15);
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '102', 'Spring', 2020, 'JWeis', 12345503, 'MWF0900_0950');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '102', 'Spring', 2021, 'JWeis', 12345503, 'MWF0900_0950');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '102', 'Spring', 2022, 'JWeis', 12345503, 'MWF0900_0950');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '102', 'Spring', 2023, 'JWeis', 12345503, 'MWF0900_0950');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '102', 'Spring', 2024, 'JWeis', 12345503, 'MWF0900_0950');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '102', 'Spring', 2025, 'JWeis', 12345503, 'MWF0900_0950');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '102', 'Spring', 2026, 'JWeis', 12345503, 'MWF0900_0950');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '103', 'Spring', 2020, 'JWeis', 12345503, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '103', 'Spring', 2021, 'JWeis', 12345503, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '103', 'Spring', 2022, 'JWeis', 12345503, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '103', 'Spring', 2023, 'JWeis', 12345503, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '103', 'Spring', 2024, 'JWeis', 12345503, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '103', 'Spring', 2025, 'JWeis', 12345503, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP1020', '103', 'Spring', 2026, 'JWeis', 12345503, 'MWF1000_1050');

INSERT INTO prereq (course_id, prereq_id) VALUES ('COMP1020', 'COMP1010');
INSERT INTO course (course_id, course_name, credits) VALUES ('COMP2010', 'Computing III', 4);
INSERT INTO time_slot (time_slot_id, day, start_time, end_time) VALUES ('TT0930_1045', 'TuTh', '09:30:00', '10:45:00');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '101', 'Fall', 2020, 'YRykalova', 74275303, 'TT0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '101', 'Fall', 2021, 'YRykalova', 74275303, 'TT0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '101', 'Fall', 2022, 'YRykalova', 74275303, 'TT0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '101', 'Fall', 2023, 'YRykalova', 74275303, 'TT0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '101', 'Fall', 2024, 'YRykalova', 74275303, 'TT0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '101', 'Fall', 2025, 'YRykalova', 74275303, 'TT0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '101', 'Fall', 2026, 'YRykalova', 74275303, 'TT0930_1045');

INSERT INTO account (email, password, type) VALUES ('Sirong_Lin@cs.uml.edu', '123456', 'instructor');
INSERT INTO instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('SLin', 'Sirong Lin', 'Professor', 'Miner School of Computer & Information Sciences', 'Sirong_Lin@cs.uml.edu');
INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES (12345408, 'Olsen', '408', 15);
INSERT INTO time_slot (time_slot_id, day, start_time, end_time) VALUES ('TT1100_1215', 'TuTh', '11:00:00', '12:15:00');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '101', 'Spring', 2020, 'SLin', 12345408, 'TT1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '101', 'Spring', 2021, 'SLin', 12345408, 'TT1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '101', 'Spring', 2022, 'SLin', 12345408, 'TT1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '101', 'Spring', 2023, 'SLin', 12345408, 'TT1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '101', 'Spring', 2024, 'SLin', 12345408, 'TT1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '101', 'Spring', 2025, 'SLin', 12345408, 'TT1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '101', 'Spring', 2026, 'SLin', 12345408, 'TT1100_1215');

INSERT INTO account (email, password, type) VALUES ('Charles_Wilkes@cs.uml.edu', '123456', 'instructor');
INSERT INTO instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('CWilkes', 'Charles Wilkes', 'Professor', 'Miner School of Computer & Information Sciences', 'Charles_Wilkes@cs.uml.edu');
INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES (12345330, 'Olsen', '330', 15);
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '102', 'Spring', 2020, 'CWilkes', 12345330, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '102', 'Spring', 2021, 'CWilkes', 12345330, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '102', 'Spring', 2022, 'CWilkes', 12345330, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '102', 'Spring', 2023, 'CWilkes', 12345330, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '102', 'Spring', 2024, 'CWilkes', 12345330, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '102', 'Spring', 2025, 'CWilkes', 12345330, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2010', '102', 'Spring', 2026, 'CWilkes', 12345330, 'MWF1000_1050');

INSERT INTO prereq (course_id, prereq_id) VALUES ('COMP2010', 'COMP1020');
INSERT INTO course (course_id, course_name, credits) VALUES ('COMP2040', 'Computing IV', 4);
INSERT INTO account (email, password, type) VALUES ('James_Daly@cs.uml.edu', '123456', 'instructor');
INSERT INTO instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('JDaly', 'James Daly', 'Professor', 'Miner School of Computer & Information Sciences', 'James_Daly@cs.uml.edu');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '201', 'Fall', 2020, 'JDaly', 51328209, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '201', 'Fall', 2021, 'JDaly', 51328209, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '201', 'Fall', 2022, 'JDaly', 51328209, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '201', 'Fall', 2023, 'JDaly', 51328209, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '201', 'Fall', 2024, 'JDaly', 51328209, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '201', 'Fall', 2025, 'JDaly', 51328209, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '201', 'Fall', 2026, 'JDaly', 51328209, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '202', 'Fall', 2020, 'JDaly', 51328209, 'MWF1200_1250');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '202', 'Fall', 2021, 'JDaly', 51328209, 'MWF1200_1250');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '202', 'Fall', 2022, 'JDaly', 51328209, 'MWF1200_1250');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '202', 'Fall', 2023, 'JDaly', 51328209, 'MWF1200_1250');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '202', 'Fall', 2024, 'JDaly', 51328209, 'MWF1200_1250');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '202', 'Fall', 2025, 'JDaly', 51328209, 'MWF1200_1250');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '202', 'Fall', 2026, 'JDaly', 51328209, 'MWF1200_1250');

INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '201', 'Spring', 2020, 'JDaly', 51328209, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '201', 'Spring', 2021, 'JDaly', 51328209, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '201', 'Spring', 2022, 'JDaly', 51328209, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '201', 'Spring', 2023, 'JDaly', 51328209, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '201', 'Spring', 2024, 'JDaly', 51328209, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '201', 'Spring', 2025, 'JDaly', 51328209, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '201', 'Spring', 2026, 'JDaly', 51328209, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '202', 'Spring', 2020, 'JDaly', 51328209, 'MWF1200_1250');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '202', 'Spring', 2021, 'JDaly', 51328209, 'MWF1200_1250');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '202', 'Spring', 2022, 'JDaly', 51328209, 'MWF1200_1250');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '202', 'Spring', 2023, 'JDaly', 51328209, 'MWF1200_1250');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '202', 'Spring', 2024, 'JDaly', 51328209, 'MWF1200_1250');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '202', 'Spring', 2025, 'JDaly', 51328209, 'MWF1200_1250');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '202', 'Spring', 2026, 'JDaly', 51328209, 'MWF1200_1250');

INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES (51328313, 'Falmouth Hall', '313', 15);
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '203', 'Spring', 2020, 'YRykalova', 51328313, 'TT0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '203', 'Spring', 2021, 'YRykalova', 51328313, 'TT0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '203', 'Spring', 2022, 'YRykalova', 51328313, 'TT0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '203', 'Spring', 2023, 'YRykalova', 51328313, 'TT0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '203', 'Spring', 2024, 'YRykalova', 51328313, 'TT0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '203', 'Spring', 2025, 'YRykalova', 51328313, 'TT0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '203', 'Spring', 2026, 'YRykalova', 51328313, 'TT0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '204', 'Spring', 2020, 'YRykalova', 51328313, 'TT1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '204', 'Spring', 2021, 'YRykalova', 51328313, 'TT1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '204', 'Spring', 2022, 'YRykalova', 51328313, 'TT1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '204', 'Spring', 2023, 'YRykalova', 51328313, 'TT1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '204', 'Spring', 2024, 'YRykalova', 51328313, 'TT1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '204', 'Spring', 2025, 'YRykalova', 51328313, 'TT1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('COMP2040', '204', 'Spring', 2026, 'YRykalova', 51328313, 'TT1100_1215');

INSERT INTO prereq (course_id, prereq_id) VALUES ('COMP2040', 'COMP2010');
INSERT INTO course (course_id, course_name, credits) VALUES ('ENGL1010', 'College Writing I', 3);
INSERT INTO department (dept_name, location) VALUES ('English Department', 'OLeary Library, 61 Wilder Street, Lowell, MA 01854');
INSERT INTO account (email, password, type) VALUES ('Michael_Baron@uml.edu', '123456', 'instructor');
INSERT INTO instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('MBaron', 'Michael Baron', 'Professor', 'English Department', 'Michael_Baron@uml.edu');
INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES (12345353, 'Olsen', '353', 15);
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '202', 'Fall', 2020, 'MBaron', 12345353, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '202', 'Fall', 2021, 'MBaron', 12345353, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '202', 'Fall', 2022, 'MBaron', 12345353, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '202', 'Fall', 2023, 'MBaron', 12345353, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '202', 'Fall', 2024, 'MBaron', 12345353, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '202', 'Fall', 2025, 'MBaron', 12345353, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '202', 'Fall', 2026, 'MBaron', 12345353, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '203', 'Fall', 2020, 'MBaron', 12345353, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '203', 'Fall', 2021, 'MBaron', 12345353, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '203', 'Fall', 2022, 'MBaron', 12345353, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '203', 'Fall', 2023, 'MBaron', 12345353, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '203', 'Fall', 2024, 'MBaron', 12345353, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '203', 'Fall', 2025, 'MBaron', 12345353, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '203', 'Fall', 2026, 'MBaron', 12345353, 'MWF1100_1150');

INSERT INTO account (email, password, type) VALUES ('Jason_Bellipanni@uml.edu', '123456', 'instructor');
INSERT INTO instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('JBellipann', 'Jason Bellipanni', 'Professor', 'English Department', 'Jason_Bellipanni@uml.edu');
INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES (12345349, 'Olsen', '349', 15);
INSERT INTO time_slot (time_slot_id, day, start_time, end_time) VALUES ('MWF0800_0850', 'MoWeFr', '08:00:00', '08:50:00');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '204', 'Fall', 2020, 'JBellipann', 12345349, 'MWF0800_0850');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '204', 'Fall', 2021, 'JBellipann', 12345349, 'MWF0800_0850');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '204', 'Fall', 2022, 'JBellipann', 12345349, 'MWF0800_0850');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '204', 'Fall', 2023, 'JBellipann', 12345349, 'MWF0800_0850');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '204', 'Fall', 2024, 'JBellipann', 12345349, 'MWF0800_0850');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '204', 'Fall', 2025, 'JBellipann', 12345349, 'MWF0800_0850');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '204', 'Fall', 2026, 'JBellipann', 12345349, 'MWF0800_0850');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '205', 'Fall', 2020, 'JBellipann', 12345349, 'MWF0900_0950');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '205', 'Fall', 2021, 'JBellipann', 12345349, 'MWF0900_0950');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '205', 'Fall', 2022, 'JBellipann', 12345349, 'MWF0900_0950');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '205', 'Fall', 2023, 'JBellipann', 12345349, 'MWF0900_0950');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '205', 'Fall', 2024, 'JBellipann', 12345349, 'MWF0900_0950');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '205', 'Fall', 2025, 'JBellipann', 12345349, 'MWF0900_0950');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '205', 'Fall', 2026, 'JBellipann', 12345349, 'MWF0900_0950');

INSERT INTO account (email, password, type) VALUES ('Darrin_Berard@uml.edu', '123456', 'instructor');
INSERT INTO instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('DBerard', 'Darrin Berard', 'Professor', 'English Department', 'Darrin_Berard@uml.edu');
INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES (12345106, 'Olsen', '106', 15);
INSERT INTO time_slot (time_slot_id, day, start_time, end_time) VALUES ('MW0330_0445', 'MoWe', '03:30:00', '04:45:00');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '206', 'Fall', 2020, 'DBerard', 12345106, 'MW0330_0445');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '206', 'Fall', 2021, 'DBerard', 12345106, 'MW0330_0445');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '206', 'Fall', 2022, 'DBerard', 12345106, 'MW0330_0445');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '206', 'Fall', 2023, 'DBerard', 12345106, 'MW0330_0445');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '206', 'Fall', 2024, 'DBerard', 12345106, 'MW0330_0445');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '206', 'Fall', 2025, 'DBerard', 12345106, 'MW0330_0445');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '206', 'Fall', 2026, 'DBerard', 12345106, 'MW0330_0445');
INSERT INTO time_slot (time_slot_id, day, start_time, end_time) VALUES ('MW1700_1815', 'MoWe', '17:00:00', '18:15:00');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '207', 'Fall', 2020, 'DBerard', 12345106, 'MW1700_1815');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '207', 'Fall', 2021, 'DBerard', 12345106, 'MW1700_1815');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '207', 'Fall', 2022, 'DBerard', 12345106, 'MW1700_1815');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '207', 'Fall', 2023, 'DBerard', 12345106, 'MW1700_1815');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '207', 'Fall', 2024, 'DBerard', 12345106, 'MW1700_1815');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '207', 'Fall', 2025, 'DBerard', 12345106, 'MW1700_1815');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '207', 'Fall', 2026, 'DBerard', 12345106, 'MW1700_1815');

INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES (59237107, 'Perry Hall', '107', 15);
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '203', 'Spring', 2020, 'MBaron', 59237107, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '203', 'Spring', 2021, 'MBaron', 59237107, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '203', 'Spring', 2022, 'MBaron', 59237107, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '203', 'Spring', 2023, 'MBaron', 59237107, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '203', 'Spring', 2024, 'MBaron', 59237107, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '203', 'Spring', 2025, 'MBaron', 59237107, 'MWF1000_1050');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '203', 'Spring', 2026, 'MBaron', 59237107, 'MWF1000_1050');

INSERT INTO account (email, password, type) VALUES ('Theresa_DeFranzo@uml.edu', '123456', 'instructor');
INSERT INTO instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('TDeFranzo', 'Theresa DeFranzo', 'Professor', 'English Department', 'Theresa_DeFranzo@uml.edu');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '205', 'Spring', 2020, 'TDeFranzo', 12345349, 'TT0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '205', 'Spring', 2021, 'TDeFranzo', 12345349, 'TT0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '205', 'Spring', 2022, 'TDeFranzo', 12345349, 'TT0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '205', 'Spring', 2023, 'TDeFranzo', 12345349, 'TT0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '205', 'Spring', 2024, 'TDeFranzo', 12345349, 'TT0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '205', 'Spring', 2025, 'TDeFranzo', 12345349, 'TT0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '205', 'Spring', 2026, 'TDeFranzo', 12345349, 'TT0930_1045');

INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '207', 'Spring', 2020, 'MBaron', 59237107, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '207', 'Spring', 2021, 'MBaron', 59237107, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '207', 'Spring', 2022, 'MBaron', 59237107, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '207', 'Spring', 2023, 'MBaron', 59237107, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '207', 'Spring', 2024, 'MBaron', 59237107, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '207', 'Spring', 2025, 'MBaron', 59237107, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1010', '207', 'Spring', 2026, 'MBaron', 59237107, 'MWF1100_1150');

INSERT INTO course (course_id, course_name, credits) VALUES ('MATH1310', 'Calculus I', 4);
INSERT INTO department (dept_name, location) VALUES ('Department of Mathematics and Statistics', 'Southwick Hall, 1 University Ave, Lowell, MA 01854');
INSERT INTO account (email, password, type) VALUES ('Theresa_Schille@uml.edu', '123456', 'instructor');
INSERT INTO instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('TSchille', 'Theresa Schille', 'Professor', 'Department of Mathematics and Statistics', 'Theresa_Schille@uml.edu');
INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES (12345407, 'Olsen', '407', 15);
INSERT INTO time_slot (time_slot_id, day, start_time, end_time) VALUES ('MWF0930_1045', 'MoWeFr', '09:30:00', '10:45:00');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '201', 'Fall', 2020, 'TSchille', 12345407, 'MWF0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '201', 'Fall', 2021, 'TSchille', 12345407, 'MWF0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '201', 'Fall', 2022, 'TSchille', 12345407, 'MWF0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '201', 'Fall', 2023, 'TSchille', 12345407, 'MWF0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '201', 'Fall', 2024, 'TSchille', 12345407, 'MWF0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '201', 'Fall', 2025, 'TSchille', 12345407, 'MWF0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '201', 'Fall', 2026, 'TSchille', 12345407, 'MWF0930_1045');

INSERT INTO account (email, password, type) VALUES ('Sunghye_Yeh@uml.edu', '123456', 'instructor');
INSERT INTO instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('SYeh', 'Sunghye Yeh', 'Professor', 'Department of Mathematics and Statistics', 'Sunghye_Yeh@uml.edu');
INSERT INTO time_slot (time_slot_id, day, start_time, end_time) VALUES ('MWF1100_1215', 'MoWeFr', '11:00:00', '12:15:00');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '202', 'Fall', 2020, 'SYeh', 12345407, 'MWF1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '202', 'Fall', 2021, 'SYeh', 12345407, 'MWF1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '202', 'Fall', 2022, 'SYeh', 12345407, 'MWF1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '202', 'Fall', 2023, 'SYeh', 12345407, 'MWF1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '202', 'Fall', 2024, 'SYeh', 12345407, 'MWF1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '202', 'Fall', 2025, 'SYeh', 12345407, 'MWF1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '202', 'Fall', 2026, 'SYeh', 12345407, 'MWF1100_1215');

INSERT INTO account (email, password, type) VALUES ('Jennifer_GonzalezZugasti@uml.edu', '123456', 'instructor');
INSERT INTO instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('JGonzalezZ', 'Jennifer GonzalezZugasti', 'Professor', 'Department of Mathematics and Statistics', 'Jennifer_GonzalezZugasti@uml.edu');
INSERT INTO time_slot (time_slot_id, day, start_time, end_time) VALUES ('MWF1230_1345', 'MoWeFr', '12:30:00', '13:45:00');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '203', 'Fall', 2020, 'JGonzalezZ', 51328313, 'MWF1230_1345');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '203', 'Fall', 2021, 'JGonzalezZ', 51328313, 'MWF1230_1345');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '203', 'Fall', 2022, 'JGonzalezZ', 51328313, 'MWF1230_1345');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '203', 'Fall', 2023, 'JGonzalezZ', 51328313, 'MWF1230_1345');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '203', 'Fall', 2024, 'JGonzalezZ', 51328313, 'MWF1230_1345');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '203', 'Fall', 2025, 'JGonzalezZ', 51328313, 'MWF1230_1345');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '203', 'Fall', 2026, 'JGonzalezZ', 51328313, 'MWF1230_1345');

INSERT INTO account (email, password, type) VALUES ('Jeanne_Derosa@uml.edu', '123456', 'instructor');
INSERT INTO instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('JDerosa', 'Jeanne Derosa', 'Professor', 'Department of Mathematics and Statistics', 'Jeanne_Derosa@uml.edu');
INSERT INTO time_slot (time_slot_id, day, start_time, end_time) VALUES ('MWF1700_1815', 'MoWeFr', '17:00:00', '18:15:00');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '204', 'Fall', 2020, 'JDerosa', 51328313, 'MWF1700_1815');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '204', 'Fall', 2021, 'JDerosa', 51328313, 'MWF1700_1815');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '204', 'Fall', 2022, 'JDerosa', 51328313, 'MWF1700_1815');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '204', 'Fall', 2023, 'JDerosa', 51328313, 'MWF1700_1815');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '204', 'Fall', 2024, 'JDerosa', 51328313, 'MWF1700_1815');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '204', 'Fall', 2025, 'JDerosa', 51328313, 'MWF1700_1815');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '204', 'Fall', 2026, 'JDerosa', 51328313, 'MWF1700_1815');

INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '201', 'Spring', 2020, 'SYeh', 51328313, 'MWF0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '201', 'Spring', 2021, 'SYeh', 51328313, 'MWF0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '201', 'Spring', 2022, 'SYeh', 51328313, 'MWF0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '201', 'Spring', 2023, 'SYeh', 51328313, 'MWF0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '201', 'Spring', 2024, 'SYeh', 51328313, 'MWF0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '201', 'Spring', 2025, 'SYeh', 51328313, 'MWF0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '201', 'Spring', 2026, 'SYeh', 51328313, 'MWF0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '202', 'Spring', 2020, 'SYeh', 51328313, 'MWF1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '202', 'Spring', 2021, 'SYeh', 51328313, 'MWF1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '202', 'Spring', 2022, 'SYeh', 51328313, 'MWF1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '202', 'Spring', 2023, 'SYeh', 51328313, 'MWF1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '202', 'Spring', 2024, 'SYeh', 51328313, 'MWF1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '202', 'Spring', 2025, 'SYeh', 51328313, 'MWF1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '202', 'Spring', 2026, 'SYeh', 51328313, 'MWF1100_1215');

INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '204', 'Spring', 2020, 'SYeh', 51328313, 'MWF1230_1345');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '204', 'Spring', 2021, 'SYeh', 51328313, 'MWF1230_1345');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '204', 'Spring', 2022, 'SYeh', 51328313, 'MWF1230_1345');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '204', 'Spring', 2023, 'SYeh', 51328313, 'MWF1230_1345');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '204', 'Spring', 2024, 'SYeh', 51328313, 'MWF1230_1345');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '204', 'Spring', 2025, 'SYeh', 51328313, 'MWF1230_1345');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1310', '204', 'Spring', 2026, 'SYeh', 51328313, 'MWF1230_1345');

INSERT INTO course (course_id, course_name, credits) VALUES ('ENGL1020', 'College Writing II', 3);
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '201', 'Fall', 2020, 'TDeFranzo', 12345349, 'MWF1200_1250');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '201', 'Fall', 2021, 'TDeFranzo', 12345349, 'MWF1200_1250');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '201', 'Fall', 2022, 'TDeFranzo', 12345349, 'MWF1200_1250');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '201', 'Fall', 2023, 'TDeFranzo', 12345349, 'MWF1200_1250');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '201', 'Fall', 2024, 'TDeFranzo', 12345349, 'MWF1200_1250');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '201', 'Fall', 2025, 'TDeFranzo', 12345349, 'MWF1200_1250');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '201', 'Fall', 2026, 'TDeFranzo', 12345349, 'MWF1200_1250');

INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '204', 'Fall', 2020, 'JBellipann', 59237107, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '204', 'Fall', 2021, 'JBellipann', 59237107, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '204', 'Fall', 2022, 'JBellipann', 59237107, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '204', 'Fall', 2023, 'JBellipann', 59237107, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '204', 'Fall', 2024, 'JBellipann', 59237107, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '204', 'Fall', 2025, 'JBellipann', 59237107, 'MWF1100_1150');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '204', 'Fall', 2026, 'JBellipann', 59237107, 'MWF1100_1150');

INSERT INTO account (email, password, type) VALUES ('Timothy_Rogers@uml.edu', '123456', 'instructor');
INSERT INTO instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('TRogers', 'Timothy Rogers', 'Professor', 'English Department', 'Timothy_Rogers@uml.edu');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '208', 'Fall', 2020, 'TRogers', 12345353, 'TT1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '208', 'Fall', 2021, 'TRogers', 12345353, 'TT1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '208', 'Fall', 2022, 'TRogers', 12345353, 'TT1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '208', 'Fall', 2023, 'TRogers', 12345353, 'TT1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '208', 'Fall', 2024, 'TRogers', 12345353, 'TT1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '208', 'Fall', 2025, 'TRogers', 12345353, 'TT1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '208', 'Fall', 2026, 'TRogers', 12345353, 'TT1100_1215');

INSERT INTO account (email, password, type) VALUES ('Sara_Backer@uml.edu', '123456', 'instructor');
INSERT INTO instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('SBacker', 'Sara Backer', 'Professor', 'English Department', 'Sara_Backer@uml.edu');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '201', 'Spring', 2020, 'SBacker', 59237107, 'TT0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '201', 'Spring', 2021, 'SBacker', 59237107, 'TT0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '201', 'Spring', 2022, 'SBacker', 59237107, 'TT0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '201', 'Spring', 2023, 'SBacker', 59237107, 'TT0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '201', 'Spring', 2024, 'SBacker', 59237107, 'TT0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '201', 'Spring', 2025, 'SBacker', 59237107, 'TT0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '201', 'Spring', 2026, 'SBacker', 59237107, 'TT0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '202', 'Spring', 2020, 'SBacker', 59237107, 'TT1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '202', 'Spring', 2021, 'SBacker', 59237107, 'TT1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '202', 'Spring', 2022, 'SBacker', 59237107, 'TT1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '202', 'Spring', 2023, 'SBacker', 59237107, 'TT1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '202', 'Spring', 2024, 'SBacker', 59237107, 'TT1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '202', 'Spring', 2025, 'SBacker', 59237107, 'TT1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('ENGL1020', '202', 'Spring', 2026, 'SBacker', 59237107, 'TT1100_1215');

INSERT INTO prereq (course_id, prereq_id) VALUES ('ENGL1020', 'ENGL1010');
INSERT INTO course (course_id, course_name, credits) VALUES ('MATH1320', 'Calculus II', 4);
INSERT INTO account (email, password, type) VALUES ('Howard_Troughton@uml.edu', '123456', 'instructor');
INSERT INTO instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('HTroughton', 'Howard Troughton', 'Professor', 'Department of Mathematics and Statistics', 'Howard_Troughton@uml.edu');
INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES (12345405, 'Olsen', '405', 15);
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '201', 'Fall', 2020, 'HTroughton', 12345405, 'MWF0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '201', 'Fall', 2021, 'HTroughton', 12345405, 'MWF0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '201', 'Fall', 2022, 'HTroughton', 12345405, 'MWF0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '201', 'Fall', 2023, 'HTroughton', 12345405, 'MWF0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '201', 'Fall', 2024, 'HTroughton', 12345405, 'MWF0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '201', 'Fall', 2025, 'HTroughton', 12345405, 'MWF0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '201', 'Fall', 2026, 'HTroughton', 12345405, 'MWF0930_1045');

INSERT INTO account (email, password, type) VALUES ('Carly_Briggs@uml.edu', '123456', 'instructor');
INSERT INTO instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('CBriggs', 'Carly Briggs', 'Professor', 'Department of Mathematics and Statistics', 'Carly_Briggs@uml.edu');
INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES (51328309, 'Falmouth Hall', '309', 15);
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '202', 'Fall', 2020, 'CBriggs', 51328309, 'MWF1230_1345');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '202', 'Fall', 2021, 'CBriggs', 51328309, 'MWF1230_1345');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '202', 'Fall', 2022, 'CBriggs', 51328309, 'MWF1230_1345');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '202', 'Fall', 2023, 'CBriggs', 51328309, 'MWF1230_1345');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '202', 'Fall', 2024, 'CBriggs', 51328309, 'MWF1230_1345');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '202', 'Fall', 2025, 'CBriggs', 51328309, 'MWF1230_1345');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '202', 'Fall', 2026, 'CBriggs', 51328309, 'MWF1230_1345');

INSERT INTO account (email, password, type) VALUES ('Thoa_Tran@uml.edu', '123456', 'instructor');
INSERT INTO instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('TTran', 'Thoa Tran', 'Professor', 'Department of Mathematics and Statistics', 'Thoa_Tran@uml.edu');
INSERT INTO time_slot (time_slot_id, day, start_time, end_time) VALUES ('MWF1400_1515', 'MoWeFr', '14:00:00', '15:15:00');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '203', 'Fall', 2020, 'TTran', 51328313, 'MWF1400_1515');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '203', 'Fall', 2021, 'TTran', 51328313, 'MWF1400_1515');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '203', 'Fall', 2022, 'TTran', 51328313, 'MWF1400_1515');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '203', 'Fall', 2023, 'TTran', 51328313, 'MWF1400_1515');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '203', 'Fall', 2024, 'TTran', 51328313, 'MWF1400_1515');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '203', 'Fall', 2025, 'TTran', 51328313, 'MWF1400_1515');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '203', 'Fall', 2026, 'TTran', 51328313, 'MWF1400_1515');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '204', 'Fall', 2020, 'TTran', 51328313, 'MWF1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '204', 'Fall', 2021, 'TTran', 51328313, 'MWF1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '204', 'Fall', 2022, 'TTran', 51328313, 'MWF1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '204', 'Fall', 2023, 'TTran', 51328313, 'MWF1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '204', 'Fall', 2024, 'TTran', 51328313, 'MWF1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '204', 'Fall', 2025, 'TTran', 51328313, 'MWF1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '204', 'Fall', 2026, 'TTran', 51328313, 'MWF1100_1215');

INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES (12345109, 'Olsen', '109', 15);
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '202', 'Spring', 2020, 'HTroughton', 12345109, 'MWF0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '202', 'Spring', 2021, 'HTroughton', 12345109, 'MWF0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '202', 'Spring', 2022, 'HTroughton', 12345109, 'MWF0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '202', 'Spring', 2023, 'HTroughton', 12345109, 'MWF0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '202', 'Spring', 2024, 'HTroughton', 12345109, 'MWF0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '202', 'Spring', 2025, 'HTroughton', 12345109, 'MWF0930_1045');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '202', 'Spring', 2026, 'HTroughton', 12345109, 'MWF0930_1045');

INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '204', 'Spring', 2020, 'HTroughton', 12345109, 'MWF1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '204', 'Spring', 2021, 'HTroughton', 12345109, 'MWF1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '204', 'Spring', 2022, 'HTroughton', 12345109, 'MWF1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '204', 'Spring', 2023, 'HTroughton', 12345109, 'MWF1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '204', 'Spring', 2024, 'HTroughton', 12345109, 'MWF1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '204', 'Spring', 2025, 'HTroughton', 12345109, 'MWF1100_1215');
INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ('MATH1320', '204', 'Spring', 2026, 'HTroughton', 12345109, 'MWF1100_1215');

INSERT INTO prereq (course_id, prereq_id) VALUES ('MATH1320', 'MATH1310');
INSERT INTO account (email, password, type) VALUES ('_ADMIN@admin.uml.edu', 'ADMIN12345!', 'admin');
INSERT INTO account (email, password, type) VALUES ('Reggie_Palmer@student.uml.edu', 'Palmer12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('7228188573', 'Reggie Palmer', 'Reggie_Palmer@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('7228188573', NULL, 'Freshman');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('7228188573', 'COMP1010', '102', 'Fall', 2024, 'A');
INSERT INTO account (email, password, type) VALUES ('Tom_Scran@student.uml.edu', 'Scran12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('6822182907', 'Tom Scran', 'Tom_Scran@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('6822182907', NULL, 'Freshman');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('6822182907', 'COMP1010', '102', 'Fall', 2024, 'A');
INSERT INTO account (email, password, type) VALUES ('Martha_Lime@student.uml.edu', 'Lime12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('5321592542', 'Martha Lime', 'Martha_Lime@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('5321592542', NULL, 'Freshman');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('5321592542', 'COMP1010', '102', 'Fall', 2024, 'A');
INSERT INTO account (email, password, type) VALUES ('Grant_Fisher@student.uml.edu', 'Fisher12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('6735339995', 'Grant Fisher', 'Grant_Fisher@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('6735339995', NULL, 'Freshman');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('6735339995', 'COMP1010', '102', 'Fall', 2024, 'A');
INSERT INTO account (email, password, type) VALUES ('Bant_Jane@student.uml.edu', 'Jane12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('2208063399', 'Bant Jane', 'Bant_Jane@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('2208063399', NULL, 'Freshman');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('2208063399', 'COMP1010', '102', 'Fall', 2024, 'A');
INSERT INTO account (email, password, type) VALUES ('Yan_Cran@student.uml.edu', 'Cran12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('2343953623', 'Yan Cran', 'Yan_Cran@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('2343953623', NULL, 'Freshman');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('2343953623', 'COMP1010', '102', 'Fall', 2024, 'B');
INSERT INTO account (email, password, type) VALUES ('Dake_Lin@student.uml.edu', 'Lin12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('1848447223', 'Dake Lin', 'Dake_Lin@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('1848447223', NULL, 'Freshman');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('1848447223', 'COMP1010', '102', 'Fall', 2024, 'B');
INSERT INTO account (email, password, type) VALUES ('Harry_Terr@student.uml.edu', 'Terr12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('4373332281', 'Harry Terr', 'Harry_Terr@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('4373332281', NULL, 'Freshman');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('4373332281', 'COMP1010', '102', 'Fall', 2024, 'B');
INSERT INTO account (email, password, type) VALUES ('Boris_Johnson@student.uml.edu', 'Johnson12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('4167571675', 'Boris Johnson', 'Boris_Johnson@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('4167571675', NULL, 'Freshman');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('4167571675', 'COMP1010', '102', 'Fall', 2024, 'B');
INSERT INTO account (email, password, type) VALUES ('Mark_Billson@student.uml.edu', 'Billson12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('4303781444', 'Mark Billson', 'Mark_Billson@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('4303781444', NULL, 'Freshman');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('4303781444', 'COMP1010', '102', 'Fall', 2024, 'B');
INSERT INTO account (email, password, type) VALUES ('Cart_Fillson@student.uml.edu', 'Fillson12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('9803320855', 'Cart Fillson', 'Cart_Fillson@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('9803320855', NULL, 'Freshman');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('9803320855', 'COMP1010', '102', 'Fall', 2024, 'C');
INSERT INTO account (email, password, type) VALUES ('Indi_Huff@student.uml.edu', 'Huff12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('9742609370', 'Indi Huff', 'Indi_Huff@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('9742609370', NULL, 'Freshman');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('9742609370', 'COMP1010', '102', 'Fall', 2024, 'C');
INSERT INTO account (email, password, type) VALUES ('Vart_Stinky@student.uml.edu', 'Stinky12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('9964141999', 'Vart Stinky', 'Vart_Stinky@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('9964141999', NULL, 'Freshman');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('9964141999', 'COMP1010', '102', 'Fall', 2024, 'C');
INSERT INTO account (email, password, type) VALUES ('Lois_Roberts@student.uml.edu', 'Roberts12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('2771915910', 'Lois Roberts', 'Lois_Roberts@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('2771915910', NULL, 'Freshman');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('2771915910', 'COMP1010', '102', 'Fall', 2024, 'D');
INSERT INTO account (email, password, type) VALUES ('Jake_Fake@student.uml.edu', 'Fake12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('4626169361', 'Jake Fake', 'Jake_Fake@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('4626169361', NULL, 'Freshman');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('4626169361', 'COMP1010', '102', 'Fall', 2024, 'D');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('7228188573', 'COMP1020', '102', 'Spring', 2024, Null);
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('6822182907', 'COMP1020', '102', 'Spring', 2024, Null);
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('5321592542', 'COMP1020', '102', 'Spring', 2024, Null);
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('6735339995', 'COMP1020', '102', 'Spring', 2024, Null);
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('2208063399', 'COMP1020', '102', 'Spring', 2024, Null);
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('2343953623', 'COMP1020', '102', 'Spring', 2024, Null);
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('1848447223', 'COMP1020', '102', 'Spring', 2024, Null);
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('4373332281', 'COMP1020', '102', 'Spring', 2024, Null);
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('4167571675', 'COMP1020', '102', 'Spring', 2024, Null);
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('4303781444', 'COMP1020', '102', 'Spring', 2024, Null);
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('9803320855', 'COMP1020', '102', 'Spring', 2024, Null);
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('9742609370', 'COMP1020', '102', 'Spring', 2024, Null);
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('9964141999', 'COMP1020', '102', 'Spring', 2024, Null);
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('2771915910', 'COMP1020', '102', 'Spring', 2024, Null);
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('4626169361', 'COMP1020', '102', 'Spring', 2024, Null);
INSERT INTO account (email, password, type) VALUES ('Swon_Lons@student.uml.edu', 'Lons12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('3628424455', 'Swon Lons', 'Swon_Lons@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('3628424455', NULL, 'Sophomore');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('3628424455', 'COMP1010', '102', 'Fall', 2022, 'C');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('3628424455', 'COMP1020', '102', 'Spring', 2023, 'B');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('3628424455', 'COMP2010', '101', 'Spring', 2024, Null);
INSERT INTO account (email, password, type) VALUES ('Hip_Campus@student.uml.edu', 'Campus12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('8035769270', 'Hip Campus', 'Hip_Campus@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('8035769270', NULL, 'Sophomore');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('8035769270', 'COMP1010', '102', 'Fall', 2022, 'A');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('8035769270', 'COMP1020', '102', 'Spring', 2023, 'C');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('8035769270', 'COMP2010', '101', 'Spring', 2024, Null);
INSERT INTO account (email, password, type) VALUES ('Jim_Milton@student.uml.edu', 'Milton12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('4790836199', 'Jim Milton', 'Jim_Milton@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('4790836199', NULL, 'Sophomore');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('4790836199', 'COMP1010', '102', 'Fall', 2022, 'A');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('4790836199', 'COMP1020', '102', 'Spring', 2023, 'B');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('4790836199', 'COMP2010', '101', 'Spring', 2024, Null);
INSERT INTO account (email, password, type) VALUES ('Jackie_Willis@student.uml.edu', 'Willis12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('2647709714', 'Jackie Willis', 'Jackie_Willis@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('2647709714', NULL, 'Sophomore');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('2647709714', 'COMP1010', '102', 'Fall', 2022, 'A');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('2647709714', 'COMP1020', '102', 'Spring', 2023, 'A');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('2647709714', 'COMP2010', '101', 'Spring', 2024, Null);
INSERT INTO account (email, password, type) VALUES ('Payton_Apple@student.uml.edu', 'Apple12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('8325270564', 'Payton Apple', 'Payton_Apple@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('8325270564', NULL, 'Sophomore');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('8325270564', 'COMP1010', '102', 'Fall', 2022, 'B');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('8325270564', 'COMP1020', '102', 'Spring', 2023, 'A');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('8325270564', 'COMP2010', '101', 'Spring', 2024, Null);
INSERT INTO account (email, password, type) VALUES ('Garff_Eild@student.uml.edu', 'Eild12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('6890851849', 'Garff Eild', 'Garff_Eild@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('6890851849', NULL, 'Sophomore');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('6890851849', 'COMP1010', '102', 'Fall', 2022, 'B');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('6890851849', 'COMP1020', '102', 'Spring', 2023, 'A');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('6890851849', 'COMP2010', '101', 'Spring', 2024, Null);
INSERT INTO account (email, password, type) VALUES ('Clark_Tent@student.uml.edu', 'Tent12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('7885172279', 'Clark Tent', 'Clark_Tent@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('7885172279', NULL, 'Junior');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('7885172279', 'COMP1010', '102', 'Fall', 2022, 'C');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('7885172279', 'COMP1020', '102', 'Spring', 2023, 'A');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('7885172279', 'COMP2010', '101', 'Fall', 2023, 'D');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('7885172279', 'COMP2040', '202', 'Spring', 2024, Null);
INSERT INTO account (email, password, type) VALUES ('John_Kins@student.uml.edu', 'Kins12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('3451498131', 'John Kins', 'John_Kins@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('3451498131', NULL, 'Freshman');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('3451498131', 'COMP1010', '102', 'Spring', 2024, Null);
INSERT INTO account (email, password, type) VALUES ('Kasse_Kins@student.uml.edu', 'Kins12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('1139624932', 'Kasse Kins', 'Kasse_Kins@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('1139624932', NULL, 'Freshman');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('1139624932', 'COMP1010', '102', 'Spring', 2024, Null);
INSERT INTO account (email, password, type) VALUES ('Marty_Kins@student.uml.edu', 'Kins12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('8000058993', 'Marty Kins', 'Marty_Kins@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('8000058993', NULL, 'Freshman');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('8000058993', 'COMP1010', '102', 'Spring', 2024, Null);
INSERT INTO account (email, password, type) VALUES ('Edward_Kins@student.uml.edu', 'Kins12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('3073708599', 'Edward Kins', 'Edward_Kins@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('3073708599', NULL, 'Freshman');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('3073708599', 'COMP1010', '102', 'Spring', 2024, Null);
INSERT INTO account (email, password, type) VALUES ('Dart_Kins@student.uml.edu', 'Kins12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('3390966239', 'Dart Kins', 'Dart_Kins@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('3390966239', NULL, 'Freshman');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('3390966239', 'COMP1010', '102', 'Spring', 2024, Null);
INSERT INTO account (email, password, type) VALUES ('Mary_Kins@student.uml.edu', 'Kins12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('5034995828', 'Mary Kins', 'Mary_Kins@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('5034995828', NULL, 'Freshman');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('5034995828', 'COMP1010', '102', 'Spring', 2024, Null);
INSERT INTO account (email, password, type) VALUES ('Stan_Upson@student.uml.edu', 'Upson12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('9815022415', 'Stan Upson', 'Stan_Upson@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO master (student_id, total_credits) VALUES ('9815022415', Null);
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('9815022415', 'COMP1010', '102', 'Fall', 2022, 'C');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('9815022415', 'COMP1020', '102', 'Spring', 2023, 'A');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('9815022415', 'COMP2010', '101', 'Fall', 2023, 'D');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('9815022415', 'COMP2040', '202', 'Spring', 2024, 'A');
INSERT INTO account (email, password, type) VALUES ('Kate_Upson@student.uml.edu', 'Upson12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('4145368776', 'Kate Upson', 'Kate_Upson@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO master (student_id, total_credits) VALUES ('4145368776', Null);
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('4145368776', 'COMP1010', '102', 'Fall', 2022, 'A');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('4145368776', 'COMP1020', '102', 'Spring', 2023, 'A');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('4145368776', 'COMP2010', '101', 'Fall', 2023, 'A');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('4145368776', 'COMP2040', '202', 'Spring', 2024, 'A');
INSERT INTO account (email, password, type) VALUES ('Phil_Yards@student.uml.edu', 'Yards12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('7542734628', 'Phil Yards', 'Phil_Yards@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO phd (student_id, qualifier, proposal_defence_date, dissertation_defence_date) VALUES ('7542734628', Null, Null, Null);
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('7542734628', 'COMP1010', '102', 'Fall', 2022, 'A');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('7542734628', 'COMP1020', '102', 'Spring', 2023, 'A');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('7542734628', 'COMP2010', '101', 'Fall', 2023, 'D');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('7542734628', 'COMP2040', '202', 'Spring', 2024, 'A');
INSERT INTO account (email, password, type) VALUES ('John_Bins@student.uml.edu', 'Bins12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('2683556838', 'John Bins', 'John_Bins@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('2683556838', NULL, 'Freshman');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('2683556838', 'COMP1010', '103', 'Spring', 2024, Null);
INSERT INTO account (email, password, type) VALUES ('Kasse_Bins@student.uml.edu', 'Bins12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('6292695509', 'Kasse Bins', 'Kasse_Bins@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('6292695509', NULL, 'Freshman');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('6292695509', 'COMP1010', '103', 'Spring', 2024, Null);
INSERT INTO account (email, password, type) VALUES ('Marty_Bins@student.uml.edu', 'Bins12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('2330993603', 'Marty Bins', 'Marty_Bins@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('2330993603', NULL, 'Freshman');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('2330993603', 'COMP1010', '103', 'Spring', 2024, Null);
INSERT INTO account (email, password, type) VALUES ('Edward_Bins@student.uml.edu', 'Bins12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('3373858409', 'Edward Bins', 'Edward_Bins@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('3373858409', NULL, 'Freshman');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('3373858409', 'COMP1010', '103', 'Spring', 2024, Null);
INSERT INTO account (email, password, type) VALUES ('Dart_Bins@student.uml.edu', 'Bins12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('2393386608', 'Dart Bins', 'Dart_Bins@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('2393386608', NULL, 'Freshman');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('2393386608', 'COMP1010', '103', 'Spring', 2024, Null);
INSERT INTO account (email, password, type) VALUES ('Mary_Bins@student.uml.edu', 'Bins12345!', 'student');
INSERT INTO student (student_id, name, email, dept_name) VALUES ('4329127794', 'Mary Bins', 'Mary_Bins@student.uml.edu', 'Miner School of Computer & Information Sciences');
INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES ('4329127794', NULL, 'Freshman');
INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ('4329127794', 'COMP1010', '103', 'Spring', 2024, Null);
INSERT INTO account (email, password, type) VALUES ('admin@uml.edu', '123456', 'admin');
