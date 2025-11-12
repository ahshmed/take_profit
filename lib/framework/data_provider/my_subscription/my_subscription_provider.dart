import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:take_profit/framework/data_provider/my_subscription/user_guide_controller.dart';

import 'my_subscription_controller.dart';


final mySubscriptionProvider =
    ChangeNotifierProvider((ref) => MySubscriptionController());

final userGuideProvider =
    ChangeNotifierProvider((ref) => UserGuideController());
