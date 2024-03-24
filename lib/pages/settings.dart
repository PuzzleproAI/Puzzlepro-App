import 'package:flutter/material.dart';
import 'package:puzzlepro_app/Data/constants.dart';
import 'package:puzzlepro_app/models/theme_data.dart';
import 'package:puzzlepro_app/services/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage(
      {super.key,
      required this.changeTheme,
      required this.changeColor,
      required this.themeModel});

  final Function(int) changeTheme;
  final Function(ColorSeed) changeColor;
  final ThemeDataModel themeModel;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

List<String> themeOptions = ['System Mode', 'Light Mode', 'Dark Mode'];

class _SettingsPageState extends State<SettingsPage> {
  List<ColorSeed> colorOptions = ColorSeed.values.toList();
  Color? selectedColor;
  int selectedColorIndex = 0;
  int themeValue = 0;
  String _selectedTheme = 'System Mode';

  int scannedSudokuCount = 0;
  int generatedSudokuCount = 0;
  int totalSudoku = 0;
  int totalPendingSudoku = 0;
  bool isDataFetched = false;

  void deleteData() async {
    await StorageHelper.deleteAllData();
    await fetchStatistics();
  }

  @override
  void initState() {
    super.initState();
    fetchStatistics();
    setState(() {
      _selectedTheme = themeOptions[widget.themeModel.themeValue];
      themeValue = widget.themeModel.themeValue;
      selectedColor = colorOptions[widget.themeModel.colorSelected.index].color;
    });
  }

  getBrightness(int value) {
    switch (value) {
      case 0:
        return View.of(context).platformDispatcher.platformBrightness;
      case 1:
        return Brightness.light;
      case 2:
        return Brightness.dark;
    }
    return Brightness.dark;
  }

  saveTheme(int themeValue) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setInt('isLightMode', themeValue);
  }

  saveColorSelected() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setInt('colorSeed', selectedColorIndex);
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
                        if (newValue == 'Light Mode') {
                          themeValue = 1;
                        } else if (newValue == 'Dark Mode') {
                          themeValue = 2;
                        }
                        widget.changeTheme(themeValue);
                        saveTheme(themeValue);
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
                            dimension:
                                MediaQuery.of(context).size.width.toInt() / 11,
                            onTap: () {
                              widget.changeColor(colorOptions[
                                  i * colorOptions.length ~/ 3 + j]);
                              setState(() {
                                selectedColor = colorOptions[
                                        i * colorOptions.length ~/ 3 + j]
                                    .color;
                                selectedColorIndex =
                                    i * colorOptions.length ~/ 3 + j;
                              });
                              saveColorSelected();
                            },
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
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
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Generated Sudoku: $generatedSudokuCount',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Sudoku: $totalSudoku',
                  style: const TextStyle(fontSize: 17),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total pending Sudoku: $totalPendingSudoku',
                  style: const TextStyle(fontSize: 17),
                ),
                Text(
                  'Total Solved Sudoku: ${totalSudoku - totalPendingSudoku}',
                  style: const TextStyle(fontSize: 17),
                )
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
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
  final Function() onTap;
  final double dimension;

  const RoundColorButton({
    super.key,
    required this.color,
    required this.isSelected,
    required this.onTap,
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
            color: isSelected ? Colors.black : Colors.transparent, width: 4),
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
                const Center(
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.black87,
                    size: 19,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
