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
    PRIMARY KEY (instructor_id, student_id, section_id, course_id),
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
	(time_slot_id		varchar(8),
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
	 time_slot_id		varchar(8),	
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



insert into account (email, password, type) values ('admin@uml.edu', '123456', 'admin');
insert into account (email, password, type) values ('dbadams@cs.uml.edu', '123456', 'instructor');
insert into account (email, password, type) values ('slin@cs.uml.edu', '123456', 'instructor');
insert into account (email, password, type) values ('Yelena_Rykalova@uml.edu', '123456', 'instructor');
insert into account (email, password, type) values ('Johannes_Weis@uml.edu', '123456', 'instructor');
insert into account (email, password, type) values ('Charles_Wilkes@uml.edu', '123456', 'instructor');


insert into course (course_id, course_name, credits) values ('COMP1010', 'Computing I', 3);
insert into course (course_id, course_name, credits) values ('COMP1020', 'Computing II', 3);
insert into course (course_id, course_name, credits) values ('COMP2010', 'Computing III', 3);
insert into course (course_id, course_name, credits) values ('COMP2040', 'Computing IV', 3);

insert into department (dept_name, location) value ('Miner School of Computer & Information Sciences', 'Dandeneau Hall, 1 University Avenue, Lowell, MA 01854');

insert into instructor (instructor_id, instructor_name, title, dept_name, email) value ('1', 'David Adams', 'Teaching Professor', 'Miner School of Computer & Information Sciences','dbadams@cs.uml.edu');
insert into instructor (instructor_id, instructor_name, title, dept_name, email) value ('2', 'Sirong Lin', 'Associate Teaching Professor', 'Miner School of Computer & Information Sciences','slin@cs.uml.edu');
insert into instructor (instructor_id, instructor_name, title, dept_name, email) value ('3', 'Yelena Rykalova', 'Associate Teaching Professor', 'Miner School of Computer & Information Sciences', 'Yelena_Rykalova@uml.edu');
insert into instructor (instructor_id, instructor_name, title, dept_name, email) value ('4', 'Johannes Weis', 'Assistant Teaching Professor', 'Miner School of Computer & Information Sciences','Johannes_Weis@uml.edu');
insert into instructor (instructor_id, instructor_name, title, dept_name, email) value ('5', 'Tom Wilkes', 'Assistant Teaching Professor', 'Miner School of Computer & Information Sciences','Charles_Wilkes@uml.edu');

insert into time_slot (time_slot_id, day, start_time, end_time) value ('TS1', 'MoWeFr', '11:00:00', '11:50:00');
insert into time_slot (time_slot_id, day, start_time, end_time) value ('TS2', 'MoWeFr', '12:00:00', '12:50:00');
insert into time_slot (time_slot_id, day, start_time, end_time) value ('TS3', 'MoWeFr', '13:00:00', '13:50:00');
insert into time_slot (time_slot_id, day, start_time, end_time) value ('TS4', 'TuTh', '11:00:00', '12:15:00');
insert into time_slot (time_slot_id, day, start_time, end_time) value ('TS5', 'TuTh', '12:30:00', '13:45:00');

insert into section (course_id, section_id, semester, year) value ('COMP1010', 'Section101', 'Fall', 2023);
insert into section (course_id, section_id, semester, year) value ('COMP1010', 'Section102', 'Fall', 2023);
insert into section (course_id, section_id, semester, year) value ('COMP1010', 'Section103', 'Fall', 2023);
insert into section (course_id, section_id, semester, year) value ('COMP1010', 'Section104', 'Fall', 2023);
insert into section (course_id, section_id, semester, year) value ('COMP1020', 'Section101', 'Spring', 2024);
insert into section (course_id, section_id, semester, year) value ('COMP1020', 'Section102', 'Spring', 2024);
insert into section (course_id, section_id, semester, year) value ('COMP2010', 'Section101', 'Fall', 2023);
insert into section (course_id, section_id, semester, year) value ('COMP2010', 'Section102', 'Fall', 2023);
insert into section (course_id, section_id, semester, year) value ('COMP2040', 'Section201', 'Spring', 2024);

INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES (108115340, "Olsen", 340, 15);
INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES (111108215, "Olsen", 215, 15);
INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES (101251110, "Olsen", 110, 15);
INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES (151353413, "Olsen", 413, 15);
INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES (139553221, "Shay", 221, 15);
INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES (135153312, "Shay", 312, 15);
INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES (135195164, "Shay", 164, 15);
INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES (810357424, "Shay", 424, 15);
INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES (083513132, "Falmouth", 132, 15);
INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES (125336421, "Falmouth", 421, 15);
INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES (527223253, "Ball", 253, 15);
INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES (136161135, "Ball", 135, 15);
INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES (624623344, "Ball", 344, 15);
INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES (246262243, "Weed", 243, 15);
INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES (136161241, "Olney", 241, 15);
INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES (360953110, "Olney", 110, 15);

INSERT INTO `prereq`(`course_id`, `prereq_id`) VALUES ('COMP1020','COMP1010');
INSERT INTO `prereq`(`course_id`, `prereq_id`) VALUES ('COMP2010','COMP1010');
INSERT INTO `prereq`(`course_id`, `prereq_id`) VALUES ('COMP2010','COMP1020');
INSERT INTO `prereq`(`course_id`, `prereq_id`) VALUES ('COMP2040','COMP1010');
INSERT INTO `prereq`(`course_id`, `prereq_id`) VALUES ('COMP2040','COMP1020');
INSERT INTO `prereq`(`course_id`, `prereq_id`) VALUES ('COMP2040','COMP2010');
