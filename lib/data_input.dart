import 'package:flutter/material.dart';
import 'data_model.dart';
import 'database_helper.dart';

class DataInput extends StatefulWidget {
  final DataModel? data; // Updated to accept the data parameter

  DataInput({this.data});

  @override
  _DataInputState createState() => _DataInputState();
}

class _DataInputState extends State<DataInput> {
  String selectedDay = 'Select Day';
  TimeOfDay? _selectedTime; // Changed to nullable
  TextEditingController courseController = TextEditingController();
  TextEditingController courseTitleController = TextEditingController();
  TextEditingController teacherNameController = TextEditingController();
  TextEditingController roomNumberController = TextEditingController();
  FocusNode courseFocusNode = FocusNode();
  FocusNode courseTitleFocusNode = FocusNode();
  FocusNode teacherNameFocusNode = FocusNode();
  FocusNode roomNumberFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.data != null ? DataModel.parseTime(widget.data!.selectedTime) : null; // Initialize with the data if available
    if (widget.data != null) {
      selectedDay = widget.data!.selectedDay;
      courseController.text = widget.data!.courseCode;
      courseTitleController.text = widget.data!.courseTitle;
      teacherNameController.text = widget.data!.teacherName;
      roomNumberController.text = widget.data!.roomNumber;
    }
  }

  @override
  void dispose() {
    // Dispose the FocusNode instances when the widget is disposed
    courseFocusNode.dispose();
    courseTitleFocusNode.dispose();
    teacherNameFocusNode.dispose();
    roomNumberFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Data Input',
          style: TextStyle(
            fontFamily: 'Courier New',
            fontWeight: FontWeight.bold,
            fontSize: 26.0,
            color: Colors.green,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.green),
      ),
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          // Wrap the Column with a ListView
          children: [
            SizedBox(
              height: 60,
              child: DropdownTextField(
                value: selectedDay,
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      selectedDay = value;
                    });
                  }
                },
                items: const [
                  'Saturday',
                  'Sunday',
                  'Monday',
                  'Tuesday',
                  'Wednesday',
                  'Thursday',
                  'Friday',
                  'Select Day',
                ],
              ),
            ),
            const SizedBox(height: 25),
            buildTimeSelectField(),
            const SizedBox(height: 25),
            buildCustomTextField('Course Code', courseController, courseFocusNode),
            const SizedBox(height: 25),
            buildCustomTextField('Course Title', courseTitleController, courseTitleFocusNode),
            const SizedBox(height: 25),
            buildCustomTextField('Teacher\'s Name', teacherNameController, teacherNameFocusNode),
            const SizedBox(height: 25),
            buildCustomTextField('Room Number', roomNumberController, roomNumberFocusNode),
            const SizedBox(height: 80),
            buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget buildCustomTextField(String label, TextEditingController controller, FocusNode focusNode) {
    return Focus(
      focusNode: focusNode,
      onFocusChange: (isFocused) {
        setState(() {
          controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
        });
      },
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontFamily: 'Courier New',
          color: Colors.green,
          fontSize: 18,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontFamily: 'Courier New',
            color: Colors.green,
            fontSize: 18,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green, width: 1.7),
            borderRadius: BorderRadius.circular(8.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green, width: 1.7),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(), // Set the default time to the current time
    );
    if (newTime != null) {
      setState(() {
        _selectedTime = newTime;
      });
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Select Time';
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Widget buildTimeSelectField() {
    return GestureDetector(
      onTap: () => _selectTime(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Time',
          labelStyle: TextStyle(
            fontFamily: 'Courier New',
            color: Colors.green,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green, width: 1.7),
            borderRadius: BorderRadius.circular(8.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green, width: 1.7),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(
          _formatTime(_selectedTime), // Pass _selectedTime directly
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Courier New',
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  Widget buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _onSaveButtonPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Save',
          style: TextStyle(fontSize: 22, fontFamily: 'Courier New', fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _onSaveButtonPressed() async {
    final data = DataModel(
      selectedDay: selectedDay,
      selectedTime: DataModel.formatTime(_selectedTime!), // Convert TimeOfDay to string
      courseCode: courseController.text,
      courseTitle: courseTitleController.text,
      teacherName: teacherNameController.text,
      roomNumber: roomNumberController.text,
    );

    // If widget.data is not null, it means we are editing an existing entry
    if (widget.data != null) {
      data.id = widget.data!.id; // Copy the existing ID to the updated data
      await DatabaseHelper.updateData(data);
      Navigator.pop(context, data); // Pass the updated data back to DatabaseScreen
    } else {
      await DatabaseHelper.insertData(data);
      Navigator.pop(context, data); // Pass the new data back to DatabaseScreen
    }

    // Show the "Data Have Been Saved" message
    _showDataSavedMessage();
  }

  void _showDataSavedMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Success', style: TextStyle(fontFamily: 'Courier New', color: Colors.white)),
          content: const Text('Data Have Been Saved', style: TextStyle(fontFamily: 'Courier New', color: Colors.white)),
          backgroundColor: Colors.black,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(fontFamily: 'Courier New', color: Colors.green)),
            ),
          ],
        );
      },
    );
  }
}

class DropdownTextField extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;

  DropdownTextField({
    required this.value,
    required this.items,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Day',
        labelStyle: TextStyle(
          fontFamily: 'Courier New',
          color: Colors.green,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green, width: 1.7),
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green, width: 1.7),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  fontFamily: 'Courier New',
                  color: Colors.green,
                  fontSize: 18,
                ),
              ),
            );
          }).toList(),
          dropdownColor: Colors.grey[900],
        ),
      ),
    );
  }
}
