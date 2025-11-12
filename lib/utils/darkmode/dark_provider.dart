import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dark_mode_controller.dart';

// final darkProvider = ChangeNotifierProvider.autoDispose((ref)=> DarkModeController());
final darkProvider = ChangeNotifierProvider((ref) => DarkModeController());
