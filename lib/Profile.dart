import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'AllStoresPage.dart'; // ✅ Make sure you import the page here!

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  String? _selectedGender;
  String? _selectedLevel;
  File? _profileImage;
  final picker = ImagePicker();

  String? _idError;
  String? _nameError;
  String? _emailError;
  String? _studentIdError;

  bool _isLoading = false;
  bool _showProfileForm = false;
  User? _user;

  bool _isFCIEmail(String email) {
    RegExp regex = RegExp(r'^\d{8}@stud\.fci-cu\.edu\.eg$');
    return regex.hasMatch(email);
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _profileImage = File(pickedFile.path);
      }
    });
  }

  Future<void> _fetchUserById() async {
    setState(() {
      _idError = _idController.text.isEmpty ? 'Student ID is required' : null;
      _isLoading = true;
    });

    if (_idError != null) return;

    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8080/user/${_idController.text}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _user = User.fromJson(data);
          _nameController.text = _user!.name;
          _emailController.text = _user!.email;
          _studentIdController.text = _user!.studentId;
          _selectedGender = _user!.gender;
          _selectedLevel = _user!.level.toString();
          _showProfileForm = true;
        });
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found'), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}'), backgroundColor: Colors.red),
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

  Future<void> _updateProfile() async {
    setState(() {
      _nameError = _nameController.text.isEmpty ? 'Name is required' : null;
      _emailError = _emailController.text.isEmpty ? 'Email is required' : null;
      _studentIdError = _studentIdController.text.isEmpty ? 'Student ID is required' : null;

      if (_emailController.text.isNotEmpty && !_isFCIEmail(_emailController.text)) {
        _emailError = 'Please enter a valid FCI email.';
      }
    });

    if (_nameError != null || _emailError != null || _studentIdError != null || _selectedGender == null || _selectedLevel == null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> userData = {
        'id': _user?.id,
        'name': _nameController.text,
        'email': _emailController.text,
        'studentId': _studentIdController.text,
        'gender': _selectedGender,
        'level': int.parse(_selectedLevel!),
      };

      if (_profileImage != null) {
        List<int> imageBytes = await _profileImage!.readAsBytes();
        String base64Image = base64Encode(imageBytes);
        userData['profilePhoto'] = base64Image;
      }

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AllStoresPage(userId: _user!.id)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile. ${response.body}'), backgroundColor: Colors.red),
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
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : !_showProfileForm
            ? Column(
          children: [
            TextFormField(
              controller: _idController,
              decoration: InputDecoration(labelText: 'Enter Your Student ID', errorText: _idError),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchUserById,
              child: const Text('Fetch Profile Data'),
            ),
          ],
        )
            : ListView(
          children: [
            GestureDetector(
              onTap: getImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : (_user?.profilePhoto != null
                    ? MemoryImage(base64Decode(_user!.profilePhoto!)) as ImageProvider
                    : const AssetImage('assets/default_profile_image.png')) as ImageProvider,
                child: _profileImage == null && _user?.profilePhoto == null
                    ? const Icon(Icons.camera_alt, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
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
              items: ['1', '2', '3', '4'].map((level) {
                return DropdownMenuItem<String>(value: level, child: Text(level));
              }).toList(),
              onChanged: (value) => setState(() => _selectedLevel = value),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: const Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class User {
  int id;
  String name;
  String gender;
  String email;
  String studentId;
  int level;
  String? profilePhoto;

  User({
    required this.id,
    required this.name,
    required this.gender,
    required this.email,
    required this.studentId,
    required this.level,
    this.profilePhoto,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      gender: json['gender'],
      email: json['email'],
      studentId: json['studentId'],
      level: json['level'],
      profilePhoto: json['profilePhoto'],
    );
  }
}
