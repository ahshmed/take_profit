
import '../contract/favourite_repository.dart';
import 'favourite_api_repository.dart';

class FavouriteRepositoryBuilder {
  static FavouriteRepository repository() {
    return FavouriteApiRepository();
  }
}