import 'package:flutter/material.dart';
const double narrowScreenWidthThreshold = 450;
const double mediumWidthBreakpoint = 1000;
const double largeWidthBreakpoint = 1500;
const double transitionLength = 500;

enum ColorSeed {
  indigo('Indigo', Colors.indigo),
  blue('Blue', Colors.blue),
  teal('Teal', Colors.teal),
  green('Green', Colors.green),
  yellow('Yellow', Colors.yellow),
  orange('Orange', Colors.orange),
  deepOrange('Deep Orange', Colors.deepOrange),
  pink('Pink', Colors.pink),
  blueGray('BlueGray', Colors.blueGrey);

  const ColorSeed(this.label, this.color);
  final String label;
  final Color color;
}

enum ScreenSelected {
  home(0),
  scanner(1),
  generator(2),
  setting(3);

  const ScreenSelected(this.value);
  final int value;
}
