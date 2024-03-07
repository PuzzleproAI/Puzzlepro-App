import 'package:flutter/material.dart';
import 'package:puzzlepro_app/Data/constants.dart';
import 'package:puzzlepro_app/pages/home.dart';
import 'package:puzzlepro_app/pages/scan_sudoku.dart';
import 'package:puzzlepro_app/pages/generate_sudoku.dart';
import 'package:puzzlepro_app/services/database.dart';
import 'package:puzzlepro_app/pages/settings.dart';
import 'package:puzzlepro_app/services/database.dart';

void main() async {
  await StorageHelper.initializeHive();
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int screenIndex = ScreenSelected.home.value;
  bool controllerInitialized = false;
  bool showMediumSizeLayout = false;
  bool showLargeSizeLayout = false;
  List<String> titleList = ["PuzzlePro", "Scan", "Generator", "Settings"];
  String title = "PuzzlePro";

  bool useMaterial3 = true;
  ThemeMode themeMode = ThemeMode.dark;
  ColorSeed colorSelected = ColorSeed.teal;
  ColorScheme? colorScheme = const ColorScheme.highContrastDark();
  
  bool useLightMode(int theme) {
    switch (theme) {
      case 0:
        setState(() {
          themeMode = ThemeMode.system;
        });
        return View.of(context).platformDispatcher.platformBrightness ==
            Brightness.light;
      case 1:
        setState(() {
          themeMode = ThemeMode.light;
        });
        return true;
      case 2:
        setState(() {
          themeMode = ThemeMode.dark;
        });
        return false;
    }
    return false;
  }

  void handleBrightnessChange(bool useLightMode) {
    setState(() {
      themeMode = useLightMode ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void handleColorSelect(int value) {
    setState(() {
      colorSelected = ColorSeed.values[value];
    });
  }

  void handleScreenChange(int index, String message) {
    setState(() {
      screenIndex = index;
    });
    if (message != "") {
      //some logic to show snake-bar
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final double width = MediaQuery.of(context).size.width;
    if (width > mediumWidthBreakpoint) {
      if (width > largeWidthBreakpoint) {
        showMediumSizeLayout = false;
        showLargeSizeLayout = true;
      } else {
        showMediumSizeLayout = true;
        showLargeSizeLayout = false;
      }
    } else {
      showMediumSizeLayout = false;
      showLargeSizeLayout = false;
    }
  }

  Widget getScreen(ScreenSelected screenSelected) {
    switch (screenSelected) {
      case ScreenSelected.home:
        return Home(
          useMaterial3: useMaterial3,
          handleBrightnessChange: handleBrightnessChange,
          handleColorSelect: handleColorSelect,
        );
      case ScreenSelected.scanner:
        return const ImageProcessingPage();
      case ScreenSelected.generator:
        return SudokuGeneratorPage(
          handleScreenChange: handleScreenChange,
        );
      case ScreenSelected.setting:
        return SettingsPage(
          changeTheme: useLightMode,
        );
      //   return const SettingsPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    var bottomNavigationBarItems = const <Widget>[
      NavigationDestination(
        icon: Icon(Icons.home_rounded),
        label: 'Home',
      ),
      NavigationDestination(
        icon: Icon(Icons.qr_code_scanner_rounded),
        label: 'Scan',
      ),
      NavigationDestination(
        icon: Icon(Icons.add_box_rounded),
        label: 'Generate',
      ),
      NavigationDestination(
        icon: Icon(Icons.settings_rounded),
        label: 'Settings',
      ),
    ];
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: themeMode,
        theme: ThemeData(
            fontFamily: 'Rubik',
            colorSchemeSeed: colorSelected.color,
            useMaterial3: true,
            brightness: Brightness.light,
            appBarTheme: const AppBarTheme(
              surfaceTintColor: Colors.transparent,
            )),
        darkTheme: ThemeData(
            fontFamily: 'Rubik',
            colorSchemeSeed: colorSelected.color,
            useMaterial3: true,
            brightness: Brightness.dark,
            appBarTheme: const AppBarTheme(
              surfaceTintColor: Colors.transparent,
            )),
        home: Scaffold(
          appBar: AppBar(
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 27.0,
              ),
            ),
          ),
          // body: const SudokuHome(),
          body: getScreen(ScreenSelected.values[screenIndex]),
          // body: const ScanOptionsPage(),
          bottomNavigationBar: NavigationBar(
            onDestinationSelected: (int index) {
              setState(() {
                screenIndex = index;
                title = titleList[index];
              });
            },
            destinations: bottomNavigationBarItems,
            selectedIndex: screenIndex,
          ),
        ));
  }
}
