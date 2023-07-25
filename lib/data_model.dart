import 'package:flutter/material.dart';

class DataModel {
  int? id;
  String selectedDay;
  String selectedTime; // Changed to String to store time as a formatted String
  String courseCode;
  String courseTitle;
  String teacherName;
  String roomNumber;

  DataModel({
    this.id,
    required this.selectedDay,
    required this.selectedTime,
    required this.courseCode,
    required this.courseTitle,
    required this.teacherName,
    required this.roomNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'selectedDay': selectedDay,
      'selectedTime': selectedTime, // Store the formatted time String
      'courseCode': courseCode,
      'courseTitle': courseTitle,
      'teacherName': teacherName,
      'roomNumber': roomNumber,
    };
  }

  static DataModel fromMap(Map<String, dynamic> map) {
    return DataModel(
      id: map['id'],
      selectedDay: map['selectedDay'],
      selectedTime: map['selectedTime'],
      courseCode: map['courseCode'],
      courseTitle: map['courseTitle'],
      teacherName: map['teacherName'],
      roomNumber: map['roomNumber'],
    );
  }

  static String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  static TimeOfDay parseTime(String timeStr) {
    final parts = timeStr.split(' ');
    final time = parts[0];
    final period = parts[1];
    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final dayPeriod = period == 'AM' ? DayPeriod.am : DayPeriod.pm;
    return TimeOfDay(hour: hour, minute: minute);
  }
}
