import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'SignUpPage.dart'; // <-- Import SignUpPage
import 'Profile.dart';
import 'AllStoresPage.dart'; // <-- Import the AllStoresPage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(), // Set LoginPage as the initial screen
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;

  bool _isFCIEmail(String email) {
    RegExp regex = RegExp(r'^\d{8}@stud\.fci-cu\.edu\.eg$');
    return regex.hasMatch(email);
  }

  Future<void> _login() async {
    setState(() {
      _emailError = _emailController.text.isEmpty ? 'Email is required' : null;
      _passwordError = _passwordController.text.isEmpty ? 'Password is required' : null;

      if (_emailController.text.isNotEmpty && !_isFCIEmail(_emailController.text)) {
        _emailError = 'Please enter a valid FCI email.';
      }
    });

    if (_emailError != null || _passwordError != null) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/login'), // Ensure this endpoint is correct
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      print('Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        // Ensure responseBody contains a 'userId' field and convert it to int
        final String userIdStr = responseBody['userId'] ?? '';
        final int userId = int.tryParse(userIdStr) ?? 0; // Convert to int or set to 0 if parsing fails

        if (userId != 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login successful'), backgroundColor: Colors.green),
          );

          // Navigate to AllStoresPage and pass the userId
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AllStoresPage(userId: userId)), // Pass as int
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User ID not found'), backgroundColor: Colors.red),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid credentials'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email', errorText: _emailError),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password', errorText: _passwordError),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(onPressed: _login, child: const Text('Login')),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpPage()),
                );
              },
              child: const Text("Don't have an account? Sign Up"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
              child: const Text("Wanna Edit Your Profile? Edit"),
            ),
          ],
        ),
      ),
    );
  }
}
