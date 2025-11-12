import 'package:flutter/cupertino.dart';

import '../const.dart';
import '../theme_const.dart';

class DarkModeController with ChangeNotifier {
  bool _darkTheme = false;

  bool get darkTheme => _darkTheme;

  DarkModeController() {
    _loadInitialTheme();
  }

  Future<void> _loadInitialTheme() async {
    try {
      // Load saved theme preference
      final savedTheme =  getIsAppThemeDark();
      if (savedTheme != null) {
        _darkTheme = savedTheme;
        debugPrint("Loaded theme from storage: $_darkTheme");
      }else{
        _darkTheme = false; // Default to light theme
        debugPrint("No saved theme found, using default: $_darkTheme");
      }
      notifyListeners();
    }catch(e){
      debugPrint("Error loading theme: $e");
      _darkTheme = false; // Fallback to light theme
      notifyListeners();
    }
  }

  void updateIsDarkMode(bool fromSetting, bool value) async {
    try {
      if (fromSetting) {
        saveLocalData(KEY_APP_THEME_DARK, value);
        debugPrint("Saved theme to storage: $value");
      }
      _darkTheme = value;
      debugPrint("Dark Mode changed to $_darkTheme");
      //showLog("Dark Mode changed to: $_darkTheme");
      //isDarkMode = _darkTheme;
      //showLog("is Dark mode: $isDarkMode");
      notifyListeners();
    }catch(e){
      debugPrint("Error updating theme: $e");
    }
  }
}