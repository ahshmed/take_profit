
import '../contract/master_repository.dart';
import 'master_api_repository.dart';

class MasterRepositoryBuilder {
  static MasterRepository repository() {
    return MasterApiRepository();
  }
}