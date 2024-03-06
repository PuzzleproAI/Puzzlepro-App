import 'package:flutter/material.dart';
import '../models/sudoku.dart';

class Tuple2<A, B> {
  final A item1;
  final B item2;

  Tuple2(this.item1, this.item2);
}

List<int> digits = List.generate(9, (index) => index + 1);

class SudokuAnswer extends StatefulWidget {
  final Sudoku sudoku;

  const SudokuAnswer({super.key, required this.sudoku});

  @override
  State<SudokuAnswer> createState() => _SudokuAnswerState();
}

class _SudokuAnswerState extends State<SudokuAnswer> {
  late final ColorScheme _colorScheme = Theme.of(context).colorScheme;
  final List<int> currentSelectedCell = [10, 10];
  String buttonText = "Solve Now";

  List<List<int>> originalSudoku =
      List.generate(9, (row) => List.generate(9, (col) => 0));
  List<List<int>> addedDigitsSudoku =
      List.generate(9, (row) => List.generate(9, (col) => 0));

  List<List<int>> unitList = List.generate(27, (index) {
    if (index < 9) {
      return List.generate(9, (i) => index * 9 + i);
    } else if (index < 18) {
      return List.generate(9, (i) => i * 9 + index - 9);
    } else {
      final startRow = (index - 18) ~/ 3 * 3;
      final startCol = (index - 18) % 3 * 3;
      return List.generate(
          9, (i) => (startRow + i ~/ 3) * 9 + startCol + i % 3);
    }
  });

  Tuple2<bool, List<List<int>>> solve(List<List<int>> values) {
    bool isValid(int row, int col, int num) {
      for (var i = 0; i < 9; i++) {
        if (values[row][i] == num || values[i][col] == num) {
          return false;
        }
      }

      int subgridRow = row - row % 3;
      int subgridCol = col - col % 3;
      for (var i = 0; i < 3; i++) {
        for (var j = 0; j < 3; j++) {
          if (values[subgridRow + i][subgridCol + j] == num) {
            return false;
          }
        }
      }

      return true;
    }

    Tuple2<bool, List<List<int>>> solveHelper(int row, int col) {
      if (row == 9) {
        return Tuple2(true, values);
      }
      int nextRow = (col == 8) ? row + 1 : row;
      int nextCol = (col == 8) ? 0 : col + 1;

      if (values[row][col] != 0) {
        return solveHelper(nextRow, nextCol);
      }
      for (var num in digits) {
        if (isValid(row, col, num)) {
          values[row][col] = num;
          var result = solveHelper(nextRow, nextCol);
          if (result.item1) {
            return result;
          }
          values[row][col] = 0;
        }
      }
      return Tuple2(false, values);
    }

    return solveHelper(0, 0);
  }

  Tuple2<bool, List<List<int>>> solveAll(List<List<int>> grids) {
    final result = solve(grids);
    return Tuple2(true, result.item2);
  }

  void generateAnswer() {
    setState(() {
      if (widget.sudoku.finalAnswer != null) {
        addedDigitsSudoku = widget.sudoku.finalAnswer!;
      } else {
        final answer = solveAll(originalSudoku);
        addedDigitsSudoku = answer.item2;
        widget.sudoku.finalAnswer = answer.item2;
      }
      buttonText = "Solved";
    });
  }

  @override
  Widget build(BuildContext context) {
    var temp = widget.sudoku.copy();
    originalSudoku = temp.originalSudoku;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Solution",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30.0,
          ),
        ),
      ),
      body: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 100.0),
          SizedBox(
            width: 350.0,
            height: 350.0,
            child: CustomPaint(
              painter: LinesPainter(_colorScheme),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 9,
                ),
                itemCount: originalSudoku.length * originalSudoku[0].length,
                itemBuilder: (context, index) {
                  int row = index ~/ 9;
                  int col = index % 9;
                  int originalCellValue = originalSudoku[row][col];
                  int addedDigitsCellValue = addedDigitsSudoku[row][col];

                  return SudokuCell(
                    originalValue: originalCellValue,
                    addedDigitsValue: addedDigitsCellValue,
                    colorScheme: _colorScheme,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 30.0),
          SizedBox(
            width: 400,
            height: 70,
            child: ElevatedButton(
              onPressed: generateAnswer,
              child: Text(
                buttonText,
                style: const TextStyle(fontSize: 30.0),
              ),
            ),
          )
        ],
      )),
    );
  }
}

class SudokuCell extends StatelessWidget {
  final ColorScheme colorScheme;
  final int originalValue;
  final int addedDigitsValue;

  const SudokuCell({
    super.key,
    required this.originalValue,
    required this.addedDigitsValue,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: originalValue != 0
              ? Colors.transparent
              : colorScheme.primary.withOpacity(0.05)),
      child: Center(
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
