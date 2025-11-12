
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:take_profit/framework/data_provider/payment/payment_controller.dart';


final paymentProvider = ChangeNotifierProvider((ref) => PaymentController());