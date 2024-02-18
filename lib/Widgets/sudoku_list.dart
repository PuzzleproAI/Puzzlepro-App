import 'package:flutter/material.dart';
import 'package:puzzlepro_app/Widgets/sudoku_widget.dart';
import 'package:puzzlepro_app/models/sudoku.dart';
import 'package:puzzlepro_app/pages/sudoku_home.dart';

enum ItemFilter { all, incomplete, completed }

class SudokuListView extends StatefulWidget {
  final Map<dynamic, Sudoku> sudokuList;
  final Function(int) onDelete;

  const SudokuListView({
    super.key,
    required this.sudokuList,
    required this.onDelete,
  });

  @override
  State<SudokuListView> createState() => _SudokuListViewState();
}

class _SudokuListViewState extends State<SudokuListView> {
  ItemFilter currentFilter = ItemFilter.all;

  Map<dynamic, Sudoku> getFilteredItems() {
    switch (currentFilter) {
      case ItemFilter.all:
        return widget.sudokuList;
      case ItemFilter.incomplete:
        return Map.from(widget.sudokuList)
          ..removeWhere((k, v) => v.isComplete == true);
      case ItemFilter.completed:
        return Map.from(widget.sudokuList)
          ..removeWhere((k, v) => v.isComplete == false);
      default:
        return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.background,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilterButton(
                filter: ItemFilter.all,
                text: 'All',
                onPressed: () {
                  setState(() {
                    currentFilter = ItemFilter.all;
                  });
                },
                isSelected: currentFilter == ItemFilter.all,
              ),
              FilterButton(
                filter: ItemFilter.incomplete,
                text: 'Incomplete',
                onPressed: () {
                  setState(() {
                    currentFilter = ItemFilter.incomplete;
                  });
                },
                isSelected: currentFilter == ItemFilter.incomplete,
              ),
              FilterButton(
                filter: ItemFilter.completed,
                text: 'Completed',
                onPressed: () {
                  setState(() {
                    currentFilter = ItemFilter.completed;
                  });
                },
                isSelected: currentFilter == ItemFilter.completed,
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListView(
              children: [
                const SizedBox(height: 8),
                const SizedBox(height: 8),
                ...List.generate(
                  getFilteredItems().length,
                  (index) {
                    int key = getFilteredItems().keys.elementAt(index);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: SudokuWidget(
                        sudoku: getFilteredItems()[key] ?? Sudoku.empty(),
                        listIndex: index,
                        onSelected: () => {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (BuildContext context) {
                            return SudokuHome(
                              index: key,
                            );
                          }))
                        },
                        key: widget.key,
                        onDelete: () => {
                          widget.onDelete(key),
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class FilterButton extends StatelessWidget {
  final ItemFilter filter;
  final String text;
  final VoidCallback onPressed;
  final bool isSelected;

  const FilterButton({
    required this.filter,
    required this.text,
    required this.onPressed,
    required this.isSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return isSelected
        ? FilledButton(
            onPressed: onPressed,
            child: Text(
              text,
            ),
          )
        : ElevatedButton(
            onPressed: onPressed,
            child: Text(
              text,
            ),
          );
  }
}
