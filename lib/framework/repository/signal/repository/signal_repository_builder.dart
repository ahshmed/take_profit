
import 'package:take_profit/framework/repository/signal/repository/signal_api_repository.dart';

import '../contract/signal_repository.dart';

class SignalRepositoryBuilder {
  static SignalRepository repository() {
    return SignalApiRepository();
  }
}