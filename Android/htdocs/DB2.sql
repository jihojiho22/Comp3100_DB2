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

-- Add capacity column to existing section table if it doesn't exist
ALTER TABLE section ADD COLUMN IF NOT EXISTS capacity numeric(3,0) DEFAULT 15;


INSERT INTO course (course_id, course_name, credits)
VALUES 
('CS101', 'Introduction to Computer Science', 4),
('CS202', 'Data Structures and Algorithms', 3);

INSERT INTO instructor (instructor_id, instructor_name, title, dept_name, email)
VALUES
('I001', 'Dr. John Doe', 'Professor', 'Computer Science', 'john.doe@example.com'),
('I002', 'Dr. Jane Smith', 'Assistant Professor', 'Computer Science', 'jane.smith@example.com');


INSERT INTO time_slot (time_slot_id, day, start_time, end_time)
VALUES
('TS101', 'Monday', '09:00:00', '10:30:00'),
('TS102', 'Wednesday', '14:00:00', '15:30:00');


INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id)
VALUES
('CS101', 'A01', 'Fall', 2025, 'I001', 'R101', 'TS101'),
('CS202', 'B01', 'Winter', 2025, 'I002', 'R202', 'TS102');

