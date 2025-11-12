
import 'package:take_profit/framework/repository/recommender/repository/recommender_api_repository.dart';

import '../contract/recommender_repository.dart';

class RecommenderRepositoryBuilder {
  static RecommenderRepository repository() {
    return RecommenderApiRepository();
  }
}