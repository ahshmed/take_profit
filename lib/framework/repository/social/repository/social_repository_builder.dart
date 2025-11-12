
import 'package:take_profit/framework/repository/social/repository/social_api_repository.dart';

import '../contract/social_repository.dart';

class SocialRepositoryBuilder {
  static SocialRepository repository() {
    return SocialApiRepository();
  }
}