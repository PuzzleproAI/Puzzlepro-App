import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:puzzlepro_app/pages/sudoku_answer.dart';
import 'package:puzzlepro_app/pages/sudoku_check_answer.dart';
import 'package:puzzlepro_app/pages/sudoku_validate_answer.dart';
import 'package:share/share.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import '../models/sudoku.dart';
import '../services/database.dart';

class SudokuHome extends StatefulWidget {
  final int index;

  const SudokuHome({super.key, required this.index});

  @override
  State<SudokuHome> createState() => _SudokuHomeState();
}

class _SudokuHomeState extends State<SudokuHome> {
  late final ColorScheme _colorScheme = Theme.of(context).colorScheme;
  final List<int> currentSelectedCell = [10, 10];
  int isLoading = 0;
  Sudoku sudoku = Sudoku.empty();
  WidgetsToImageController controller = WidgetsToImageController();

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = 1;
    });
    fetchSudoku();
    setState(() {
      sudoku.lastViewed = DateTime.now();
    });
  }

  fetchSudoku() async {
    Sudoku? tempSudoku;
    tempSudoku = await StorageHelper.getSudokuByIndex(widget.index);
    setState(() {
      sudoku = tempSudoku ?? Sudoku.empty();
    });
  }

  void setAddedDigit(int digit) {
    if (currentSelectedCell[0] > 9) {
      return;
    }
    setState(() {
      sudoku.addedDigits![currentSelectedCell[0]][currentSelectedCell[1]] =
          digit;
    });
  }

  void onClearPress() {
    setState(() {
      sudoku.addedDigits![currentSelectedCell[0]][currentSelectedCell[1]] =
          sudoku.originalSudoku[currentSelectedCell[0]][currentSelectedCell[1]];
    });
  }

  void clearSudoku() {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        setState(() {
          sudoku.addedDigits![i][j] = sudoku.originalSudoku[i][j];
        });
      }
    }
  }

  void solveSudoku() {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return SudokuAnswer(
        sudoku: sudoku,
      );
    }));
  }

  showSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sudoku Saved successfully.'),behavior: SnackBarBehavior.floating,duration: Duration(seconds: 1),),
    );
  }

  void saveSudoku() async {
    await StorageHelper.updateSudoku(sudoku, widget.index);
    showSnackBar();
  }

  void shareSudokuAsImage() async {
    final tempDir = await getTemporaryDirectory();
    final imageBytes = await controller.capture();

    await File('${tempDir.path}/SudokuImage.png')
        .writeAsBytes(imageBytes!.toList());

    await Share.shareFiles(['${tempDir.path}/SudokuImage.png'],
        text: 'SudokuImage');
  }

  void goToHome() {
    Navigator.pop(context);
  }

  void deleteAndPop() async {
    await StorageHelper.deleteSudokuById(widget.index);
    goToHome();
  }

  bool checkAllDigitsAddedHome(addedDigits) {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (addedDigits[i][j] == 0) {
          return false;
        }
      }
    }
    return true;
  }
  checkAnswerPress(){
    if(checkAllDigitsAddedHome(sudoku.addedDigits)){
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) {
            return SudokuAnswerChecker(
              sudoku: sudoku,
            );
          }));
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the digits.'),behavior: SnackBarBehavior.floating,duration: Duration(seconds: 1),),
      );
    }
  }

  Widget sudokuWidget() {
    return SizedBox(
      width: 350.0,
      height: 350.0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _colorScheme.background,
        ),
        child: CustomPaint(
        painter: LinesPainter(_colorScheme),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 9,
          ),
          itemCount:
              sudoku.originalSudoku.length * sudoku.originalSudoku[0].length,
          itemBuilder: (context, index) {
            int row = index ~/ 9;
            int col = index % 9;
            int originalCellValue = sudoku.originalSudoku[row][col];
            int addedDigitsCellValue = sudoku.addedDigits![row][col];

            return SudokuCell(
              originalValue: originalCellValue,
              addedDigitsValue: addedDigitsCellValue,
              colorScheme: _colorScheme,
              isSelected: (currentSelectedCell[0] == row &&
                  currentSelectedCell[1] == col),
              onTap: () {
                setState(() {
                  currentSelectedCell[0] = row;
                  currentSelectedCell[1] = col;
                });
              },
            );
          },
        ),
      ),
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "PuzzlePro",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30.0,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "share") {
                shareSudokuAsImage();
              } else if (value == "delete") {
                deleteAndPop();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: "share",
                  child: Text("Share"),
                ),
                const PopupMenuItem<String>(
                  value: "delete",
                  child: Text("Delete"),
                ),
              ];
            },
          ),
        ],
      ),
      body: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    "Some details here",
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
                ElevatedButton(
                  onPressed: checkAnswerPress,
                  child: Text(
                    "Check Answer",
                    style: TextStyle(color: _colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
          WidgetsToImage(
            controller: controller,
            child: sudokuWidget(),
          ),
          const SizedBox(
            height: 20.0,
          ),
          DigitRow1(
              colorScheme: _colorScheme,
              onPressed: (digit) => {setAddedDigit(digit)}),
          const SizedBox(
            height: 8.0,
          ),
          DigitRow2(
            colorScheme: _colorScheme,
            onPressed: (digit) => {setAddedDigit(digit)},
            onClearPressed: () => {onClearPress()},
          ),
          const SizedBox(
            height: 20.0,
          ),
          // Bottom buttons
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: saveSudoku,
                    child: const Icon(Icons.save_as_rounded),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      clearSudoku();
                    },
                    child: const Icon(Icons.restart_alt_rounded),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      solveSudoku();
                    },
                    child: const Icon(Icons.calculate_rounded),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return SudokuValidator(
                          sudoku: sudoku,
                        );
                      }));
                    },
                    child: const Icon(Icons.lightbulb_outline_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }
}

class SudokuCell extends StatelessWidget {
  final ColorScheme colorScheme;
  final int originalValue;
  final int addedDigitsValue;
  final Function() onTap;
  final bool isSelected;

  const SudokuCell({
    super.key,
    required this.originalValue,
    required this.addedDigitsValue,
    required this.colorScheme,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            border: isSelected
                ? Border.all(color: colorScheme.primary, width: 2.0)
                : Border.all(color: Colors.transparent),
            color: originalValue != 0
                ? Colors.transparent
                : addedDigitsValue != 0
                    ? colorScheme.error.withOpacity(0.05)
                    : colorScheme.primary.withOpacity(0.05)),
        child: Center(
          child: Text(
            originalValue != 0
                ? '$originalValue'
                : addedDigitsValue != 0
                    ? '$addedDigitsValue'
                    : '',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: originalValue != 0
                  ? colorScheme.secondary
                  : colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class LinesPainter extends CustomPainter {
  final ColorScheme colorScheme;

  LinesPainter(this.colorScheme);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = colorScheme.primary
      ..strokeWidth = 0.25;
    final Paint paintBold = Paint()
      ..color = colorScheme.primary
      ..strokeWidth = 2.0;

    double x = size.width / 9.0;
    double spaceX = x;

    for (int i = 1; i < 9; i++) {
      if (i % 3 == 0) {
        canvas.drawLine(
            Offset(x - 1, 0), Offset(x - 1, size.height), paintBold);
      } else {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }
      x += spaceX;
    }

    double y = size.height / 9.0;
    double spaceY = y;

    for (int i = 1; i < 9; i++) {
      if (i % 3 == 0) {
        canvas.drawLine(Offset(0, y - 1), Offset(size.width, y - 1), paintBold);
      } else {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
      y += spaceY;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class DigitRow1 extends StatelessWidget {
  final ColorScheme colorScheme;
  final void Function(int digit) onPressed;
  static const List<int> digits = [1, 2, 3, 4, 5];

  const DigitRow1(
      {super.key, required this.colorScheme, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int digit in digits)
          InputButton(
              colorScheme: colorScheme,
              onPressed: () => onPressed(digit),
              child: Text("$digit")),
      ],
    );
  }
}

class DigitRow2 extends StatelessWidget {
  final ColorScheme colorScheme;
  final void Function(int digit) onPressed;
  static const List<int> digits = [6, 7, 8, 9];
  final void Function() onClearPressed;

  const DigitRow2(
      {super.key,
      required this.colorScheme,
      required this.onPressed,
      required this.onClearPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int digit in digits)
          InputButton(
              colorScheme: colorScheme,
              onPressed: () => onPressed(digit),
              child: Text("$digit")),
        InputButton(
            colorScheme: colorScheme,
            onPressed: onClearPressed,
            child: const Icon(Icons.backspace_rounded))
      ],
    );
  }
}

class InputButton extends StatelessWidget {
  final ColorScheme colorScheme;
  final Widget child;
  final void Function() onPressed;

  const InputButton({
    super.key,
    required this.colorScheme,
    required this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SizedBox(
          width: 100.0,
          height: 50.0,
          child: ElevatedButton(
            style: ButtonStyle(
              textStyle: MaterialStateProperty.all(
                const TextStyle(
                    fontSize: 25.0,
                    fontFamily: "Rubik",
                    fontWeight: FontWeight.w700),
              ),
            ),
            onPressed: () {
              onPressed();
            },
            child: child,
          ),
        ),
      ),
    );
  }
}
