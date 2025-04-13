import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mysql_client/mysql_client.dart';
import 'home_screen.dart';

class StudentDetailsScreen extends StatefulWidget {

  const StudentDetailsScreen({
    super.key,
  });

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  MySQLConnection? _conn;
  bool _isConnecting = false;
  String? _connectionError;

  // Controllers for student fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _graduationYearController = TextEditingController();
  final _degreeController = TextEditingController();
  final _majorController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _twitterController = TextEditingController();
  final _githubController = TextEditingController();
  final _skillsController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupDatabaseConnection();
    });
  }

  Future<void> _setupDatabaseConnection() async {
    if (_isConnecting) return;

    setState(() {
      _isConnecting = true;
      _connectionError = null;
    });

    try {
      final conn = await MySQLConnection.createConnection(
        host: "192.168.110.49",
        port: 3306,
        userName: "root",
        password: "mysql@264",
        databaseName: "alunet_db",
        secure: false,
      );

      await conn.connect();
      _conn = conn;

      if (mounted) {
        setState(() {
          _connectionError = null;
        });
      }
      print("Database connected successfully");
    } catch (e) {
      print("Database connection error: $e");
      if (mounted) {
        setState(() {
          _connectionError = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Database connection failed: $e'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _saveToDatabase() async {
    if (_conn == null || _connectionError != null) {
      await _setupDatabaseConnection();
      if (_conn == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Cannot connect to database. Please check your MySQL server settings.'),
            duration: Duration(seconds: 5),
          ),
        );
        return;
      }
    }

    try {
      final result = await _conn!.execute(
        "INSERT INTO students (full_name, email, phone_number, address, city, country, graduation_year, "
        "degree, major, linkedin_url, twitter_url, github_url, skills, bio) "
        "VALUES (:name, :email, :phone, :address, :city, :country, :grad_year, "
        ":degree, :major, :linkedin, :twitter, :github, :skills, :bio)",
        {
          "name": _nameController.text,
          "email": _emailController.text,
          "phone": _phoneController.text,
          "address": _addressController.text,
          "city": _cityController.text,
          "country": _countryController.text,
          "grad_year": int.parse(_graduationYearController.text),
          "degree": _degreeController.text,
          "major": _majorController.text,
          "linkedin": _linkedinController.text,
          "twitter": _twitterController.text,
          "github": _githubController.text,
          "skills": _skillsController.text,
          "bio": _bioController.text,
        },
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _graduationYearController.dispose();
    _degreeController.dispose();
    _majorController.dispose();
    _linkedinController.dispose();
    _twitterController.dispose();
    _githubController.dispose();
    _skillsController.dispose();
    _bioController.dispose();

    _conn?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Student Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor:
                          Theme.of(context).primaryColor.withOpacity(0.1),
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? const Icon(Icons.person,
                              size: 60, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        radius: 18,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt,
                              size: 18, color: Colors.white),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildTextField(_nameController, 'Full Name', Icons.person),
              _buildTextField(_emailController, 'Email', Icons.email),
              _buildTextField(_phoneController, 'Phone Number', Icons.phone),
              _buildTextField(_addressController, 'Address', Icons.location_on),
              _buildTextField(_cityController, 'City', Icons.location_city),
              _buildTextField(_countryController, 'Country', Icons.flag),
              _buildTextField(
                  _graduationYearController, 'Graduation Year', Icons.school),
              _buildTextField(_degreeController, 'Degree', Icons.school),
              _buildTextField(
                  _majorController, 'Major/Specialization', Icons.book),
              _buildTextField(
                  _linkedinController, 'LinkedIn Profile', Icons.link),
              _buildTextField(
                  _twitterController, 'Twitter Profile', Icons.link),
              _buildTextField(_githubController, 'GitHub Profile', Icons.link),
              _buildTextField(_skillsController, 'Skills (comma separated)',
                  Icons.psychology),
              _buildTextField(_bioController, 'Bio', Icons.description,
                  maxLines: 3),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveToDatabase,
                  child: const Text('Save Profile'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your $label';
          }
          return null;
        },
      ),
    );
  }
}
