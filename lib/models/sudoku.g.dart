// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sudoku.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SudokuAdapter extends TypeAdapter<Sudoku> {
  @override
  final int typeId = 2;

  @override
  Sudoku read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Sudoku(
      (fields[0] as List).map((dynamic e) => (e as List).cast<int>()).toList(),
      fields[5] as bool,
      fields[6] as String,
    )
      ..createdAt = fields[1] as DateTime?
      ..addedDigits = (fields[2] as List?)
          ?.map((dynamic e) => (e as List).cast<int>())
          ?.toList()
      ..lastViewed = fields[3] as DateTime
      ..isComplete = fields[4] as bool
      ..finalAnswer = (fields[7] as List?)
          ?.map((dynamic e) => (e as List).cast<int>())
          ?.toList()
      ..isGeneratedByApp = fields[8] as bool;
  }

  @override
  void write(BinaryWriter writer, Sudoku obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.originalSudoku)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.addedDigits)
      ..writeByte(3)
      ..write(obj.lastViewed)
      ..writeByte(4)
      ..write(obj.isComplete)
      ..writeByte(5)
      ..write(obj.isScanned)
      ..writeByte(6)
      ..write(obj.difficulty)
      ..writeByte(7)
      ..write(obj.finalAnswer)
      ..writeByte(8)
      ..write(obj.isGeneratedByApp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SudokuAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
