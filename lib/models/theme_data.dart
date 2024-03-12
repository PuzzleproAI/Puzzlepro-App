import 'package:flutter/material.dart';
import 'package:puzzlepro_app/Data/constants.dart';

class ThemeDataModel with ChangeNotifier {
  int isLightTheme;

  ColorSeed colorSelected;

  bool isAutoTheme;
  void setTheme(bool isLightTheme) {
    isLightTheme = isLightTheme;
    notifyListeners();
  }

  void setColorScheme(bool isAuto, ColorSeed colorSelected) {
    isAutoTheme = isAuto;
    if (!isAuto) {
      this.colorSelected = colorSelected;
    }
    notifyListeners();
  }

  ThemeDataModel()
      : isLightTheme = 0,
        colorSelected = ColorSeed.teal,
        isAutoTheme = false;

  ThemeDataModel.create(
      this.isLightTheme, this.colorSelected, this.isAutoTheme);
}
