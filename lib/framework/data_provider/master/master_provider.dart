import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'master_controller.dart';

final masterProvider = ChangeNotifierProvider((ref) => MasterController());
