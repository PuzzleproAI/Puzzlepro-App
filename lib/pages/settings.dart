import 'package:flutter/material.dart';
import 'package:puzzlepro_app/Data/constants.dart';
import 'package:puzzlepro_app/services/database.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.changeTheme});

  final Function(int) changeTheme;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedTheme = 'System Mode';
  late final ColorScheme _colorScheme = Theme.of(context).colorScheme;

  // Example counts (modify these according to your logic)
  int scannedSudokusCount = StorageHelper.scannedSudokusCount; // Replace with actual count
  int generatedSudokusCount = StorageHelper.generatedSudokusCount; // Replace with actual count
  int totalSudokus = StorageHelper.totalSudokus;
  int totalpendingSudokus = StorageHelper.pendingSudokus;

  void deleteData(){

    setState(() {
      StorageHelper.DeleteAllData();

    });
  }
  @override
  void initState() {
    super.initState();
    // Load statistics when the page is initialized

    setState(() {
      StorageHelper.loadStatistics();
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Theme',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedTheme,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedTheme = newValue;
                        if (newValue == 'System Mode') {
                          widget.changeTheme(0);
                        } else if (newValue == 'Light Mode') {
                          widget.changeTheme(1);
                        } else if (newValue == 'Dark Mode') {
                          widget.changeTheme(2);
                        }
                      });
                    }
                  },
                  underline: Container(), // Remove the underline
                  items: <String>['System Mode', 'Light Mode', 'Dark Mode']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: _colorScheme.primary),
            SizedBox(height: 16),

            // Display the counts
            Text(
              'Statistics of app usage',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Scanned Sudokus: $scannedSudokusCount',
                  style: TextStyle(fontSize: 15, color: _colorScheme.primary),
                ),
                Text(
                  'Generated Sudokus: $generatedSudokusCount',
                  style: TextStyle(fontSize: 15, color: _colorScheme.primary),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Sudokus: $totalSudokus',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total pending Sudokus: $totalpendingSudokus',
                  style: TextStyle(fontSize: 18),
                )
              ],
            ),
            SizedBox(height: 16),
            Divider(color: _colorScheme.primary),
            // Add more settings as needed
            SizedBox(height: 16,),
            Expanded(

              child: Align(
                heightFactor: 60,
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () {
                    deleteData();
                  },
                  child: Text(
                    'Delete All Sudokus',
                    style: TextStyle(fontSize: 18,color: Colors.black,height: 2),
                  ),
                  style: ElevatedButton.styleFrom(

                    primary: _colorScheme.primary,
                    // Set the button color
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
