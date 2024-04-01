import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:puzzlepro_app/Data/constants.dart';
import 'package:puzzlepro_app/models/theme_data.dart';
import 'package:puzzlepro_app/pages/home.dart';
import 'package:puzzlepro_app/pages/scan_sudoku.dart';
import 'package:puzzlepro_app/pages/generate_sudoku.dart';
import 'package:puzzlepro_app/services/database.dart';
import 'package:puzzlepro_app/pages/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

setThemeFromStorage() async {
  var themeModel = ThemeDataModel();
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  int isLightMode = sharedPreferences.getInt('isLightMode') ?? 2;
  themeModel.setTheme(isLightMode);
  ColorSeed colorSeed =
      ColorSeed.values[sharedPreferences.getInt('colorSeed') ?? 2];
  themeModel.setColorScheme(colorSeed);
  return themeModel;
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await StorageHelper.initializeHive();
  var themeModeValues = await setThemeFromStorage();
  runApp(ChangeNotifierProvider(
      create: (context) => ThemeDataModel(),
      child: App(
        themeValues: themeModeValues,
      )));
}

class App extends StatefulWidget {
  final ThemeDataModel themeValues;

  const App({super.key, required this.themeValues});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int screenIndex = ScreenSelected.scanner.value;
  bool controllerInitialized = false;
  bool showMediumSizeLayout = false;
  bool showLargeSizeLayout = false;
  List<String> titleList = ["PuzzlePro", "Scan", "Generator", "Settings"];
  String title = "PuzzlePro";
  bool useMaterial3 = true;
  ThemeMode themeMode = ThemeMode.dark;
  ColorSeed colorSelected = ColorSeed.teal;
  ThemeDataModel? themeDataModel;
  bool isLoaded = false;

  @override
  void initState() {
    setState(() {
      themeDataModel = widget.themeValues;
      themeMode = widget.themeValues.getTheme();
      colorSelected = widget.themeValues.colorSelected;
    });
    FlutterNativeSplash.remove();
    super.initState();
  }

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

  void changeColorScheme(ColorSeed colorSeed) {
    setState(() {
      colorSelected = colorSeed;
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

  setThemeValues(ThemeDataModel themeDataModel) {
    useLightMode(themeDataModel.themeValue);
    changeColorScheme(themeDataModel.colorSelected);
  }

  Widget getScreen(ScreenSelected screenSelected) {
    switch (screenSelected) {
      case ScreenSelected.home:
        return Home(
          useMaterial3: useMaterial3,
        );
      case ScreenSelected.scanner:
        return ImageProcessingPage(
          handleScreenChange: handleScreenChange,
        );
      case ScreenSelected.generator:
        return PopScope(
          canPop: true,
          onPopInvoked: (bool didPop) {
            if(didPop){
              handleScreenChange(ScreenSelected.home.value, "Home");
            }
          },
          child:SudokuGeneratorPage(
          handleScreenChange: handleScreenChange,
        ),
        );
      case ScreenSelected.setting:
        return SettingsPage(
          changeTheme: useLightMode,
          changeColor: changeColorScheme,
          themeModel: themeDataModel!,
        );
      //   return const SettingsPage();
    }
  }

  getBrightness(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.system:
        return View.of(context).platformDispatcher.platformBrightness;
    }
  }

  getColorScheme() {
    return ColorScheme.fromSeed(seedColor: colorSelected.color)
        .copyWith(brightness: getBrightness(themeMode));
  }

  setTheme(ThemeDataModel themeModeSetter) {
    SharedPreferences.getInstance().then((SharedPreferences sharedPreferences) {
      int isLightMode =
          sharedPreferences.getInt('isLightMode') ?? themeDataModel!.themeValue;
      themeModeSetter.setTheme(isLightMode);
      var colorIndex = sharedPreferences.getInt('colorSeed');
      ColorSeed colorSeed;
      if (colorIndex == null) {
        colorSeed = themeDataModel!.colorSelected;
      } else {
        colorSeed = ColorSeed.values[colorIndex];
      }
      themeModeSetter.setColorScheme(colorSeed);
      setThemeValues(themeModeSetter);
      setState(() {
        isLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    useLightMode(themeDataModel!.themeValue);
    changeColorScheme(themeDataModel!.colorSelected);
    ThemeDataModel themeModeTemp = Provider.of<ThemeDataModel>(context);
    themeDataModel = themeModeTemp;
    setTheme(themeModeTemp);
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
    return isLoaded
        ? MaterialApp(
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
              body: PageTransitionSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (
                    Widget child,
                    Animation<double> animation,
                    Animation<double> secondaryAnimation,
                    ) {
                  return FadeThroughTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    fillColor: Colors.transparent,
                    child: child,
                  );
                },
                child: getScreen(ScreenSelected.values[screenIndex]),
              ),
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
            ))
        : const MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Loading')),
            ),
          );
  }
}
