




import 'package:take_profit/framework/repository/payment/repository/payment_api_repository.dart';

import '../contract/payment_repository.dart';

class PaymentRepositoryBuilder{
  static PaymentRepository repository(){
    return PaymentApiRepository();
  }
}