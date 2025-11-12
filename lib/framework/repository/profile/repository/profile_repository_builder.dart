
import 'package:take_profit/framework/repository/profile/repository/profile_api_repository.dart';

import '../contract/profile_repository.dart';

class ProfileRepositoryBuilder {
  static ProfileRepository repository() {
    return ProfileApiRepository();
  }
}