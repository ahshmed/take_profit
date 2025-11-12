
import 'package:take_profit/framework/repository/support/repository/support_api_repository.dart';

import '../contract/support_repository.dart';

class SupportRepositoryBuilder {
  static SupportRepository repository() {
    return SupportApiRepository();
  }
}