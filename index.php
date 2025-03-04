<?php
session_start();

// If user is already logged in, redirect to dashboard
if (isset($_SESSION['user_id'])) {
    header('Location: dashboard.php');
    exit;
}
?>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login</title>
</head>
<body>
    <h2>Login</h2>
    <?php if (isset($_SESSION['login_error'])): ?>
        <div style="color: red;">
            <?php echo $_SESSION['login_error']; ?>
            <?php unset($_SESSION['login_error']); ?>
        </div>
    <?php endif; ?>
    
    <?php if (isset($_SESSION['success_message'])): ?>
        <div style="color: green;">
            <?php echo $_SESSION['success_message']; ?>
            <?php unset($_SESSION['success_message']); ?>
        </div>
    <?php endif; ?>
    
    <form action="login.php" method="POST">
        <label for="email">Email: </label>
        <input type="email" id="email" name="email" required>
        <br><br><br>
        <label for="password">Password: </label>
        <input type="password" id="password" name="password" required>
        <br><br><br>
        <button type="submit">Login</button>
    </form>
    <br><br>
    <a href="create_account.php"><button type="button">Create Account</button></a>
</body>
</html>
