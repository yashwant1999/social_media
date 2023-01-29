import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_media/core/enums/enums.dart';

final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

final colorProvider = StateNotifierProvider<ColorNotifier, Color>((ref) {
  return ColorNotifier();
});

class ColorNotifier extends StateNotifier<Color> {
  ColorNotifier() : super(Colors.orange) {
    getValue();
  }

  // intilize the sharedprefrence value in constructor.
  void getValue() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    state = Color(prefs.getInt('colorint') ?? Colors.orange.value);
  }

  // set the value into the shared Preferences.
  void setValue(int colorValue) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('colorint', colorValue);
    state = Color(colorValue);
  }
}

class Pallete {
  // Colors

  static const intaBlack = Color.fromRGBO(0, 0, 0, 1);
  static const blackColor = Color.fromRGBO(1, 1, 1, 1); // primary color
  static const greyColor = Color.fromRGBO(26, 39, 45, 1); // secondary color
  static const drawerColor = Color.fromRGBO(18, 18, 18, 1);
  static const whiteColor = Colors.white;
  static var redColor = Colors.red.shade500;
  static var blueColor = Colors.blue.shade300;

  // Themes

  static var darkModeAppTheme = ThemeData.dark().copyWith(
    useMaterial3: true,

    scaffoldBackgroundColor: blackColor,
    cardColor: greyColor,
    appBarTheme: const AppBarTheme(
      scrolledUnderElevation: 0,
      backgroundColor: drawerColor,
      iconTheme: IconThemeData(
        color: whiteColor,
      ),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    drawerTheme: const DrawerThemeData(
      backgroundColor: drawerColor,
    ),
    primaryColor: redColor,
    backgroundColor:
        drawerColor, // will be used as alternative background color
  );

  static var lightModeAppTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: whiteColor,
    iconTheme: const IconThemeData(color: Colors.black),
    useMaterial3: true,
    cardColor: greyColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: whiteColor,
      elevation: 0,
      iconTheme: IconThemeData(
        color: blackColor,
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: whiteColor,
    ),
    primaryColor: redColor,
    backgroundColor: whiteColor,
  );
}

class ThemeNotifier extends StateNotifier<ThemeData> {
  XThemeMode _mode;

  ThemeNotifier({
    XThemeMode mode = XThemeMode.dark,
  })  : _mode = mode,
        super(Pallete.darkModeAppTheme) {
    getTheme();
  }

  XThemeMode get mode => _mode;

  void getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme');

    if (theme == 'light') {
      _mode = XThemeMode.light;
      state = Pallete.lightModeAppTheme;
    } else {
      _mode = XThemeMode.dark;
      state = Pallete.darkModeAppTheme;
    }
  }

  void toggleTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_mode == ThemeMode.dark) {
      _mode = XThemeMode.light;
      state = Pallete.lightModeAppTheme;
      prefs.setString('theme', 'light');
    } else {
      _mode = XThemeMode.dark;
      state = Pallete.darkModeAppTheme;
      prefs.setString('theme', 'dark');
    }
  }
}


/// So first thing the default value will be :- 
///           final string = pref.getString('color');
///           return Color('String'); so the way you will get the things is 
///           return Color(pref.getInt() ?? Color.orange );
/// 
