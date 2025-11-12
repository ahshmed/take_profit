
import '../contract/cms_repository.dart';
import 'cms_api_repository.dart';

class CmsRepositoryBuilder {
  static CmsRepository repository() {
    return CmsApiRepository();
  }
}