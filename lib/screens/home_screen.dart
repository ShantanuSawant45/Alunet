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
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.grey.shade50,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        offset: const Offset(0, 3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        offset: const Offset(0, 10),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
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
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Profile image with gradient border
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.blue.shade200,
                                        Colors.purple.shade200,
                                      ],
                                    ),
                                  ),
                                  child: Hero(
                                    tag: 'alumni_image_${alumni['id'] ?? alumni['name']}',
                                    child: CircleAvatar(
                                      radius: 36,
                                      backgroundColor: Colors.white,
                                      backgroundImage: NetworkImage(alumni['image']),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  alumni['name'],
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.3,
                                                    height: 1.2,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${alumni['designation']} at ${alumni['company']}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey.shade700,
                                                    height: 1.3,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.grey.shade100,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.05),
                                                  blurRadius: 3,
                                                  offset: const Offset(0, 1),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.arrow_forward_ios,
                                              size: 16,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on_outlined,
                                              size: 16,
                                              color: Colors.blue.shade300
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            alumni['location'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(height: 1, thickness: 0.5),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.blue.shade100, width: 0.5),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.school_outlined, size: 14, color: Colors.blue.shade700),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Skills',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: (alumni['skills'] as List)
                                          .take(3)
                                          .map((skill) => Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.grey.shade200,
                                                Colors.grey.shade100,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.03),
                                                blurRadius: 2,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            skill,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey.shade800,
                                            ),
                                          ),
                                        ),
                                      ))
                                          .toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
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
                                  icon: Icon(Icons.person_outline, size: 16, color: Colors.purple.shade400),
                                  label: Text(
                                    'View Profile',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.purple.shade400,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    backgroundColor: Colors.purple.shade50,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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