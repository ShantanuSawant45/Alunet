import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';

import 'User_profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Name';

  final List<String> _filterOptions = [
    'Name',
    'Company',
    'Graduation Year',
    'Skills',
    'Location',
    'Degree'
  ];

  List<Map<String, dynamic>> _alumni = [];
  List<Map<String, dynamic>> _filteredAlumni = [];
  bool _isLoading = true;
  String? _errorMessage;
  MySQLConnection? _conn;

  @override
  void initState() {
    super.initState();
    _setupDatabaseConnection();
  }

  Future<void> _setupDatabaseConnection() async {
    try {
      final conn = await MySQLConnection.createConnection(
        host: "192.168.153.49", // Make sure this matches your UserDetailsScreen
        port: 3306,
        userName: "root",
        password: "mysql@264",
        databaseName: "alunet_db",
        secure: false,
      );

      await conn.connect();
      _conn = conn;

      // Once connected, fetch the alumni data
      await _fetchAlumniData();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Database connection error: $e";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Database connection failed: $e'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _fetchAlumniData() async {
    if (_conn == null) {
      setState(() {
        _errorMessage = "Database connection not established";
        _isLoading = false;
      });
      return;
    }

    try {
      // Fetch alumni data from the database
      final results = await _conn!.execute("SELECT * FROM alumni");

      final List<Map<String, dynamic>> alumniList = [];

      // Process each row
      for (final row in results.rows) {
        // Convert IResultRowEntry to regular Map
        final Map<String, dynamic> alumniData = {
          'id': row.colAt(0),
          'name': row.colByName("full_name"),
          'email': row.colByName("email"),
          'phone': row.colByName("phone_number"),
          'address': row.colByName("address"),
          'city': row.colByName("city"),
          'country': row.colByName("country"),
          'location': "${row.colByName("city")}, ${row.colByName("country")}",
          'graduationYear': row.colByName("graduation_year"),
          'degree': row.colByName("degree"),
          'major': row.colByName("major"),
          'company': row.colByName("current_company"),
          'designation': row.colByName("designation"),
          'experience': row.colByName("years_of_experience"),
          'linkedin': row.colByName("linkedin_url"),
          'twitter': row.colByName("twitter_url"),
          'github': row.colByName("github_url"),
          'skills': row.colByName("skills")?.toString().split(',').map((skill) => skill.trim()).toList() ?? [],
          'bio': row.colByName("bio"),
          // Default image if there's no profile picture in the database
          'image': 'https://picsum.photos/200',
        };

        alumniList.add(alumniData);
      }

      setState(() {
        _alumni = alumniList;
        _filteredAlumni = alumniList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching alumni data: $e";
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch alumni data: $e'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _filterAlumni(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredAlumni = _alumni;
      });
      return;
    }

    setState(() {
      _filteredAlumni = _alumni.where((alumni) {
        switch (_selectedFilter) {
          case 'Name':
            return alumni['name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase());
          case 'Company':
            return alumni['company']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase());
          case 'Graduation Year':
            return alumni['graduationYear']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase());
          case 'Skills':
            return (alumni['skills'] as List).any((skill) =>
                skill.toString().toLowerCase().contains(query.toLowerCase()));
          case 'Location':
            return alumni['location']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase());
          case 'Degree':
            return alumni['degree']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase());
          default:
            return false;
        }
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alunet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Navigate to own profile page
              // You'll need to implement this based on your authentication flow
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search alumni...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: _filterAlumni,
                      ),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: _selectedFilter,
                      items: _filterOptions.map((String filter) {
                        return DropdownMenuItem<String>(
                          value: filter,
                          child: Text(filter),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedFilter = newValue;
                          });
                          _filterAlumni(_searchController.text);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _errorMessage = null;
                      });
                      _setupDatabaseConnection();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
                : _filteredAlumni.isEmpty
                ? const Center(
              child: Text(
                'No alumni found matching your search criteria',
                style: TextStyle(fontSize: 16),
              ),
            )
                : ListView.builder(
              itemCount: _filteredAlumni.length,
              itemBuilder: (context, index) {
                final alumni = _filteredAlumni[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(alumni['image']),
                    ),
                    title: Text(alumni['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '${alumni['designation']} at ${alumni['company']}'),
                        Text(alumni['location']),
                        Wrap(
                          spacing: 4,
                          children: (alumni['skills'] as List)
                              .take(3)
                              .map((skill) => Chip(
                            label: Text(
                              skill,
                              style: const TextStyle(fontSize: 12),
                            ),
                            padding: EdgeInsets.zero,
                          ))
                              .toList(),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Navigate to the alumni profile page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AlumniProfilePage(
                            alumniData: alumni,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement post creation logic
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _conn?.close();
    super.dispose();
  }
}