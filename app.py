from flask import Flask, render_template, redirect, url_for, request

app = Flask(__name__)

@app.route('/')
def home():
    return render_template('home.html')

@app.route('/login', methods=['POST'])
def login():
    user_id = request.form['user_id']
    user_password = request.form['user_password']
    
    # Here, you would typically validate the user's credentials.
    # If valid, redirect to a dashboard or user page:
    return redirect(url_for('dashboard'))

@app.route('/createaccount', methods=['POST'])
def create_account():
    # Here, you would handle the account creation logic
    return render_template('createAccount.html')

@app.route('/dashboard')
def dashboard():
    return "Welcome to your dashboard!"

@app.route('/account_created')
def account_created():
    return redirect(url_for('home'))

if __name__ == '__main__':
    app.run(debug=True)


