import 'package:flutter/material.dart';
class Alumni {
  final int id;
  final String name;
  final String graduationYear;
  final String email;
  final String? phone;
  final String? course;
  final String? branch;
  final String? currentCompany;
  final String? jobTitle;

  Alumni({
    required this.id,
    required this.name,
    required this.graduationYear,
    required this.email,
    this.phone,
    this.course,
    this.branch,
    this.currentCompany,
    this.jobTitle,
  });

  // Factory constructor to create an Alumni from JSON
  factory Alumni.fromJson(Map<String, dynamic> json) {
    return Alumni(
      id: json['id'],
      name: json['name'],
      graduationYear: json['graduation_year'],
      email: json['email'],
      phone: json['phone'],
      course: json['course'],
      branch: json['branch'],
      currentCompany: json['current_company'],
      jobTitle: json['job_title'],
    );
  }
}