import 'package:flutter/material.dart';
import 'package:puzzlepro_app/Data/constants.dart';
import 'package:puzzlepro_app/Widgets/sudoku_board_widget.dart';
import 'package:puzzlepro_app/pages/sudoku_home.dart';
import 'package:puzzlepro_app/services/database.dart';
import 'package:sudoku_dart/sudoku_dart.dart' as plugin;
import 'package:puzzlepro_app/models/sudoku.dart';

const hardnessLevels = ["easy", "medium", "hard", "very-hard"];

class SudokuGeneratorPage extends StatefulWidget {
  const SudokuGeneratorPage({super.key, required this.handleScreenChange});

  final Function(int, String) handleScreenChange;

  @override
  State<SudokuGeneratorPage> createState() => _SudokuGeneratorPageState();
}

class _SudokuGeneratorPageState extends State<SudokuGeneratorPage> {
  List<String> difficulties = ["Easy", "Medium", "Hard", "Very hard"];
  late final ColorScheme _colorScheme = Theme.of(context).colorScheme;
  bool isSudokuGenerated = false;
  Sudoku generatedSudoku = Sudoku.empty();
  int chosenDifficulty = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isSudokuGenerated ? _menu() : _generatorCard(),
        ],
      ),
    );
  }

  Widget _menu() {
    return Expanded(
      child: Center(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
              child: Text(
                'Generated sudoku',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              'Difficulty ${difficulties[chosenDifficulty]}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            SudokuBoardWidget(
                sudoku: generatedSudoku, colorScheme: _colorScheme),
            const SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    generatorSudoku(chosenDifficulty);
                  },
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text("Try Again"),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 32.0),
                  child: ElevatedButton.icon(
                    onPressed: saveButton,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text("Save and start"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _generatorCard() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 10.0),
              child: Text(
                'SudokuGenerator by PuzzlePro',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 90.0),
            ElevatedButton(
              onPressed: () {
                generatorSudoku(0);
              },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(330, 80), // Set the button size
              ),
              child: const Text(
                'Easy',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                generatorSudoku(1);
              },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(330, 80), // Set the button size
              ),
              child: const Text(
                'Medium',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                generatorSudoku(2);
              },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(330, 80), // Set the button size
              ),
              child: const Text(
                'Hard',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                generatorSudoku(3);
              },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(330, 80), // Set the button size
              ),
              child: const Text(
                'Very-Hard',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Route _sudokuHomeRoute(int key) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SudokuHome(
        index: key,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        // Adding a fade transition along with the slide transition
        var fadeTween = Tween<double>(begin: 0.0, end: 1.0);
        var fadeAnimation = animation.drive(fadeTween);

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: animation.drive(tween),
            child: child,
          ),
        );
      },
    );
  }

  sendToHome(int id) {
    widget.handleScreenChange(ScreenSelected.home.value, "Generated");
    Navigator.push(context, _sudokuHomeRoute(id));
  }

  saveButton() async {
    int id = await StorageHelper.saveSudoku(generatedSudoku);
    sendToHome(id);
  }

  generatorSudoku(int index) {
    var sudokuObject = plugin.Sudoku.generate(plugin.Level.values[index]);
    var sudokuList = sudokuObject.puzzle;
    var sudokuMatrix = List.generate(
        9,
        (i) => List<int>.generate(
            9, (j) => -1 == sudokuList[i * 9 + j] ? 0 : sudokuList[i * 9 + j]));

    setState(() {
      generatedSudoku = Sudoku(sudokuMatrix, false, difficulties[index]);
      isSudokuGenerated = true;
      chosenDifficulty = index;
    });
  }
}
