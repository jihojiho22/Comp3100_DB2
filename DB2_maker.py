import random

def gen_studentID():
  return str(random.randint(10**9, (10**10) - 1))

OLS = "Olsen"
LYD = "Lydon Library"
SHA = "Shah Hall"
FAL = "Falmouth Hall"
PER = "Perry Hall"

building_codes = {
  OLS: 12345,
  PER: 59237,
  LYD: 30173,
  SHA : 74275,
  FAL : 51328
}

ACCOUNTS = []
DEPARTMENTS = []
INSTRUCTORS = []
CLASSROOMS = []
TIMESLOTS = []
COURSES = []
STUDENTS = {}

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
    #print(timeid)
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
    r += "'" + course_id + "', '" + course_name + "', " + str(credits) + ");\n"
    return r

def make_years(course, sec, sem, s, e, instr, classid, tim):
    r = ""
    prefixx = "INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES ("
    while (s <= e):
        r += prefixx
        r += "'" + course + "', "
        r += "'" + sec + "', "
        r += "'" + sem + "', "
        r += str(s) + ", "
        r += "'" + instr + "', "
        r += str(classid) + ", "
        r += "'" + tim + "');\n"
        s += 1
    return r

def make_prereq(course_info, prereq_course_info):
    return "INSERT INTO prereq (course_id, prereq_id) VALUES ('" + course_info[0] + "', '" + prereq_course_info[0] +"');" + "\n"


def make_undergrad(student_firstname, student_lastname, dept_name, standing):
    r = ""
    student_email = student_firstname + "_" + student_lastname + "@student.uml.edu"
    if student_email not in STUDENTS:
        r += make_student(student_firstname, student_lastname, dept_name)
    r += "INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES (\'"
    r += STUDENTS[student_email] + "\', "
    r += "NULL, \'" + standing + "\');\n"
    return r

def make_master(student_firstname, student_lastname, dept_name, student_info):
    r = ""
    student_email = student_firstname + "_" + student_lastname + "@student.uml.edu"
    if student_email not in STUDENTS:
        r += make_student(student_firstname, student_lastname, dept_name)
    r += "INSERT INTO master (student_id, total_credits) VALUES (\'"
    r += STUDENTS[student_email] + "\', "
    r += student_info + ");\n"
    return r

def make_phd(student_firstname, student_lastname, dept_name, student_info):
    r = ""
    student_email = student_firstname + "_" + student_lastname + "@student.uml.edu"
    if student_email not in STUDENTS:
        r += make_student(student_firstname, student_lastname, dept_name)

    r += "INSERT INTO phd (student_id, qualifier, proposal_defence_date, dissertation_defence_date) VALUES (\'"
    r += STUDENTS[student_email] + "\', "
    r += student_info[0] + ", "
    r += student_info[1] + ", "
    r += student_info[2] + ");\n"
    return r

def make_student(student_firstname, student_lastname, dept_name):
    r = ""
    student_name = student_firstname + " " + student_lastname
    student_email = student_firstname + "_" + student_lastname + "@student.uml.edu"
    if student_email not in ACCOUNTS:
        r += create_account(student_email, student_lastname + "12345!", "student")

    if student_email not in STUDENTS:
        possible_id = gen_studentID()
        while possible_id in STUDENTS.values():
            possible_id = gen_studentID()
        STUDENTS[student_email] = possible_id

        r += "INSERT INTO student (student_id, name, email, dept_name) VALUES (\'"
        r += possible_id + "\', "
        r += "\'" + student_name + "\', "
        r += "\'" + student_email + "\', "
        r += "\'" + dept_name + "\');\n"
        
    return r

def add_student_to(student_info, course_info, section_id, semester, year, grade):
    r = ""
    # student_info = [student_firstname, student_lastname, dept_name, grad_type, grad_type_info]
    student_name = student_info[0] + " " + student_info[1]
    student_email = student_info[0] + "_" + student_info[1] + "@student.uml.edu"
    if student_email not in STUDENTS:
        if student_info[3] == "PHD":
            r += make_phd(student_info[0], student_info[1], student_info[2], student_info[4])
        elif student_info[3] == "MASTERS":
            r += make_master(student_info[0], student_info[1], student_info[2], student_info[4][0])
        else:
            r += make_undergrad(student_info[0], student_info[1], student_info[2], student_info[4][0])
    r += "INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES ("
    r += "\'" + STUDENTS[student_email] + "\', "
    r += "\'" + course_info[0] + "\', "
    r += "\'" + section_id + "\', "
    r += "\'" + semester + "\', "
    r += str(year) + ", "
    r += grade + ");\n"
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
    if (_semester == BOTH):
        r += make_years(course_id, section_id, "Fall", startyear, endyear, instruct_id, classroom_id, time_slot_id)
        r += make_years(course_id, section_id, "Spring", startyear, endyear, instruct_id, classroom_id, time_slot_id)
    else:
        r += make_years(course_id, section_id, _semester, startyear, endyear, instruct_id, classroom_id, time_slot_id)

    return r

def make_sections_single(course_id, course_name, course_credits,
                  dept_name, dept_location, section_info):
    #section_info is a list
    # section_info[0] = [start_section_number, end_section_number]
    # section_info[1] = [instruct_firstname, instructor_lastname, instructor_title, instruct_email]
    # section_info[2] = [classroom_building, classroom_number, classroom_capacity]
    # section_info[3] = [semester, start_year, end_year]
    # section_info[4] = [ts_day]
    # section_info[5] = [[start_time_0, end_time_0], [start_time_1, end_time_1], ... [start_time_n, end_time_n] ]
    # where n = end_section_number - start_section_number
    # start_time_x and end_time_x are the time periods for the section number (start_section_number + x)
    INSTRUCTOR = 1
    CLASSROOM = 2

    r = ""
    i = 0
    current_section_num = section_info[0][0]
    while (current_section_num <= section_info[0][1]):
        r += make_section(course_id, course_name, course_credits,
                 str(current_section_num),
                 section_info[INSTRUCTOR][0], section_info[INSTRUCTOR][1],
                 section_info[INSTRUCTOR][2], section_info[INSTRUCTOR][3],
                 dept_name, dept_location,
                 section_info[CLASSROOM][0], section_info[CLASSROOM][1], section_info[CLASSROOM][2],
                 section_info[3][0], section_info[3][1], section_info[3][2],
                 section_info[4][0], section_info[5][i][0], section_info[5][i][1])
        i += 1
        current_section_num += 1  
    return r

def make_sections_all(course_info, dept_info, all_section_infos):
    # course_info = [course_id, course_name, course_credits]
    # dept_info = [dept_name, dept_location]
    # all_section_infos is a list of section_info, see make_sections_single() to see section_info definition
    r = ""
    for section_info in all_section_infos:
        r += make_sections_single(course_info[0], course_info[1], course_info[2], dept_info[0], dept_info[1], section_info) + "\n"
    return r
    
def make_admin(firstname, lastname):
    admin_email = firstname + "_" + lastname + "@admin.uml.edu"
    return create_account(admin_email, lastname + "12345!", "admin")

_ENGLISH_DEPARTMENT_NAME = "English Department"
_ENGLISH_DEPARTMENT_LOCATION = "OLeary Library, 61 Wilder Street, Lowell, MA 01854"
ENGLISH_DEPT = [_ENGLISH_DEPARTMENT_NAME, _ENGLISH_DEPARTMENT_LOCATION]

_CS_DEPARTMENT_NAME = "Miner School of Computer & Information Sciences"
_CS_DEPARTMENT_LOCATION = "Dandeneau Hall, 1 University Avenue, Lowell, MA 01854"
CS_DEPT = [_CS_DEPARTMENT_NAME, _CS_DEPARTMENT_LOCATION]

_MATH_DEPARTMENT_NAME = "Department of Mathematics and Statistics"
_MATH_DEPARTMENT_LOCATION = "Southwick Hall, 1 University Ave, Lowell, MA 01854"
MATH_DEPT = [_MATH_DEPARTMENT_NAME, _MATH_DEPARTMENT_LOCATION]

PROFESSOR = "Professor"
PART_TIME_FACULTY = "Part time faculty"

FALL = "Fall"
SPRING = "Spring"
BOTH = "Both"

MW = "MoWe"
MWF = "MoWeFr"
TT = "TuTh"


NINE_AM_50_MIN =    ["09:00:00", "09:50:00"]
TEN_AM_50_MIN =     ["10:00:00", "10:50:00"]
ELEVEN_AM_50_MIN =  ["11:00:00", "11:50:00"]
ONE_PM_50_MIN =     ["13:00:00", "13:50:00"]
TWO_PM_75_MIN =     ["14:00:00", "15:15:00"]
NOON_50_MIN =       ["12:00:00", "12:50:00"]
NINE_30_AM_75_MIN = ["09:30:00", "10:45:00"]
ELEVEN_AM_75_MIN =  ["11:00:00", "12:15:00"]
EIGHT_AM_50_MIN =   ["08:00:00", "08:50:00"]
THREE_30_75_MIN =   ["03:30:00", "04:45:00"]
FIVE_PM_75_MIN =    ["17:00:00", "18:15:00"]
NOON_30_75_MIN =    ["12:30:00", "13:45:00"]

INSTRUCTOR_DANE_CHRISTENSEN = ["Dane", "Chirstensen", PROFESSOR, "Dane_Christensen@cs.uml.edu"]
INSTRUCTOR_RYAN_OCONNELL = ["Ryan", "OConnell", PROFESSOR, "Ryan_OConnell@cs.uml.edu"]
INSTRUCTOR_YELENA_RYKALOVA = ["Yelena", "Rykalova", PROFESSOR, "Yelena_Rykalova@cs.uml.edu"]
INSTRUCTOR_DAVID_ADAMS = ["David", "Adams", PROFESSOR, "dadams@cs.uml.edu"]
INSTRUCTOR_JOHANNES_WEIS = ["Johannes", "Weis", PROFESSOR, "Johannes_Weis@cs.uml.edu"]
INSTRUCTOR_SIRONG_LIN = ["Sirong", "Lin", PROFESSOR, "Sirong_Lin@cs.uml.edu"]
INSTRUCTOR_CHARLES_WILKES = ["Charles", "Wilkes", PROFESSOR, "Charles_Wilkes@cs.uml.edu"]
INSTRUCTOR_JAMES_DALY = ["James", "Daly", PROFESSOR, "James_Daly@cs.uml.edu"]
INSTRUCTOR_MICHAEL_BARON = ["Michael", "Baron", PROFESSOR, "Michael_Baron@uml.edu"]
INSTRUCTOR_JASON_BELLIPANNI = ["Jason", "Bellipanni", PROFESSOR, "Jason_Bellipanni@uml.edu"]
INSTRUCTOR_DARRIN_BERARD = ["Darrin", "Berard", PROFESSOR, "Darrin_Berard@uml.edu"]
INSTRUCTOR_THERESA_DEFRANZO = ["Theresa", "DeFranzo", PROFESSOR, "Theresa_DeFranzo@uml.edu"]
INSTRUCTOR_THERESA_SCHILLE = ["Theresa", "Schille", PROFESSOR, "Theresa_Schille@uml.edu"]
INSTRUCTOR_SUNGHYE_YEH = ["Sunghye", "Yeh", PROFESSOR, "Sunghye_Yeh@uml.edu"]
INSTRUCTOR_JENNIFER_GONZALEZZUGASTI = ["Jennifer", "GonzalezZugasti", PROFESSOR, "Jennifer_GonzalezZugasti@uml.edu"]
INSTRUCTOR_JEANNE_DEROSA = ["Jeanne", "Derosa", PROFESSOR, "Jeanne_Derosa@uml.edu"]
INSTRUCTOR_TIMOTHY_ROGERS = ["Timothy", "Rogers", PROFESSOR, "Timothy_Rogers@uml.edu"]
INSTRUCTOR_SARA_BACKER = ["Sara", "Backer", PROFESSOR, "Sara_Backer@uml.edu"]
INSTRUCTOR_THOA_TRAN = ["Thoa", "Tran", PROFESSOR, "Thoa_Tran@uml.edu"]
INSTRUCTOR_HOWARD_TROUGHTON = ["Howard", "Troughton", PROFESSOR, "Howard_Troughton@uml.edu"]
INSTRUCTOR_CARLY_BRIGGS = ["Carly", "Briggs", PROFESSOR, "Carly_Briggs@uml.edu"]

PHD = "PHD"
MASTERS = "MASTERS"
UNDERGRAD = "UNDERGRAD"
STUDENT_REGGIE_PALMER = ["Reggie", "Palmer", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Freshman"]]
STUDENT_TOM_SCRAN = ["Tom", "Scran", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Freshman"]]
STUDENT_MARTHA_LIME = ["Martha", "Lime", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Freshman"]]
STUDENT_GRANT_FISHER = ["Grant", "Fisher", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Freshman"]]
STUDENT_BANT_JANE = ["Bant", "Jane", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Freshman"]]

STUDENT_YAN_CRAN = ["Yan", "Cran", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Freshman"]]
STUDENT_DAKE_LIN = ["Dake", "Lin", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Freshman"]]
STUDENT_HARRY_TERR = ["Harry", "Terr", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Freshman"]]
STUDENT_BORRIS_JOHNSON = ["Boris", "Johnson", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Freshman"]]
STUDENT_MARK_BILLSON = ["Mark", "Billson", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Freshman"]]

STUDENT_CART_FILLSON = ["Cart", "Fillson", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Freshman"]]
STUDENT_INDI_HUFF = ["Indi", "Huff", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Freshman"]]
STUDENT_VART_STINKY = ["Vart", "Stinky", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Freshman"]]
STUDENT_LOIS_ROBERTS = ["Lois", "Roberts", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Freshman"]]
STUDENT_JAKE_FAKE = ["Jake", "Fake", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Freshman"]]

STUDENT_SWON_LONS = ["Swon", "Lons", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Sophomore"]]
STUDENT_HIP_CAMPUS = ["Hip", "Campus", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Sophomore"]]
STUDENT_JIM_MILTON = ["Jim", "Milton", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Sophomore"]]
STUDENT_JACKIE_WILLIS = ["Jackie", "Willis", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Sophomore"]]
STUDENT_PAYTON_APPLE = ["Payton", "Apple", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Sophomore"]]

STUDENT_GARFF_EILED = ["Garff", "Eild", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Sophomore"]]
STUDENT_CLARK_TENT = ["Clark", "Tent", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Junior"]]

STUDENT_JOHN_KINS = ["John", "Kins", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Freshman"]]
STUDENT_KASSE_KINS = ["Kasse", "Kins", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Freshman"]]
STUDENT_MARTY_KINS = ["Marty", "Kins", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Freshman"]]
STUDENT_EDWARD_KINS = ["Edward", "Kins", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Freshman"]]
STUDENT_DART_KINS = ["Dart", "Kins", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Freshman"]]
STUDENT_MARY_KINS = ["Mary", "Kins", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Freshman"]]

STUDENT_JOHN_BINS = ["John", "Bins", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Freshman"]]
STUDENT_KASSE_BINS = ["Kasse", "Bins", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Freshman"]]
STUDENT_MARTY_BINS = ["Marty", "Bins", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Freshman"]]
STUDENT_EDWARD_BINS = ["Edward", "Bins", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Freshman"]]
STUDENT_DART_BINS = ["Dart", "Bins", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Freshman"]]
STUDENT_MARY_BINS = ["Mary", "Bins", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Freshman"]]

STUDENT_MASTER_STAN_UPSON = ["Stan", "Upson", _CS_DEPARTMENT_NAME, MASTERS, ["Null"]]
STUDENT_MASTER_KATE_UPSON = ["Kate", "Upson", _CS_DEPARTMENT_NAME, MASTERS, ["Null"]]

STUDENT_PHD_PHIL_YARDS = ["Phil", "Yards", _CS_DEPARTMENT_NAME, PHD, ["Null", "Null", "Null"]]

STUDENT_TEST_JOHNSON = ["Test", "Johnson", _CS_DEPARTMENT_NAME, UNDERGRAD, ["Freshman"]]

SHA_303 = [SHA, "303", 15]
FAL_209 = [FAL, "209", 15]
LYD_110 = [LYD, "110", 15]
OLS_503 = [OLS, "503", 15]
OLS_330 = [OLS, "330", 15]
OLS_408 = [OLS, "408", 15]
FAL_313 = [FAL, "313", 15]
OLS_353 = [OLS, "353", 15]
OLS_349 = [OLS, "349", 15]
OLS_106 = [OLS, "106", 15]
PER_107 = [PER, "107", 15]
OLS_349 = [OLS, "349", 15]
OLS_407 = [OLS, "407", 15]
FAL_309 = [FAL, "309", 15]
OLS_405 = [OLS, "405", 15]
OLS_109 = [OLS, "109", 15]


FALL_ALL = [FALL, 2020, 2026]
SPRING_ALL = [SPRING, 2020, 2026]
BOTH_ALL = [BOTH, 2020, 2026]

DAY_MW = [MW]
DAY_MWF = [MWF]
DAY_TT = [TT]

COMP1010 = ["COMP1010", "Computing I", 4]
COMP1020 = ["COMP1020", "Computing II", 4]
COMP2010 = ["COMP2010", "Computing III", 4]
COMP2040 = ["COMP2040", "Computing IV", 4]
ENGL1010 = ["ENGL1010", "College Writing I", 3]
MATH1310 = ["MATH1310", "Calculus I", 4]
MATH1320 = ["MATH1320", "Calculus II", 4]
ENGL1020 = ["ENGL1020", "College Writing II", 3]
# section_info[0] = [start_section_number, end_section_number]
    # section_info[1] = [instruct_firstname, instructor_lastname, instructor_title, instruct_email]
    # section_info[2] = [classroom_building, classroom_number, classroom_capacity]
    # section_info[3] = [semester, start_year, end_year]
    # section_info[4] = [ts_day]
    # section_info[5] = [[start_time_0, end_time_0], [start_time_1, end_time_1], ... [start_time_n, end_time_n] ]

def make_full():
    full = ""

    full += make_sections_all(COMP1010, CS_DEPT, [
        [[101, 103], INSTRUCTOR_DANE_CHRISTENSEN, LYD_110, FALL_ALL, DAY_MWF, [NINE_AM_50_MIN, TEN_AM_50_MIN, ELEVEN_AM_50_MIN]],
        [[104, 104], INSTRUCTOR_YELENA_RYKALOVA, SHA_303, FALL_ALL, DAY_TT, [TWO_PM_75_MIN]],
        [[105, 106], INSTRUCTOR_RYAN_OCONNELL, FAL_209, FALL_ALL, DAY_MWF, [NINE_AM_50_MIN, TEN_AM_50_MIN]],
        [[102, 103], INSTRUCTOR_RYAN_OCONNELL, FAL_209, SPRING_ALL, DAY_MWF, [TEN_AM_50_MIN, ELEVEN_AM_50_MIN]]
    ])

    full += make_sections_all(COMP1020, CS_DEPT, [
        [[101, 102], INSTRUCTOR_DAVID_ADAMS, SHA_303, FALL_ALL, DAY_MWF, [ELEVEN_AM_50_MIN, NOON_50_MIN]],
        [[101, 101], INSTRUCTOR_YELENA_RYKALOVA, SHA_303, SPRING_ALL, DAY_TT, [TWO_PM_75_MIN]],
        [[102, 103], INSTRUCTOR_JOHANNES_WEIS, OLS_503, SPRING_ALL, DAY_MWF, [NINE_AM_50_MIN, TEN_AM_50_MIN]]
    ])

    full += make_prereq(COMP1020, COMP1010)

    full += make_sections_all(COMP2010, CS_DEPT, [
        [[101, 101], INSTRUCTOR_YELENA_RYKALOVA, SHA_303, FALL_ALL, DAY_TT, [NINE_30_AM_75_MIN]],
        [[101, 101], INSTRUCTOR_SIRONG_LIN, OLS_408, SPRING_ALL, DAY_TT, [ELEVEN_AM_75_MIN]],
        [[102, 102], INSTRUCTOR_CHARLES_WILKES, OLS_330, SPRING_ALL, DAY_MWF, [TEN_AM_50_MIN]]
    ])

    full += make_prereq(COMP2010, COMP1020)

    full += make_sections_all(COMP2040, CS_DEPT, [
        [[201, 202], INSTRUCTOR_JAMES_DALY, FAL_209, FALL_ALL, DAY_MWF, [ELEVEN_AM_50_MIN, NOON_50_MIN]],
        [[201, 202], INSTRUCTOR_JAMES_DALY, FAL_209, SPRING_ALL, DAY_MWF, [ELEVEN_AM_50_MIN, NOON_50_MIN]],
        [[203, 204], INSTRUCTOR_YELENA_RYKALOVA, FAL_313, SPRING_ALL, DAY_TT, [NINE_30_AM_75_MIN, ELEVEN_AM_75_MIN]]
    ])

    full += make_prereq(COMP2040, COMP2010)

    full += make_sections_all(ENGL1010, ENGLISH_DEPT, [
        [[202, 203], INSTRUCTOR_MICHAEL_BARON, OLS_353, FALL_ALL, DAY_MWF, [TEN_AM_50_MIN, ELEVEN_AM_50_MIN]],
        [[204, 205], INSTRUCTOR_JASON_BELLIPANNI, OLS_349, FALL_ALL, DAY_MWF, [EIGHT_AM_50_MIN, NINE_AM_50_MIN]],
        [[206, 207], INSTRUCTOR_DARRIN_BERARD, OLS_106, FALL_ALL, DAY_MW, [THREE_30_75_MIN, FIVE_PM_75_MIN]],
        [[203, 203], INSTRUCTOR_MICHAEL_BARON, PER_107, SPRING_ALL, DAY_MWF, [TEN_AM_50_MIN]],
        [[205, 205], INSTRUCTOR_THERESA_DEFRANZO, OLS_349, SPRING_ALL, DAY_TT, [NINE_30_AM_75_MIN]],
        [[207, 207], INSTRUCTOR_MICHAEL_BARON, PER_107, SPRING_ALL, DAY_MWF, [ELEVEN_AM_50_MIN]]
    ])

    full += make_sections_all(MATH1310, MATH_DEPT, [
        [[201, 201], INSTRUCTOR_THERESA_SCHILLE, OLS_407, FALL_ALL, DAY_MWF, [NINE_30_AM_75_MIN]],
        [[202, 202], INSTRUCTOR_SUNGHYE_YEH, OLS_407, FALL_ALL, DAY_MWF, [ELEVEN_AM_75_MIN]],
        [[203, 203], INSTRUCTOR_JENNIFER_GONZALEZZUGASTI, FAL_313, FALL_ALL, DAY_MWF, [NOON_30_75_MIN]],
        [[204, 204], INSTRUCTOR_JEANNE_DEROSA, FAL_313, FALL_ALL, DAY_MWF, [FIVE_PM_75_MIN]],
        [[201, 202], INSTRUCTOR_SUNGHYE_YEH, FAL_313, SPRING_ALL, DAY_MWF, [NINE_30_AM_75_MIN, ELEVEN_AM_75_MIN]],
        [[204, 204], INSTRUCTOR_SUNGHYE_YEH, FAL_313, SPRING_ALL, DAY_MWF, [NOON_30_75_MIN]]
    ])

    full += make_sections_all(ENGL1020, ENGLISH_DEPT, [
        [[201, 201], INSTRUCTOR_THERESA_DEFRANZO, OLS_349, FALL_ALL, DAY_MWF, [NOON_50_MIN]],
        [[204, 204], INSTRUCTOR_JASON_BELLIPANNI, PER_107, FALL_ALL, DAY_MWF, [ELEVEN_AM_50_MIN]],
        [[208, 208], INSTRUCTOR_TIMOTHY_ROGERS, OLS_353, FALL_ALL, DAY_TT, [ELEVEN_AM_75_MIN]],
        [[201, 202], INSTRUCTOR_SARA_BACKER, PER_107, SPRING_ALL, DAY_TT, [NINE_30_AM_75_MIN, ELEVEN_AM_75_MIN]]
    ])

    full += make_prereq(ENGL1020, ENGL1010)

    full += make_sections_all(MATH1320, MATH_DEPT, [
        [[201, 201], INSTRUCTOR_HOWARD_TROUGHTON, OLS_405, FALL_ALL, DAY_MWF, [NINE_30_AM_75_MIN]],
        [[202, 202], INSTRUCTOR_CARLY_BRIGGS, FAL_309, FALL_ALL, DAY_MWF, [NOON_30_75_MIN]],
        [[203, 204], INSTRUCTOR_THOA_TRAN, FAL_313, FALL_ALL, DAY_MWF, [TWO_PM_75_MIN, ELEVEN_AM_75_MIN]],
        [[202, 202], INSTRUCTOR_HOWARD_TROUGHTON, OLS_109, SPRING_ALL, DAY_MWF, [NINE_30_AM_75_MIN]],
        [[204, 204], INSTRUCTOR_HOWARD_TROUGHTON, OLS_109, SPRING_ALL, DAY_MWF, [ELEVEN_AM_75_MIN]]
    ])
    full += make_prereq(MATH1320, MATH1310)
    
    GRADE_A = "\'A\'"
    GRADE_B = "\'B\'"
    GRADE_C = "\'C\'"
    GRADE_D = "\'D\'"
    GRADE_F = "\'F\'"

    full += make_admin("", "ADMIN")

    full += add_student_to(STUDENT_REGGIE_PALMER, COMP1010, "102", FALL, 2024, GRADE_A)
    full += add_student_to(STUDENT_TOM_SCRAN, COMP1010, "102", FALL, 2024, GRADE_A)
    full += add_student_to(STUDENT_MARTHA_LIME, COMP1010, "102", FALL, 2024, GRADE_A)
    full += add_student_to(STUDENT_GRANT_FISHER, COMP1010, "102", FALL, 2024, GRADE_A)
    full += add_student_to(STUDENT_BANT_JANE, COMP1010, "102", FALL, 2024, GRADE_A)

    full += add_student_to(STUDENT_YAN_CRAN, COMP1010, "102", FALL, 2024, GRADE_B)
    full += add_student_to(STUDENT_DAKE_LIN, COMP1010, "102", FALL, 2024, GRADE_B)
    full += add_student_to(STUDENT_HARRY_TERR, COMP1010, "102", FALL, 2024, GRADE_B)
    full += add_student_to(STUDENT_BORRIS_JOHNSON, COMP1010, "102", FALL, 2024, GRADE_B)
    full += add_student_to(STUDENT_MARK_BILLSON, COMP1010, "102", FALL, 2024, GRADE_B)
    
    full += add_student_to(STUDENT_CART_FILLSON, COMP1010, "102", FALL, 2024, GRADE_C)
    full += add_student_to(STUDENT_INDI_HUFF, COMP1010, "102", FALL, 2024, GRADE_C)
    full += add_student_to(STUDENT_VART_STINKY, COMP1010, "102", FALL, 2024, GRADE_C)
    full += add_student_to(STUDENT_LOIS_ROBERTS, COMP1010, "102", FALL, 2024, GRADE_D)
    full += add_student_to(STUDENT_JAKE_FAKE, COMP1010, "102", FALL, 2024, GRADE_D)




    full += add_student_to(STUDENT_REGGIE_PALMER, COMP1020, "102", SPRING, 2024, "Null")
    full += add_student_to(STUDENT_TOM_SCRAN, COMP1020, "102", SPRING, 2024, "Null")
    full += add_student_to(STUDENT_MARTHA_LIME, COMP1020, "102", SPRING, 2024, "Null")
    full += add_student_to(STUDENT_GRANT_FISHER, COMP1020, "102", SPRING, 2024, "Null")
    full += add_student_to(STUDENT_BANT_JANE, COMP1020, "102", SPRING, 2024, "Null")

    full += add_student_to(STUDENT_YAN_CRAN, COMP1020, "102", SPRING, 2024, "Null")
    full += add_student_to(STUDENT_DAKE_LIN, COMP1020, "102", SPRING, 2024, "Null")
    full += add_student_to(STUDENT_HARRY_TERR, COMP1020, "102", SPRING, 2024, "Null")
    full += add_student_to(STUDENT_BORRIS_JOHNSON, COMP1020, "102", SPRING, 2024, "Null")
    full += add_student_to(STUDENT_MARK_BILLSON, COMP1020, "102", SPRING, 2024, "Null")
    
    full += add_student_to(STUDENT_CART_FILLSON, COMP1020, "102", SPRING, 2024, "Null")
    full += add_student_to(STUDENT_INDI_HUFF, COMP1020, "102", SPRING, 2024, "Null")
    full += add_student_to(STUDENT_VART_STINKY, COMP1020, "102", SPRING, 2024, "Null")
    full += add_student_to(STUDENT_LOIS_ROBERTS, COMP1020, "102", SPRING, 2024, "Null")
    full += add_student_to(STUDENT_JAKE_FAKE, COMP1020, "102", SPRING, 2024, "Null")

    full += add_student_to(STUDENT_SWON_LONS, COMP1010, "102", FALL, 2022, GRADE_C)
    full += add_student_to(STUDENT_SWON_LONS, COMP1020, "102", SPRING, 2023, GRADE_B)
    full += add_student_to(STUDENT_SWON_LONS, COMP2010, "101", SPRING, 2024, "Null")

    full += add_student_to(STUDENT_HIP_CAMPUS, COMP1010, "102", FALL, 2022, GRADE_A)
    full += add_student_to(STUDENT_HIP_CAMPUS, COMP1020, "102", SPRING, 2023, GRADE_C)
    full += add_student_to(STUDENT_HIP_CAMPUS, COMP2010, "101", SPRING, 2024, "Null")

    full += add_student_to(STUDENT_JIM_MILTON, COMP1010, "102", FALL, 2022, GRADE_A)
    full += add_student_to(STUDENT_JIM_MILTON, COMP1020, "102", SPRING, 2023, GRADE_B)
    full += add_student_to(STUDENT_JIM_MILTON, COMP2010, "101", SPRING, 2024, "Null")

    full += add_student_to(STUDENT_JACKIE_WILLIS, COMP1010, "102", FALL, 2022, GRADE_A)
    full += add_student_to(STUDENT_JACKIE_WILLIS, COMP1020, "102", SPRING, 2023, GRADE_A)
    full += add_student_to(STUDENT_JACKIE_WILLIS, COMP2010, "101", SPRING, 2024, "Null")

    full += add_student_to(STUDENT_PAYTON_APPLE, COMP1010, "102", FALL, 2022, GRADE_B)
    full += add_student_to(STUDENT_PAYTON_APPLE, COMP1020, "102", SPRING, 2023, GRADE_A)
    full += add_student_to(STUDENT_PAYTON_APPLE, COMP2010, "101", SPRING, 2024, "Null")

    full += add_student_to(STUDENT_GARFF_EILED, COMP1010, "102", FALL, 2022, GRADE_B)
    full += add_student_to(STUDENT_GARFF_EILED, COMP1020, "102", SPRING, 2023, GRADE_A)
    full += add_student_to(STUDENT_GARFF_EILED, COMP2010, "101", SPRING, 2024, "Null")


    full += add_student_to(STUDENT_CLARK_TENT, COMP1010, "102", FALL, 2022, GRADE_C)
    full += add_student_to(STUDENT_CLARK_TENT, COMP1020, "102", SPRING, 2023, GRADE_A)
    full += add_student_to(STUDENT_CLARK_TENT, COMP2010, "101", FALL, 2023, GRADE_D)
    full += add_student_to(STUDENT_CLARK_TENT, COMP2040, "202", SPRING, 2024, "Null")


    full += add_student_to(STUDENT_JOHN_KINS, COMP1010, "102", SPRING, 2024, "Null")
    full += add_student_to(STUDENT_KASSE_KINS, COMP1010, "102", SPRING, 2024, "Null")
    full += add_student_to(STUDENT_MARTY_KINS, COMP1010, "102", SPRING, 2024, "Null")
    full += add_student_to(STUDENT_EDWARD_KINS, COMP1010, "102", SPRING, 2024, "Null")
    full += add_student_to(STUDENT_DART_KINS, COMP1010, "102", SPRING, 2024, "Null")
    full += add_student_to(STUDENT_MARY_KINS, COMP1010, "102", SPRING, 2024, "Null")

    full += add_student_to(STUDENT_MASTER_STAN_UPSON, COMP1010, "102", FALL, 2022, GRADE_C)
    full += add_student_to(STUDENT_MASTER_STAN_UPSON, COMP1020, "102", SPRING, 2023, GRADE_A)
    full += add_student_to(STUDENT_MASTER_STAN_UPSON, COMP2010, "101", FALL, 2023, GRADE_D)
    full += add_student_to(STUDENT_MASTER_STAN_UPSON, COMP2040, "202", SPRING, 2024, GRADE_A)

    full += add_student_to(STUDENT_MASTER_KATE_UPSON, COMP1010, "102", FALL, 2022, GRADE_A)
    full += add_student_to(STUDENT_MASTER_KATE_UPSON, COMP1020, "102", SPRING, 2023, GRADE_A)
    full += add_student_to(STUDENT_MASTER_KATE_UPSON, COMP2010, "101", FALL, 2023, GRADE_A)
    full += add_student_to(STUDENT_MASTER_KATE_UPSON, COMP2040, "202", SPRING, 2024, GRADE_A)

    full += add_student_to(STUDENT_PHD_PHIL_YARDS, COMP1010, "102", FALL, 2022, GRADE_A)
    full += add_student_to(STUDENT_PHD_PHIL_YARDS, COMP1020, "102", SPRING, 2023, GRADE_A)
    full += add_student_to(STUDENT_PHD_PHIL_YARDS, COMP2010, "101", FALL, 2023, GRADE_D)
    full += add_student_to(STUDENT_PHD_PHIL_YARDS, COMP2040, "202", SPRING, 2024, GRADE_A)

    full += add_student_to(STUDENT_JOHN_BINS, COMP1010, "103", SPRING, 2024, "Null")
    full += add_student_to(STUDENT_KASSE_BINS, COMP1010, "103", SPRING, 2024, "Null")
    full += add_student_to(STUDENT_MARTY_BINS, COMP1010, "103", SPRING, 2024, "Null")
    full += add_student_to(STUDENT_EDWARD_BINS, COMP1010, "103", SPRING, 2024, "Null")
    full += add_student_to(STUDENT_DART_BINS, COMP1010, "103", SPRING, 2024, "Null")
    full += add_student_to(STUDENT_MARY_BINS, COMP1010, "103", SPRING, 2024, "Null")


 
    full += "INSERT INTO account (email, password, type) VALUES ('admin@uml.edu', '123456', 'admin');\n"

    full += "\n\n\n"
    full += add_student_to(STUDENT_TEST_JOHNSON, COMP1010, "101", FALL, 2024, GRADE_A)
    print(full)

make_full()

def make_inst_info(first_name, last_name, title):
    r = "INSTRUCTOR_" + first_name.upper() + "_" + last_name.upper()
    r += " = [\"" + first_name + "\", "
    r += "\"" + last_name + "\", "
    r += title + ", "
    r += "\"" + first_name + "_" + last_name + "@uml.edu\"]"
    return (r + "\n")
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
