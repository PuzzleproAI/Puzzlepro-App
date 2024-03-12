import 'package:flutter/material.dart';
import 'package:puzzlepro_app/Data/constants.dart';
import 'package:puzzlepro_app/services/database.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage(
      {super.key, required this.changeTheme, required this.changeColor});

  final Function(int) changeTheme;
  final Function(ColorSeed, bool) changeColor;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<ColorSeed> colorOptions = ColorSeed.values.toList();
  bool isAuto = false;

  Color? selectedColor;

  String _selectedTheme = 'System Mode';
  late ColorScheme _colorScheme = Theme.of(context).colorScheme;

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

  fetchStatistics() async {
    var data = await StorageHelper.loadStatistics();
    if (data == null) {
      return;
    }
    setState(() {
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
                        _colorScheme = Theme.of(context).colorScheme;
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Color Theme Options',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                for (int i = 0; i < 3; i++)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int j = 1; j < colorOptions.length / 3; j++)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RoundColorButton(
                            color:
                                colorOptions[i * colorOptions.length ~/ 3 + j]
                                    .color,
                            isSelected:
                                colorOptions[i * colorOptions.length ~/ 3 + j]
                                        .color ==
                                    selectedColor,
                            colorScheme: _colorScheme,
                            dimension:
                                MediaQuery.of(context).size.width.toInt() / 11,
                            onTap: () {
                              widget.changeColor(
                                  colorOptions[
                                      i * colorOptions.length ~/ 3 + j],
                                  false);
                              setState(() {
                                selectedColor = colorOptions[
                                        i * colorOptions.length ~/ 3 + j]
                                    .color;
                              });
                            },
                          ),
                        ),
                    ],
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

class RoundColorButton extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final double dimension;

  const RoundColorButton({
    super.key,
    required this.color,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
    required this.dimension,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(
            color: isSelected ? colorScheme.secondary : Colors.transparent,
            width: 4),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.check,
                    color: colorScheme.secondary,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
