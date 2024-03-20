import 'package:flutter/material.dart';
import 'package:puzzlepro_app/Data/constants.dart';

class ThemeDataModel with ChangeNotifier {
  int themeValue;

  ColorSeed colorSelected;

  void setTheme(int themeValue) {
    this.themeValue = themeValue;
    notifyListeners();
  }

  void setColorScheme(ColorSeed colorSelected) {
    this.colorSelected = colorSelected;
    notifyListeners();
  }

  getTheme(){
    switch (themeValue) {
      case 0:
          return ThemeMode.system;
      case 1:
          return ThemeMode.light;
      case 2:
          return ThemeMode.dark;
    }
  }

  getColorScheme(){
    return colorSelected;
  }

  ThemeDataModel()
      : themeValue = 0,
        colorSelected = ColorSeed.teal;

  ThemeDataModel.create(
      this.themeValue, this.colorSelected);
}
