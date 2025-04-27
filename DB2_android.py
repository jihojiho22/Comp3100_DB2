from random import randint
ACCOUNTS = []
STUDENTS = {}
def add_account(email, pswd, _type):
    if email in ACCOUNTS:
        return ""
    r = "INSERT INTO account(email, password, type) VALUES (" 
    r += "'" + email + "', "
    r += "'" + pswd + "', "
    r += "'" + _type + "');\n"
    ACCOUNTS.append(email)
    return r
    
def add_student(fname, lname, dept_name):
    email = fname + "_" + lname + "@student.uml.edu"
    if email in STUDENTS:
        return ""
    r = add_account(email, (lname + "12345!"), "student")
    r += "INSERT INTO student(student_id, name, email, dept_name) VALUES("
    _id = (randint(1000000000, 9999999999))
    while (_id in STUDENTS.values()):
        _id = (randint(1000000000, 9999999999))
    r += "'" + str(_id) + "', "
    r += "'" + fname + " " + lname + "', "
    r += "'" + email + "', "
    r += "'" + dept_name + "');\n"
    STUDENTS[email] = str(_id)
    return r
    
#student_info = [email, fname, lname, dept_name]
def add_takes(student_info, course_id, section_id, semester, year, grade):
    r = ""
    email = student_info[0]
    if email not in STUDENTS:
        r += add_student(student_info[1], student_info[2], student_info[3])
        email = student_info[1] + "_" + student_info[2] + "@student.uml.edu"
    r += "INSERT INTO take(student_id, course_id, section_id, semester, year, grade) VALUES ("
    r += "'" + STUDENTS[email] + "', "
    r += "'" + course_id + "', "
    r += "'" + section_id + "', "
    r += "'" + semester + "', "
    r += "" + year + ", "
    r += grade + ");\n"
    r += "UPDATE section SET capacity=capacity-1 WHERE (course_id = "
    r += "'" + course_id + "')"
    r += "AND (section_id = '" + section_id + "');\n"
    return r

def add_takes_all(student_info_list, course_id, section_id, semester, year, grade):
    r = ""
    for student_info in student_info_list:
        r += add_takes(student_info, course_id, section_id, semester, year, grade)
    return r
    
DEPT_CS = "Computer Science"

ABE_LINCOLN = ["", "Abe", "Lincoln", DEPT_CS]
JOHN_WAYNE = ["", "John", "Wayne", DEPT_CS]
MARK_YARD = ["", "Mark", "Yard", DEPT_CS]
REGGIE_PALMER = ["", "Reggie", "Palmer", DEPT_CS]
TOM_SCRAN = ["", "Tom", "Scran", DEPT_CS]

GRANT_FISHER = ["", "Grant", "Fisher", DEPT_CS]
MARTHA_LIME = ["", "Martha", "Lime", DEPT_CS]
BANT_JANE = ["", "Bant", "Jane", DEPT_CS]
YAN_CRAN = ["", "Yan", "Cran", DEPT_CS]
DAKE_LIN = ["", "Dake", "Lin", DEPT_CS]

HARRY_TERR = ["", "Harry", "Terr", DEPT_CS]
BORRIS_JOHNSON = ["", "Boris", "Johnson", DEPT_CS]
MARK_BILLSON = ["", "Mark", "Billson", DEPT_CS]
CART_FILLSON = ["", "Cart", "Fillson", DEPT_CS]
INDI_HUFF = ["", "Indi", "Huff", DEPT_CS]

COURSE = "CS101"
SECTION = "A01"
SEM = "Fall"
YEAR = "2025"

GRADE_A = "'A'"
GRADE_NULL = "Null"

input_students = [
    ABE_LINCOLN,
    JOHN_WAYNE,
    MARK_YARD,
    REGGIE_PALMER,
    TOM_SCRAN,
    
    GRANT_FISHER,
    MARTHA_LIME,
    BANT_JANE,
    YAN_CRAN,
    DAKE_LIN,
    
    HARRY_TERR,
    BORRIS_JOHNSON,
    MARK_BILLSON,
    CART_FILLSON,
    INDI_HUFF   
]

print(add_takes_all(input_students, COURSE, SECTION, SEM, YEAR, GRADE_NULL))  
