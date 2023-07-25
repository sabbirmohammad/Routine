import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'data_input.dart';
import 'menu_bar.dart';
import 'database.dart';
import 'data_model.dart';
import 'database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<DataModel> _dataEntries = [];

  @override
  void initState() {
    super.initState();
    _loadDataFromDatabase();

    // Refresh the app every 2 minutes
    Timer.periodic(Duration(minutes: 2), (timer) {
      setState(() {
        _loadDataFromDatabase();
      });
    });
  }

  Future<void> _loadDataFromDatabase() async {
    final dataList = await DatabaseHelper.getData();
    setState(() {
      _dataEntries.clear();
      _dataEntries.addAll(dataList);
    });
  }

  List<DataModel> _getDataForToday() {
    final currentDay = DateFormat('EEEE').format(DateTime.now());
    final todayData = _dataEntries.where((data) => data.selectedDay == currentDay).toList();

    // Sort the data by time before returning
    todayData.sort((a, b) {
      final aTime = _getDateTimeFromTimeOfDay(TimeOfDay.fromDateTime(DateFormat('hh:mm a').parse(a.selectedTime)));
      final bTime = _getDateTimeFromTimeOfDay(TimeOfDay.fromDateTime(DateFormat('hh:mm a').parse(b.selectedTime)));
      return aTime.compareTo(bTime);
    });

    return todayData;
  }

  DateTime _getDateTimeFromTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
  }

  @override
  Widget build(BuildContext context) {
    final data = _getDataForToday();
    final currentTime = TimeOfDay.now();
    final currentTimeInMinutes = currentTime.hour * 60 + currentTime.minute;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Class Routine',
          style: TextStyle(
            fontSize: 26.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Courier New',
            color: Colors.green, // Monospaced font
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.green), // Dark background color
      ),
      drawer: CustomDrawer(versionNumber: '1.0',),
      body: Container(
        color: Colors.black, // Dark background color
        child: data.isEmpty
            ? _buildNoClassesScheduledCard()
            : _buildClassScheduleList(data, currentTimeInMinutes),
      ),
    );
  }

  Widget _buildNoClassesScheduledCard() {
    return Center(
      child: Card(
        color: Colors.black, // Dark grey card background color
        elevation: 4.0,
        margin: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No Classes Scheduled for Today.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26.0,
              fontFamily: 'Courier New',
              fontWeight: FontWeight.bold,
              color: Colors.red, // White text color
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClassScheduleList(List<DataModel> data, int currentTimeInMinutes) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final dataItem = data[index];

        return Card(
          color: Colors.grey[900], // Default dark grey
          elevation: 2.0,
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Time: ${dataItem.selectedTime}',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold, // Green text color
                    fontFamily: 'Courier New', // Monospaced font
                  ),
                ),
                Text(
                  'Course: ${dataItem.courseTitle}',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.green, // Green text color
                    fontFamily: 'Courier New', // Monospaced font
                  ),
                ),
                Text(
                  'Room:  ${dataItem.roomNumber}',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.red, // Red text color
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier New', // Monospaced font
                  ),
                ),
                // Uncomment this to display the day
                // Text(
                //   'Day: ${dataItem.selectedDay}',
                //   style: TextStyle(
                //     fontSize: 18.0,
                //     color: Colors.green, // Green text color
                //     fontFamily: 'Courier New', // Monospaced font
                //   ),
                // ),
                Text(
                  'Code: ${dataItem.courseCode}',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.green, // Green text color
                    fontFamily: 'Courier New', // Monospaced font
                  ),
                ),
                Text(
                  'Teacher: ${dataItem.teacherName}',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.green, // Green text color
                    fontFamily: 'Courier New', // Monospaced font
                  ),
                ),
              ],
            ),
            onTap: () {
              // When a ListTile is tapped, navigate to DataInput page for editing
              _navigateToDataInputForEdit(dataItem);
            },
          ),
        );
      },
    );
  }

  void _navigateToDataInputForAdd() async {
    final newData = await Navigator.push<DataModel>(
      context,
      MaterialPageRoute(builder: (context) => DataInput()),
    );

    if (newData != null) {
      // Convert the selectedTime to a formatted string before saving to the database
      newData.selectedTime = _formatTime(newData.selectedTime as TimeOfDay);

      await DatabaseHelper.insertData(newData);
      _loadDataFromDatabase(); // Refresh the screen after adding new data
    }
  }

  void _navigateToDataInputForEdit(DataModel data) async {
    final updatedData = await Navigator.push<DataModel>(
      context,
      MaterialPageRoute(builder: (context) => DataInput(data: data)),
    );

    if (updatedData != null) {
      // Convert the selectedTime to a formatted string before updating the database
      updatedData.selectedTime = _formatTime(updatedData.selectedTime as TimeOfDay);

      await DatabaseHelper.updateData(updatedData);
      _loadDataFromDatabase(); // Refresh the screen after updating data
    }
  }

  // Helper function to convert TimeOfDay to string
  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
