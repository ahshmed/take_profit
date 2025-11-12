import '../contract/common_repository.dart';
import 'common_api_repository.dart';

class CommonRepositoryBuilder{
  static CommonRepository repository(){
    return CommonApiRepository();
  }
}