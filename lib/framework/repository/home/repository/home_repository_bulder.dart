
import '../contract/home_repository.dart';
import 'home_api_repository.dart';

class HomeRepositoryBuilder {
  static HomeRepository repository() {
    return HomeApiRepository();
  }
}