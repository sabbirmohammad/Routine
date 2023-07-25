import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'menu_bar.dart';
import 'data_input.dart';
import 'data_model.dart';
import 'database_helper.dart';

class DatabaseScreen extends StatefulWidget {
  const DatabaseScreen({Key? key}) : super(key: key);

  @override
  _DatabaseScreenState createState() => _DatabaseScreenState();
}

class _DatabaseScreenState extends State<DatabaseScreen> {
  final List<DataModel> _dataEntries = [];

  // Define the order of days starting from Saturday
  final List<String> _daysOrder = [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  @override
  void initState() {
    super.initState();
    _loadDataFromDatabase();
  }

  Future<void> _loadDataFromDatabase() async {
    final dataList = await DatabaseHelper.getData();

    // Sort the data based on the day and time
    dataList.sort((a, b) {
      final aDayIndex = _daysOrder.indexOf(a.selectedDay);
      final bDayIndex = _daysOrder.indexOf(b.selectedDay);

      if (aDayIndex != bDayIndex) {
        // If days are different, sort by day first
        return aDayIndex.compareTo(bDayIndex);
      } else {
        // If days are the same, sort by time
        final aTime = _getDateTimeFromData(a);
        final bTime = _getDateTimeFromData(b);
        return aTime.isBefore(bTime) ? -1 : 1;
      }
    });

    setState(() {
      _dataEntries.clear();
      _dataEntries.addAll(dataList);
    });
  }

  DateTime _getDateTimeFromData(DataModel data) {
    final timeFormat = DateFormat('hh:mm a');
    final now = DateTime.now();
    return timeFormat.parse(data.selectedTime).isBefore(now)
        ? DateTime(now.year, now.month, now.day + 1, timeFormat.parse(data.selectedTime).hour, timeFormat.parse(data.selectedTime).minute)
        : DateTime(now.year, now.month, now.day, timeFormat.parse(data.selectedTime).hour, timeFormat.parse(data.selectedTime).minute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Database',
          style: TextStyle(
            fontFamily: 'Courier New',
            fontWeight: FontWeight.bold,
            fontSize: 26.0,
            color: Colors.green, // Monospaced font
          ),
        ),
        backgroundColor: Colors.black, // Set the title bar color to black
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.green), // Center the title horizontally
      ),
      drawer: CustomDrawer(versionNumber: '1.0',),
      body: ListView.builder(
        itemCount: _dataEntries.length,
        itemBuilder: (context, index) {
          final data = _dataEntries[index];
          final isFirstItem = index == 0;
          final isDifferentDay = index > 0 && data.selectedDay != _dataEntries[index - 1].selectedDay;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isFirstItem || isDifferentDay) _buildRedDivider(data.selectedDay),
              GestureDetector(
                onLongPress: () => _showDeleteConfirmation(context, data),
                child: Card(
                  color: Colors.grey[900], // Set the background color of each item to gray
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Title: ${data.courseTitle}',
                          style: TextStyle(fontFamily: 'Courier New', color: Colors.green), // Set the font color to green
                        ),
                        Text(
                          'Code: ${data.courseCode}',
                          style: TextStyle(fontFamily: 'Courier New', color: Colors.green), // Set the font color to green
                        ),
                        // Uncomment the code below to show the selectedDay in the list ----------------->
                        // Text(
                        //   'Day: ${data.selectedDay}',
                        //   style: TextStyle(fontFamily: 'Courier New', color: Colors.green), // Set the font color to green
                        // ),
                        Text(
                          'Time: ${data.selectedTime}',
                          style: TextStyle(fontFamily: 'Courier New', color: Colors.red), // Set the font color to green
                        ),
                        Text(
                          "Teacher: ${data.teacherName}",
                          style: TextStyle(fontFamily: 'Courier New', color: Colors.green), // Set the font color to green
                        ),
                        Text(
                          'Room: ${data.roomNumber}',
                          style: TextStyle(fontFamily: 'Courier New', color: Colors.yellow), // Set the font color to green
                        ),
                      ],
                    ),
                    onTap: () {
                      // When a ListTile is tapped, navigate to DataInput page for editing
                      _navigateToDataInputForEdit(data);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to DataInput page for adding new data
          _navigateToDataInputForAdd();
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      backgroundColor: Colors.black,
    );
  }

  Widget _buildRedDivider(String dayName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Uncomment the code below to add a red divider between days ----------------->
        // Container(
        //   height: 2,
        //   color: Colors.red,
        //   margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        // ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            dayName,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier New',
              fontSize: 18.0,
            ),
          ),
        ),
      ],
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

  // Helper function to delete a data entry from the database
  Future<void> _deleteDataEntry(DataModel data) async {
    await DatabaseHelper.deleteData(data.id!);
    _loadDataFromDatabase(); // Refresh the screen after deleting data
  }

  // Helper function to show a confirmation dialog before deleting the data
  void _showDeleteConfirmation(BuildContext context, DataModel data) {
    showModalBottomSheet(
      backgroundColor: Colors.black,
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                  'WARNING: Deleting this Data is Irreversible!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Courier New'
                  )
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteDataEntry(data);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.red, // Set the background color to red
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Add rounded corners
                  padding: const EdgeInsets.symmetric(vertical: 16), // Increase padding for better visibility
                ),
                child:
                const Text(
                  'HACK DELETE',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Courier New',
                      color: Colors.white // Set the text color to white
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
