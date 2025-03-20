import 'package:flutter/material.dart';

import 'alumini.dart';
import 'api_services.dart';

class AlumniListScreen extends StatefulWidget {
  const AlumniListScreen({Key? key}) : super(key: key);

  @override
  _AlumniListScreenState createState() => _AlumniListScreenState();
}

class _AlumniListScreenState extends State<AlumniListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Alumni>> _alumniList;

  @override
  void initState() {
    super.initState();
    _alumniList = _apiService.getAlumni();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alunet - Alumni Network'),
      ),
      body: FutureBuilder<List<Alumni>>(
        future: _alumniList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 60),
                  SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No alumni records found'));
          } else {
            // Display the data in a ListView
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final alumni = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(
                      alumni.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Class of ${alumni.graduationYear}'),
                        Text(alumni.email),
                        if (alumni.currentCompany != null)
                          Text('${alumni.jobTitle ?? "Works"} at ${alumni.currentCompany}'),
                      ],
                    ),
                    isThreeLine: true,
                    leading: CircleAvatar(
                      child: Text(alumni.name[0]),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}