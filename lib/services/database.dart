import 'package:hive_flutter/hive_flutter.dart';
import 'package:puzzlepro_app/models/sudoku.dart';

class StorageHelper {
  static const String sudokuBoxName = 'sudokuBox';
  static Box<Sudoku>? sudokuBox;
  static int generatedSudokusCount =0;
  static int scannedSudokusCount =0;
  static int totalSudokus = 0;
  static int pendingSudokus =0;

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

  static Future<void> loadStatistics() async{
    if (sudokuBox == null) {
      initializeHive();
    }

    if (sudokuBox!.isOpen == true) {
      final Box<Sudoku> box = await Hive.openBox<Sudoku>(sudokuBoxName);
      totalSudokus = box.length;

      scannedSudokusCount =
          box.values.where((sudoku) => sudoku.isScanned).length;

      generatedSudokusCount =
         totalSudokus -
          box.values.where((sudoku) => sudoku.isScanned).length;
    }
  }

  static Future<void> DeleteAllData()async {
    if (sudokuBox == null) {
      initializeHive();
    }

    if (sudokuBox!.isOpen == true) {
      final Box<Sudoku> box = await Hive.openBox<Sudoku>(sudokuBoxName);
      await box.clear();
    }
  }

}
