import 'package:flutter/material.dart';
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

  int scannedSudokuCount = 0;
  int generatedSudokuCount = 0;
  int totalSudoku = 0;
  int totalPendingSudoku = 0;
  bool isDataFetched = false;

  void deleteData() {
    setState(() {
      StorageHelper.deleteAllData();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchStatistics();
  }
  fetchStatistics() async{
    var data = await StorageHelper.loadStatistics();
    if(data == null){
      return;
    }
    setState((){
      scannedSudokuCount = data.totalSudoku - data.generatedSudokuCount;
      generatedSudokuCount = data.generatedSudokuCount;
      totalSudoku = data.totalSudoku;
      totalPendingSudoku = data.pendingSudoku;
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
                  underline: Container(),
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
            const SizedBox(height: 16),
            const Text(
              'Statistics of app usage',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Scanned Sudoku: $scannedSudokuCount',
                  style: TextStyle(fontSize: 15, color: _colorScheme.primary),
                ),
                Text(
                  'Generated Sudoku: $generatedSudokuCount',
                  style: TextStyle(fontSize: 15, color: _colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Sudoku: $totalSudoku',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total pending Sudoku: $totalPendingSudoku',
                  style: const TextStyle(fontSize: 18),
                )
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: _colorScheme.primary),
            // Add more settings as needed
            const SizedBox(
              height: 16,
            ),
            Expanded(
              child: Align(
                heightFactor: 60,
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () {
                    deleteData();
                  },
                  child: const Text(
                    'Delete All Sudoku',
                    style: TextStyle(fontSize: 18, height: 3),
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
