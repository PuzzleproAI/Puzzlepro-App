import 'package:flutter/material.dart';
import 'package:puzzlepro_app/Widgets/sudoku_widget.dart';
import 'package:puzzlepro_app/models/sudoku.dart';
import 'package:puzzlepro_app/pages/sudoku_home.dart';

enum ItemFilter { all, incomplete, completed }

class SudokuListView extends StatefulWidget {
  final Function() getIsLoaded;
  final Map<dynamic, Sudoku> sudokuList;
  final Function(int) onDelete;
  final Future<void> Function() onRefresh;

  const SudokuListView({
    super.key,
    required this.sudokuList,
    required this.onDelete,
    required this.onRefresh,
    required this.getIsLoaded,
  });

  @override
  State<SudokuListView> createState() => _SudokuListViewState();
}

class _SudokuListViewState extends State<SudokuListView> {
  ItemFilter currentFilter = ItemFilter.all;
  bool isLoaded = true;

  Map<dynamic, Sudoku> getFilteredItems() {
    setState(() {
      isLoaded = false;
    });
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

  Route _sudokuHomeRoute(int key) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SudokuHome(
        index: key,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

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
            child: RefreshIndicator(
              onRefresh: widget.onRefresh,
              child: getFilteredItems().isNotEmpty && widget.getIsLoaded()
                  ? ListView(
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
                                sudoku:
                                    getFilteredItems()[key] ?? Sudoku.empty(),
                                listIndex: index,
                                onSelected: () => {
                                  Navigator.push(context, _sudokuHomeRoute(key))
                                      .then((value) => {widget.onRefresh()})
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
                    )
                  : widget.getIsLoaded()
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  size: 80.0,
                                ),
                                SizedBox(height: 16.0),
                                Text(
                                  'No sudoku to display',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  'Your collection is empty. Add some sudoku to get started.',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : const Center(),
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
