import 'package:hive_flutter/hive_flutter.dart';
import 'package:puzzlepro_app/models/statistics.dart';
import 'package:puzzlepro_app/models/sudoku.dart';

class StorageHelper {
  static const String sudokuBoxName = 'sudokuBox';
  static Box<Sudoku>? sudokuBox;

  static Future<void> initializeHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(SudokuAdapter());
    sudokuBox = await Hive.openBox<Sudoku>(sudokuBoxName);
  }

  static bool checkCompleted(Sudoku sudoku) {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (sudoku.addedDigits![i][j] == 0) {
          return false;
        }
      }
    }
    return true;
  }

  static Future<int> saveSudoku(Sudoku sudoku) async {
    if (sudokuBox == null) {
      initializeHive();
    }
    if (sudokuBox!.isOpen == true) {
      final box = await Hive.openBox<Sudoku>(sudokuBoxName);
      return await box.add(sudoku);
    }
    return 0;
  }

  static Future<void> updateSudoku(Sudoku sudoku, dynamic index) async {
    if (sudokuBox == null) {
      initializeHive();
    }
    if (sudokuBox!.isOpen == true) {
      if (checkCompleted(sudoku)) {
        sudoku.isComplete = true;
      }
      final box = await Hive.openBox<Sudoku>(sudokuBoxName);
      await box.put(index, sudoku);
    }
  }

  static Future<Sudoku?> getSudokuByIndex(dynamic index) async {
    if (sudokuBox == null) {
      initializeHive();
    }
    if (sudokuBox!.isOpen == true) {
      final box = await Hive.openBox<Sudoku>(sudokuBoxName);
      var sudoku = box.get(index)!.copy();
      sudoku.lastViewed = DateTime.now();
      await updateSudoku(sudoku, index);
      return sudoku.copy();
    }
    return null;
  }

  static Future<Map<dynamic, Sudoku>> loadAllSudoku() async {
    if (sudokuBox == null) {
      initializeHive();
    }
    if (sudokuBox!.isOpen == true) {
      final box = await Hive.openBox<Sudoku>(sudokuBoxName);
      return box.toMap();
    }
    return {};
  }

  static Future<void> deleteSudokuById(dynamic index) async {
    if (sudokuBox == null) {
      initializeHive();
    }
    if (sudokuBox!.isOpen == true) {
      final box = await Hive.openBox<Sudoku>(sudokuBoxName);
      await box.delete(index);
    }
  }

  static Future<StatisticData?> loadStatistics() async {
    if (sudokuBox == null) {
      initializeHive();
    }

    if (sudokuBox!.isOpen == true) {
      final Box<Sudoku> box = await Hive.openBox<Sudoku>(sudokuBoxName);
      var totalSudoku = box.length;

      var generatedSudokuCount =
          box.values.where((sudoku) => sudoku.isScanned == false).length;

      var totalSudokuSolvedByApp = 0; // not implemented for now..

      var pendingSudoku =
          box.values.where((sudoku) => sudoku.isComplete == false).length;
      StatisticData statisticData = StatisticData.all(generatedSudokuCount,
          totalSudoku, pendingSudoku, totalSudokuSolvedByApp);
      return statisticData;
    }
    return null;
  }

  static Future<void> deleteAllData() async {
    if (sudokuBox == null) {
      initializeHive();
    }

    if (sudokuBox!.isOpen == true) {
      final Box<Sudoku> box = await Hive.openBox<Sudoku>(sudokuBoxName);
      await box.clear();
    }
  }
}
