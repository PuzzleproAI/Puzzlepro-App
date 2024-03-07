import 'package:flutter/material.dart';
import '../models/sudoku.dart';

const hardnessLevels = ["easy", "medium", "hard", "very hard"];

class SudokuWidget extends StatefulWidget {
  const SudokuWidget({
    super.key,
    required this.sudoku,
    this.onSelected,
    required this.listIndex,
    required this.onDelete,
  });

  final void Function()? onSelected;
  final Sudoku sudoku;
  final int listIndex;
  final Function() onDelete;

  @override
  State<SudokuWidget> createState() => _SudokuWidgetState();
}

class _SudokuWidgetState extends State<SudokuWidget> {
  late final ColorScheme _colorScheme = Theme.of(context).colorScheme;
  late Color unselectedColor = Color.alphaBlend(
    _colorScheme.primary.withOpacity(0.08),
    _colorScheme.surface,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onSelected,
      child: Card(
        elevation: 0,
        color: unselectedColor,
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SudokuHeadline(
              sudoku: widget.sudoku,
              index: widget.listIndex,
              onDelete: widget.onDelete,
            ),
            SudokuContent(
              sudoku: widget.sudoku,
            ),
          ],
        ),
      ),
    );
  }
}

class SudokuContent extends StatefulWidget {
  const SudokuContent({
    super.key,
    required this.sudoku,
  });

  final Sudoku sudoku;

  @override
  State<SudokuContent> createState() => _SudokuContentState();
}

class _SudokuContentState extends State<SudokuContent> {
  late final ColorScheme _colorScheme = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  Widget get contentSpacer => const SizedBox(
        height: 2,
      );

  TextStyle? get contentTextStyle {
    return _textTheme.bodyMedium
        ?.copyWith(color: _colorScheme.onSurfaceVariant);
  }

  String timeAgoSinceDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${_pluralize(minutes, "minute")} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${_pluralize(hours, "hour")} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${_pluralize(days, "day")} ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _pluralize(int count, String unit) {
    return count == 1 ? unit : '${unit}s';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.sudoku.isScanned
                    ? "Added by scanning"
                    : "Added by generating",
                style: contentTextStyle,
              ),
              Text(
                "Last viewed ${timeAgoSinceDate(widget.sudoku.lastViewed)}",
                style: contentTextStyle,
              ),
              contentSpacer,
              Text(
                "Created ${timeAgoSinceDate(widget.sudoku.createdAt!)}",
                overflow: TextOverflow.ellipsis,
                style: contentTextStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SudokuHeadline extends StatefulWidget {
  const SudokuHeadline({
    super.key,
    required this.sudoku,
    required this.index,
    required this.onDelete,
  });

  final Sudoku sudoku;
  final Function() onDelete;
  final int index;

  @override
  State<SudokuHeadline> createState() => _SudokuHeadlineState();
}

class _SudokuHeadlineState extends State<SudokuHeadline> {
  late final ColorScheme _colorScheme = Theme.of(context).colorScheme;

  Widget getStatusIcon() {
    return widget.sudoku.isComplete
        ? const Icon(Icons.check_circle_rounded)
        : const Icon(Icons.access_time_rounded);
  }

  getSudokuStatus() {
    int total = 0, remaining = 0;
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (widget.sudoku.originalSudoku[i][j] == 0) {
          total++;
          if (widget.sudoku.addedDigits![i][j] == 0) {
            remaining++;
          }
        }
      }
    }
    if (total == 0) {
      return "100";
    }
    return ((total - remaining) * 100) ~/ total;
  }

  Color _getHighPitchColorForDifficulty(String difficulty) {
    if (hardnessLevels.contains(difficulty.toLowerCase())) {
      switch (difficulty.toLowerCase()) {
        case 'easy':
          return Colors.green.withOpacity(0.8);
        case 'medium':
          return Colors.blue.withOpacity(0.8);
        case 'hard':
          return Colors.orange.withOpacity(0.8);
        case 'very hard':
          return Colors.red.withOpacity(0.8);
        default:
          return Colors.black.withOpacity(0.8);
      }
    } else {
      return Colors.black.withOpacity(0.8);
    }
  }

  Color _getLowPitchColorForDifficulty(String difficulty) {
    if (hardnessLevels.contains(difficulty.toLowerCase())) {
      switch (difficulty.toLowerCase()) {
        case 'easy':
          return Colors.green.withOpacity(0.1);
        case 'medium':
          return Colors.blue.withOpacity(0.1);
        case 'hard':
          return Colors.orange.withOpacity(0.1);
        case 'very hard':
          return Colors.red.withOpacity(0.1);
        default:
          return Colors.black.withOpacity(0.1);
      }
    } else {
      return Colors.black.withOpacity(0.1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        height: 60,
        color: Color.alphaBlend(
          _colorScheme.primary.withOpacity(0.05),
          _colorScheme.surface,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 12, 12),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "${getSudokuStatus()}% Completed",
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: _colorScheme.primary),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        widget.sudoku.difficulty != "NA"
                            ? Container(
                                padding: const EdgeInsets.fromLTRB(4, 3, 4, 3),
                                decoration: BoxDecoration(
                                  color: _getLowPitchColorForDifficulty(
                                      widget.sudoku.difficulty),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _getHighPitchColorForDifficulty(
                                        widget.sudoku.difficulty),
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  widget.sudoku.difficulty.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _getHighPitchColorForDifficulty(
                                        widget.sudoku.difficulty),
                                  ),
                                ),
                              )
                            : const SizedBox(
                                width: 10,
                              ),
                      ],
                    )
                  ],
                ),
              ),
              if (constraints.maxWidth - 200 > 0) ...[
                SizedBox(
                  height: 40,
                  width: 40,
                  child: FloatingActionButton(
                    heroTag: "DeleteButton${widget.index}",
                    onPressed: widget.onDelete,
                    elevation: 0,
                    backgroundColor: _colorScheme.surface,
                    child: const Icon(Icons.delete_outline),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(right: 8.0)),
                SizedBox(
                  height: 40,
                  width: 40,
                  child: FloatingActionButton(
                    heroTag: "StatusIcon${widget.index}",
                    onPressed: () {},
                    elevation: 0,
                    backgroundColor: _colorScheme.surface,
                    child: getStatusIcon(),
                  ),
                ),
              ]
            ],
          ),
        ),
      );
    });
  }
}
