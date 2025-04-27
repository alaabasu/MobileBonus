import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'LoginPage.dart'; // <-- Import LoginPage



class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _selectedGender;
  String? _selectedLevel;

  String? _nameError;
  String? _emailError;
  String? _studentIdError;
  String? _passwordError;
  String? _confirmPasswordError;

  bool _isFCIEmail(String email) {
    RegExp regex = RegExp(r'^\d{8}@stud\.fci-cu\.edu\.eg$');
    return regex.hasMatch(email);
  }

  bool _isValidPassword(String password) => password.length >= 8;

  bool _passwordsMatch(String password, String confirmPassword) =>
      password == confirmPassword;

  Future<void> _signUp() async {
    setState(() {
      _nameError = _nameController.text.isEmpty ? 'Name is required' : null;
      _emailError = _emailController.text.isEmpty ? 'Email is required' : null;
      _studentIdError = _studentIdController.text.isEmpty ? 'Student ID is required' : null;
      _passwordError = _passwordController.text.isEmpty ? 'Password is required' : null;
      _confirmPasswordError =
      _confirmPasswordController.text.isEmpty ? 'Confirm Password is required' : null;

      if (_emailController.text.isNotEmpty && !_isFCIEmail(_emailController.text)) {
        _emailError = 'Please enter a valid FCI email.';
      }

      if (_studentIdController.text.isNotEmpty &&
          !_emailController.text.startsWith(_studentIdController.text)) {
        _emailError = 'Email must start with your Student ID.';
      }

      if (_passwordController.text.isNotEmpty &&
          !_isValidPassword(_passwordController.text)) {
        _passwordError = 'Password must be at least 8 characters.';
      }

      if (_confirmPasswordController.text.isNotEmpty &&
          !_passwordsMatch(_passwordController.text, _confirmPasswordController.text)) {
        _confirmPasswordError = 'Passwords do not match.';
      }
    });

    if (_nameError != null ||
        _emailError != null ||
        _studentIdError != null ||
        _passwordError != null ||
        _confirmPasswordError != null ||
        _selectedGender == null ||
        _selectedLevel == null) {
      return;
    }

    Map<String, dynamic> userData = {
      'name': _nameController.text,
      'email': _emailController.text,
      'studentId': _studentIdController.text,
      'gender': _selectedGender,
      'level': _selectedLevel,
      'password': _passwordController.text,
      'confirmPassword': _confirmPasswordController.text,
    };

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign up successful'),
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(Duration(seconds: 2));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to sign up. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name', errorText: _nameError),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Gender: ', style: TextStyle(fontSize: 16)),
                Radio<String>(
                  value: 'Female',
                  groupValue: _selectedGender,
                  onChanged: (value) => setState(() => _selectedGender = value),
                ),
                const Text('Female'),
                const SizedBox(width: 20),
                Radio<String>(
                  value: 'Male',
                  groupValue: _selectedGender,
                  onChanged: (value) => setState(() => _selectedGender = value),
                ),
                const Text('Male'),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email', errorText: _emailError),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _studentIdController,
              decoration: InputDecoration(labelText: 'Student ID', errorText: _studentIdError),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedLevel,
              hint: const Text('Select Level'),
              items: ['1', '2', '3', '4']
                  .map((level) => DropdownMenuItem(value: level, child: Text(level)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedLevel = value),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password', errorText: _passwordError),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _confirmPasswordController,
              decoration:
              InputDecoration(labelText: 'Confirm Password', errorText: _confirmPasswordError),
              obscureText: true,
            ),
            ElevatedButton(onPressed: _signUp, child: const Text('Sign Up')),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: const Text("Already have an account? Login"),
            ),


          ],
        ),
      ),
    );
  }
}
