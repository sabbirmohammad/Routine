import 'package:flutter/material.dart';

class MenuBarButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.menu, color: Colors.green),
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
    );
  }
}

class CustomDrawer extends StatelessWidget {
  // Version number to be displayed in the drawer
  final String versionNumber;

  CustomDrawer({required this.versionNumber});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.black, // Set the background color of the drawer to black
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black26,
              ),
              child: Center(
                child: Text(
                  'Controller',
                  style: TextStyle(
                    color: Colors.green,
                    fontFamily: 'Courier New',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard, color: Colors.green),
              title: const Text(
                'Dashboard',
                style: TextStyle(
                    color: Colors.green,
                    fontFamily: 'Courier New',
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/'); // Navigate to HomeScreen
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.green),
              title: const Text(
                'Data Input',
                style: TextStyle(
                    color: Colors.green,
                    fontFamily: 'Courier New',
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/datainput'); // Navigate to DataInput page
              },
            ),
            ListTile(
              leading: const Icon(Icons.storage, color: Colors.green),
              title: const Text(
                'Database',
                style: TextStyle(
                    color: Colors.green,
                    fontFamily: 'Courier New',
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/database'); // Navigate to DatabaseScreen
              },
            ),
            // ListTile to display version number
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.redAccent, size: 18),
              title: Text(
                'Version $versionNumber', // Use the provided version number
                style: TextStyle(
                  color: Colors.redAccent,
                  fontFamily: 'Courier New',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
