class StatisticData {
  final int generatedSudokuCount;
  final int totalSudoku;
  final int pendingSudoku;
  final int totalSudokuSolvedByApp;

  const StatisticData.all(this.generatedSudokuCount, this.totalSudoku,
      this.pendingSudoku, this.totalSudokuSolvedByApp);
}
