import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mysql_client/mysql_client.dart';
import 'home_screen.dart';
import '../api/api_services.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  MySQLConnection? _conn;
  bool _isConnecting = false;
  String? _connectionError;

  // Controllers for all fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _graduationYearController = TextEditingController();
  final _degreeController = TextEditingController();
  final _majorController = TextEditingController();
  final _currentCompanyController = TextEditingController();
  final _designationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _twitterController = TextEditingController();
  final _githubController = TextEditingController();
  final _skillsController = TextEditingController();
  final _bioController = TextEditingController();

  // final ApiService _apiService = ApiService();

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
      // For physical device, use your computer's actual IP address
      // Note: 10.0.2.2 only works for Android emulator
      // documnetation
      final conn = await MySQLConnection.createConnection(
        host: "192.168.236.135", // REPLACE WITH YOUR ACTUAL IP ADDRESS
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
    // If there's a connection error, try to reconnect
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
      // this is an insert query
      final result = await _conn!.execute(
        "INSERT INTO alumni (full_name, email, phone_number, address, city, country, graduation_year, "
        "degree, major, current_company, designation, years_of_experience, linkedin_url, twitter_url, "
        "github_url, skills, bio) VALUES (:name, :email, :phone, :address, :city, :country, :grad_year, "
        ":degree, :major, :company, :designation, :experience, :linkedin, :twitter, :github, :skills, :bio)",
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
          "company": _currentCompanyController.text,
          "designation": _designationController.text,
          "experience": int.parse(_experienceController.text),
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

  // void _saveProfile() async {
  //   if (_formKey.currentState!.validate()) {
  //     // For testing without database connection
  //     bool useApi = false; // Set to true to use API instead of direct database
  //
  //     if (useApi) {
  //       // Using API service approach
  //       final alumniData = {
  //         'full_name': _nameController.text,
  //         'email': _emailController.text,
  //         'phone_number': _phoneController.text,
  //         'address': _addressController.text,
  //         'city': _cityController.text,
  //         'country': _countryController.text,
  //         'graduation_year': int.parse(_graduationYearController.text),
  //         'degree': _degreeController.text,
  //         'major': _majorController.text,
  //         'current_company': _currentCompanyController.text,
  //         'designation': _designationController.text,
  //         'years_of_experience': int.parse(_experienceController.text),
  //         'linkedin_url': _linkedinController.text,
  //         'twitter_url': _twitterController.text,
  //         'github_url': _githubController.text,
  //         'skills': _skillsController.text,
  //         'bio': _bioController.text,
  //       };
  //
  //       try {
  //         // await _apiService.saveAlumni(alumniData);
  //         // Navigator.pushReplacement(
  //         //   context,
  //         //   MaterialPageRoute(builder: (context) => const HomeScreen()),
  //         // );
  //       } catch (e) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Failed to save profile: $e')),
  //         );
  //       }
  //     } else {
  //       // Directly save to database without showing loading indicator
  //       await _saveToDatabase();
  //     }
  //   }
  // }

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
    _currentCompanyController.dispose();
    _designationController.dispose();
    _experienceController.dispose();
    _linkedinController.dispose();
    _twitterController.dispose();
    _githubController.dispose();
    _skillsController.dispose();
    _bioController.dispose();

    // Close the database connection
    _conn?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
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

              // Show connection status if there's an error
              if (_connectionError != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Database connection issue. Data will not be saved.',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.red),
                        onPressed: _setupDatabaseConnection,
                        tooltip: 'Retry connection',
                      ),
                    ],
                  ),
                ),

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
                  _currentCompanyController, 'Current Company', Icons.business),
              _buildTextField(
                  _designationController, 'Designation', Icons.work),
              _buildTextField(
                  _experienceController, 'Years of Experience', Icons.timeline),
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
