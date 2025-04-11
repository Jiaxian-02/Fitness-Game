import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  String _statusMessage = '';
  bool _isLogin = true; // Track whether it's login or register page

  // Change between login and registration
  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
      _statusMessage = '';
    });
  }

  // Authentication for login and registration
  Future<void> _authenticate() async {
    try {
      if (_isLogin) {
        // Login logic
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // Navigate to the home page if successful login
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Registration logic
        final username = _usernameController.text.trim();
        if (username.isEmpty) {
          setState(() {
            _statusMessage = 'Username is required.';
          });
          return;
        }

        // Check if username already exists
        final usernameSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: username)
            .get();

        if (usernameSnapshot.docs.isNotEmpty) {
          setState(() {
            _statusMessage = 'Username already exists. Choose a different one.';
          });
          return;
        }

        // Proceed with registration
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Add user to firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user?.uid)
            .set({
          'email': _emailController.text.trim(),
          'username': username,
          'createdAt': FieldValue.serverTimestamp(),
          'coins': 0,
          'steps': 0,
          'isMiniGame1Unlocked': false,
          'isMiniGame2Unlocked': false,
        });

        setState(() {
          _statusMessage = 'Registration Successful! Please Login.';
          _isLogin = true;
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _statusMessage = e.message ?? 'An error occurred.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'An unexpected error occurred: $e';
      });
    }
  }

  // Interface
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset('assets/images/logo.png', height: 100),
              SizedBox(height: 30),

              // Welcome Text
              Text(
                _isLogin ? 'Welcome back!' : 'Create an Account!',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),

              if (!_isLogin)
                Column(
                  children: [
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 15),
                  ],
                ),

              // Email Field
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 15),

              // Password Field
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 10),

              // Action Button
              ElevatedButton(
                onPressed: _authenticate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  _isLogin ? 'Sign In' : 'Register',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),

              // Status Message
              if (_statusMessage.isNotEmpty)
                Text(
                  _statusMessage,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              SizedBox(height: 10),

              // Toggle between login or register
              TextButton(
                onPressed: _toggleAuthMode,
                child: Text(
                  _isLogin
                      ? "Don't have an account? Sign up"
                      : 'Already have an account? Sign in',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
