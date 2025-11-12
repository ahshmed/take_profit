import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'favorite_controller.dart';

final favoriteProvider =
    ChangeNotifierProvider((ref) => FavoriteScreenController());
