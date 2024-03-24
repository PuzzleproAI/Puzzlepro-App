import 'package:flutter/material.dart';
import 'package:puzzlepro_app/Widgets/sudoku_list.dart';
import 'package:puzzlepro_app/models/sudoku.dart';
import 'package:puzzlepro_app/services/database.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,

    required this.useMaterial3,
  });


  final bool useMaterial3;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  bool isLoaded = false;
  @override
  void initState() {
    super.initState();
    fetchSudokuList();
  }

  void deleteSudoku(int index) async {
    StorageHelper.deleteSudokuById(index);
    await fetchSudokuList();
  }

  fetchSudokuList() async {
    setState(() {
      isLoaded = false;
    });
    var list = await StorageHelper.loadAllSudoku();
    setState(() {
      sudokuList = list;
      isLoaded = true;
    });
  }
  getIsLoaded(){
    return isLoaded;
  }

  Future<void> onRefresh() async {
    await fetchSudokuList();
    await Future.delayed(const Duration(seconds: 1));
  }

  Map<dynamic, Sudoku> sudokuList = {};

  @override
  Widget build(BuildContext context) {
    return SudokuListView(
        sudokuList: sudokuList, onDelete: deleteSudoku, onRefresh: onRefresh, getIsLoaded: getIsLoaded,);
  }
}
