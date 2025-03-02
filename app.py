from flask import Flask, render_template, redirect, url_for, request
import json
import os
import re
from getpass import getpass
from Crypto.Hash import SHA3_512
from Crypto.Random import get_random_bytes
from base64 import b64encode, b64decode

USER_FILE = "users.json"
app = Flask(__name__)

def validate_password(password):
    """
    Validate password strength
    Returns (is_valid, error_message)
    """
    error_messages = []
    
    if len(password) < 8:
        error_messages.append("Password must be at least 8 characters long")
    
    if not re.search(r'[A-Z]', password):
        error_messages.append("Password must contain at least one uppercase letter")
    
    if not re.search(r'[a-z]', password):
        error_messages.append("Password must contain at least one lowercase letter")
    
    if not re.search(r'[0-9]', password):
        error_messages.append("Password must contain at least one number")
    
    if not re.search(r'[!@#$%^&*(),.?":{}|<>]', password):
        error_messages.append("Password must contain at least one special character")
    
    if error_messages:
        return False, error_messages
    return True, []

def hash_password(password: str, salt: bytes = None) -> tuple[str, str]:
    if salt is None:
        salt = get_random_bytes(16)
    sha512_obj = SHA3_512.new()
    sha512_obj.update(password.encode() + salt)
    password_hash = sha512_obj.digest()
    encoded_hash = b64encode(password_hash).decode('utf-8')
    encoded_salt = b64encode(salt).decode('utf-8')
    return encoded_hash, encoded_salt

def verify_password(password: str, stored_hash: str, stored_salt: str) -> bool:
    salt = b64decode(stored_salt.encode('utf-8'))
    calculated_hash, _ = hash_password(password, salt)
    return calculated_hash == stored_hash

def load_users():
    try:
        if os.path.exists(USER_FILE):
            with open(USER_FILE, 'r') as file:
                return json.load(file)
    except json.JSONDecodeError:
        print("Corrupted user file detected. Creating new user file.")
    return {}

def save_users(users):
    with open(USER_FILE, 'w') as file:
        json.dump(users, file)

@app.route('/')
def home():
    return render_template('home.html')

@app.route('/login', methods=['POST'])
def login():
    user_id = request.form['user_id']
    user_password = request.form['user_password']
    users = load_users()
    
    if user_id not in users:
        print("Invalid email or password.")
        return "Invalid email or password."
    
    user = users[user_id]
    if verify_password(user_password, user["password_hash"], user["salt"]):
        print("Username and Password verified. Welcome.")
        return redirect(url_for('dashboard'))
    else:
        print("Invalid email or password.")
        return "Invalid email or password."

@app.route('/create_account_page')
def create_account_page():
    return render_template('create_account.html')

@app.route('/createaccount', methods=['POST'])
def create_account():
    user_id = request.form['user_id']
    user_password = request.form['user_password']
    
    # Validate password strength
    is_valid, error_messages = validate_password(user_password)
    if not is_valid:
        return render_template('create_account.html', error_messages=error_messages, user_id=user_id)
    
    users = load_users()
    if user_id in users:
        return render_template('create_account.html', error_messages=["User ID already registered."], user_id=user_id)
    
    password_hash, salt = hash_password(user_password)
    users[user_id] = {
        "password_hash": password_hash,
        "salt": salt
    }
    save_users(users)
    
    return redirect(url_for('home'))

@app.route('/dashboard')
def dashboard():
    return "Welcome to your dashboard!"

@app.route('/account_created')
def account_created():
    return redirect(url_for('home'))

if __name__ == '__main__':
    app.run(debug=True)