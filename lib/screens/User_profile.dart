import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class AlumniProfilePage extends StatelessWidget {
  final Map<String, dynamic> alumniData;

  const AlumniProfilePage({super.key, required this.alumniData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alumni Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share profile functionality could be implemented here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality coming soon')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header with Image and Basic Info
            Container(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(alumniData['image']),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      alumniData['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${alumniData['designation']} at ${alumniData['company']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${alumniData['city']}, ${alumniData['country']}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    // Social Media Links
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (alumniData['linkedin'] != null && alumniData['linkedin'].toString().isNotEmpty)
                          _buildSocialButton(
                            icon: Icons.link,
                            onTap: () => _launchUrl(alumniData['linkedin']),
                            label: 'LinkedIn',
                          ),
                        if (alumniData['twitter'] != null && alumniData['twitter'].toString().isNotEmpty)
                          _buildSocialButton(
                            icon: Icons.link,
                            onTap: () => _launchUrl(alumniData['twitter']),
                            label: 'Twitter',
                          ),
                        if (alumniData['github'] != null && alumniData['github'].toString().isNotEmpty)
                          _buildSocialButton(
                            icon: Icons.link,
                            onTap: () => _launchUrl(alumniData['github']),
                            label: 'GitHub',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Contact Information
            _buildSection(
              title: 'Contact Information',
              content: Column(
                children: [
                  _buildContactTile(
                    icon: Icons.email,
                    title: 'Email',
                    subtitle: alumniData['email'],
                    onTap: () => _launchUrl('mailto:${alumniData['email']}'),
                  ),
                  _buildContactTile(
                    icon: Icons.phone,
                    title: 'Phone',
                    subtitle: alumniData['phone'],
                    onTap: () => _launchUrl('tel:${alumniData['phone']}'),
                  ),
                  _buildContactTile(
                    icon: Icons.location_on,
                    title: 'Address',
                    subtitle: alumniData['address'],
                  ),
                ],
              ),
            ),

            // Education Information
            _buildSection(
              title: 'Education',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Degree', alumniData['degree']),
                  _buildInfoRow('Major', alumniData['major']),
                  _buildInfoRow('Graduation Year', alumniData['graduationYear']),
                ],
              ),
            ),

            // Professional Information
            _buildSection(
              title: 'Professional Experience',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Company', alumniData['company']),
                  _buildInfoRow('Designation', alumniData['designation']),
                  _buildInfoRow('Years of Experience', alumniData['experience']),
                ],
              ),
            ),

            // Skills
            _buildSection(
              title: 'Skills',
              content: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (alumniData['skills'] as List).map((skill) {
                  return Chip(
                    label: Text(skill),
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  );
                }).toList(),
              ),
            ),

            // Biography
            if (alumniData['bio'] != null && alumniData['bio'].toString().isNotEmpty)
              _buildSection(
                title: 'Biography',
                content: Text(
                  alumniData['bio'],
                  style: const TextStyle(fontSize: 16),
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contact request sent!')),
          );
        },
        child: const Icon(Icons.message),
        tooltip: 'Connect with this alumni',
      ),
    );
  }

  Widget _buildSection({required String title, required Widget content}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.toString(),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: onTap != null
          ? Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.content_copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: subtitle));
            },
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: onTap,
          ),
        ],
      )
          : IconButton(
        icon: const Icon(Icons.content_copy),
        onPressed: () {
          Clipboard.setData(ClipboardData(text: subtitle));
        },
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onTap,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            CircleAvatar(
              radius: 20,
              child: Icon(icon),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}       