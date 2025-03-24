building_codes = {
  "Olsen": 123456,
  "Perry": 592371,
  "Lydon": 301739
}

ACCOUNTS = []
DEPARTMENTS = []
INSTRUCTORS = []
CLASSROOMS = []
TIMESLOTS = []
COURSES = []

def create_account(email, pswd, _type):
    if email in ACCOUNTS:
        return ""
    ACCOUNTS.append(email)
    return "INSERT INTO account (email, password, type) VALUES ('" + email + "', '" + pswd + "', '" + _type + "');\n"

def create_instructor(firstname, lastname, title, department, email):
    if email in INSTRUCTORS:
        return ""
    r = ""
    if email not in ACCOUNTS:
        r += create_account(email, '123456', 'instructor')
    if department not in DEPARTMENTS:
        r += create_department(department, 'unknown')

    r += "INSERT INTO instructor (instructor_id, instructor_name, title, dept_name, email) VALUES ('" 
    r += firstname[:1] + lastname[:9] + "', '" + firstname + " " + lastname + "', " 
    r += "'" + title + "', "
    r += "'" + department + "', "
    r += "'" + email + "');\n"
    INSTRUCTORS.append(email)
    return r

def create_department(name, location):
    if name in DEPARTMENTS:
        return ""
    DEPARTMENTS.append(name)
    return "INSERT INTO department (dept_name, location) VALUES ('" + name + "', '" + location + "');\n"

def create_time_slot(timeid, days, start_time, end_time):
    TIMESLOTS.append(timeid)
    r = "INSERT INTO time_slot (time_slot_id, day, start_time, end_time) VALUES ("
    r += "'" + timeid + "', "
    r += "'" + days + "', "
    r += "'" + start_time + "', "
    r += "'" + end_time + "');\n"
    return r

def create_classroom(classroom_id, building_name, room_num, capacity):
    CLASSROOMS.append(classroom_id)
    r = "INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES ("
    r += "" + str(classroom_id) + ", "
    r += "'" + building_name + "', "
    r += "'" + room_num + "', "
    r += str(capacity) + ");\n"
    return r

def create_course(course_id, course_name, credits):
    COURSES.append(course_id)
    r = "INSERT INTO course (course_id, course_name, credits) VALUES ("
    r += "'" + course_id + "', '" + course_name + "', " + str(credits) + ")\n"
    return r

def make_years(course, sec, sem, s, e, instr, classid, tim, occ):
    r = ""
    prefixx = "INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id, occupancy) VALUES ("
    while (s <= e):
        r += prefixx
        r += "'" + course + "', "
        r += "'" + sec + "', "
        r += "'" + sem + "', "
        r += str(s) + ", "
        r += "'" + instr + "', "
        r += str(classid) + ", "
        r += "'" + tim + "', "
        r += str(occ) + ");\n"
        s += 1
    return r

def make_section(course_id, course_name, course_credits,
                 section_id,
                 instruct_firstname, instruct_lastname,
                 instruct_title, instruct_email,
                 dept_name, dept_location,
                 cr_building, cr_roomnum, cr_capacity,
                 _semester, startyear, endyear,
                 ts_day, ts_start, ts_end):
    r = ""
    if course_id not in COURSES:
        r += create_course(course_id, course_name, course_credits)
    if dept_name not in DEPARTMENTS:
        r += create_department(dept_name, dept_location)
    instruct_id = instruct_firstname[:1] + instruct_lastname[:9]
    if instruct_id not in INSTRUCTORS:
        r += create_instructor(instruct_firstname, instruct_lastname, instruct_title, dept_name, instruct_email)
    classroom_id = int(str(building_codes[cr_building]) + str(cr_roomnum))
    if classroom_id not in CLASSROOMS:
        r += create_classroom(classroom_id, cr_building, cr_roomnum, cr_capacity)
    time_slot_id = ""
    for d in ts_day:
        if d.isupper():
            time_slot_id += d
    time_slot_id += ts_start[:2] + ts_start[3:5] + "_" + ts_end[:2] + ts_end[3:5]
    if time_slot_id not in TIMESLOTS:
        r += create_time_slot(time_slot_id, ts_day, ts_start, ts_end)
    r += make_years(course_id, section_id, _semester, startyear, endyear, instruct_id, classroom_id, time_slot_id, 0)
    return r

full = ""
full += make_section("ENGL1010", "College Writing I", 3,
                 "202",
                 "Michael", "Baron",
                 "Part time faculty", "Micheal_Baron@uml.edu",
                 "English Department", "OLeary Library, 61 Wilder Street, Lowell, MA 01854",
                 "Olsen", "353", 15,
                 "Fall", 2020, 2026,
                 "MoWeFr", "10:00:00", "10:50:00")

full += make_section("ENGL1010", "College Writing I", 3,
                 "204",
                 "Jason", "Bellipanni",
                 "Professor", "Jason_Bellipanni@uml.edu",
                 "English Department", "OLeary Library, 61 Wilder Street, Lowell, MA 01854",
                 "Olsen", "349", 15,
                 "Fall", 2020, 2026,
                 "MoWeFr", "08:00:00", "08:50:00")
print(full)
#course_id -> course_id, course_name, credits
#section_id 
#instructor_id ->    instructor_id
#                    firstname
#                    lastname
#                    title
#                    email
#                    dept_name ->    dept_name
#                                    location
#classroom_id ->     classroom_id
#                    building
#                    room_number
#                    capacity
#semester
#year
#time_slot_id ->     time_slot_id
#                    day
#                    start
#                    end
#
#print(make_years('ENGL1010', '202', 'Fall', 2020, 2026, 'MBaron', 123456353, 'MWF10', 0))

#print(make_years('ENGL1010', '203', 'Fall', 2020, 2026, 'MBaron', 123456353, 'MWF11', 0))

#print(make_years('ENGL1010', '204', 'Fall', 2020, 2026, 'JBellipan', 123456349, 'MWF8', 0))

#print(make_years('ENGL1010', '205', 'Fall', 2020, 2026, 'JBellipan', 123456349, 'MWF9', 0))

#print(make_years('ENGL1010', '206', 'Fall', 2020, 2026, 'DBerard', 123456106, 'MW1530', 0))

#print(make_years('ENGL1010', '207', 'Fall', 2020, 2026, 'DBerard', 123456106, 'MW17', 0))

#print(make_years('MATH1310', '201', 'Fall', 2020, 2026, 'YSunghye', 869755407, '', 0))

#print(make_years('MATH1310', '202', 'Fall', 2020, 2026, '', 123456353, '', 0))

#print(make_years('MATH1310', '2-3', 'Fall', 2020, 2026, '', 123456353, '', 0))
