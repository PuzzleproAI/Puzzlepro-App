import 'package:hive/hive.dart';

part 'sudoku.g.dart';

@HiveType(typeId: 2)
class Sudoku {
  @HiveField(0)
  List<List<int>> originalSudoku;

  @HiveField(1)
  DateTime? createdAt;

  @HiveField(2)
  List<List<int>>? addedDigits;

  @HiveField(3)
  DateTime lastViewed;

  @HiveField(4)
  bool isComplete;

  @HiveField(5)
  bool isScanned;

  @HiveField(6)
  String difficulty;

  @HiveField(7)
  List<List<int>>? finalAnswer;

  int id = 0;

  Sudoku(this.originalSudoku, this.isScanned, this.difficulty)
      : createdAt = DateTime.now(),
        lastViewed = DateTime.now(),
        addedDigits = originalSudoku,
        isComplete = false;

  Sudoku.empty()
      : originalSudoku = [
          [5, 3, 0, 0, 7, 0, 0, 0, 0],
          [6, 0, 0, 1, 9, 5, 0, 0, 0],
          [0, 9, 8, 0, 0, 0, 0, 6, 0],
          [8, 0, 0, 0, 6, 0, 0, 0, 3],
          [4, 0, 0, 8, 0, 3, 0, 0, 1],
          [7, 0, 0, 0, 2, 0, 0, 0, 6],
          [0, 6, 0, 0, 0, 0, 2, 8, 0],
          [0, 0, 0, 4, 1, 9, 0, 0, 5],
          [0, 0, 0, 0, 8, 0, 0, 7, 9]
        ],
        addedDigits = [
          [5, 3, 0, 0, 7, 0, 0, 0, 0],
          [6, 0, 0, 1, 9, 5, 3, 5, 0],
          [0, 9, 8, 3, 0, 5, 0, 6, 5],
          [8, 0, 0, 0, 6, 0, 0, 0, 3],
          [4, 0, 0, 8, 0, 3, 0, 0, 1],
          [7, 0, 0, 0, 2, 0, 3, 5, 6],
          [0, 6, 2, 0, 0, 5, 2, 8, 0],
          [0, 0, 0, 4, 1, 9, 0, 5, 5],
          [0, 0, 0, 0, 8, 0, 0, 7, 9]
        ],
        isScanned = true,
        difficulty = "NA",
        createdAt = DateTime.now(),
        lastViewed = DateTime.now(),
        isComplete = false;

  Sudoku.correct()
      : originalSudoku = [
          [5, 3, 0, 0, 7, 0, 0, 0, 0],
          [6, 0, 0, 1, 9, 5, 0, 0, 0],
          [0, 9, 8, 0, 0, 0, 0, 6, 0],
          [8, 0, 0, 0, 6, 0, 0, 0, 3],
          [4, 0, 0, 8, 0, 3, 0, 0, 1],
          [7, 0, 0, 0, 2, 0, 0, 0, 6],
          [0, 6, 0, 0, 0, 0, 2, 8, 0],
          [0, 0, 0, 4, 1, 9, 0, 0, 5],
          [0, 0, 0, 0, 8, 0, 0, 7, 9]
        ],
        addedDigits = [
          [5, 3, 0, 0, 7, 0, 0, 0, 0],
          [6, 0, 0, 1, 9, 5, 0, 0, 0],
          [0, 9, 8, 0, 0, 0, 0, 6, 0],
          [8, 0, 0, 0, 6, 0, 0, 0, 3],
          [4, 0, 0, 8, 0, 3, 0, 0, 1],
          [7, 0, 0, 0, 2, 0, 0, 0, 6],
          [0, 6, 0, 0, 0, 0, 2, 8, 0],
          [0, 0, 0, 4, 1, 9, 0, 0, 5],
          [0, 0, 0, 0, 8, 0, 0, 7, 9]
        ],
        isScanned = true,
        difficulty = "NA",
        createdAt = DateTime.now(),
        lastViewed = DateTime.now(),
        isComplete = false;

  Sudoku.incorrect()
      : originalSudoku = [
    [5, 3, 0, 0, 7, 0, 0, 0, 0],
    [6, 0, 0, 1, 9, 5, 0, 0, 0],
    [0, 9, 8, 0, 0, 0, 0, 6, 0],
    [8, 0, 0, 0, 6, 3, 4, 0, 3],
    [4, 0, 0, 8, 0, 3, 0, 0, 1],
    [7, 0, 0, 0, 2, 0, 0, 0, 6],
    [0, 6, 0, 0, 0, 0, 2, 8, 0],
    [0, 0, 0, 4, 1, 9, 0, 0, 5],
    [0, 0, 0, 0, 8, 0, 0, 7, 9]
  ],
        addedDigits = [
          [5, 3, 0, 0, 7, 0, 0, 0, 0],
          [6, 0, 0, 1, 9, 5, 0, 0, 0],
          [0, 9, 8, 0, 0, 0, 0, 6, 0],
          [8, 0, 0, 0, 6, 0, 0, 0, 3],
          [4, 0, 0, 8, 0, 3, 0, 0, 1],
          [7, 0, 0, 0, 2, 0, 0, 0, 6],
          [0, 6, 0, 0, 0, 0, 2, 8, 0],
          [0, 0, 0, 4, 1, 9, 0, 0, 5],
          [0, 0, 0, 0, 8, 0, 0, 7, 9]
        ],
        isScanned = true,
        difficulty = "NA",
        createdAt = DateTime.now(),
        lastViewed = DateTime.now(),
        isComplete = false;

  Sudoku copy() {
    return Sudoku(
      List.generate(9, (i) => List<int>.from(originalSudoku[i])),
      isScanned,
      difficulty,
    )
      ..createdAt = createdAt
      ..lastViewed = lastViewed
      ..addedDigits = addedDigits != null
          ? List.generate(9, (i) => List<int>.from(addedDigits![i]))
          : null
      ..isComplete = isComplete
      ..finalAnswer = finalAnswer != null
          ? List.generate(9, (i) => List<int>.from(finalAnswer![i]))
          : null;
  }

  @override
  String toString(){
    return originalSudoku.toString() + addedDigits.toString();
  }
}
