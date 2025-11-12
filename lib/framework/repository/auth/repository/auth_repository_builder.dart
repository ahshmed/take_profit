

import '../contract/auth_repository.dart';
import 'auth_api_repository.dart';

class AuthRepositoryBuilder {
  static AuthApiRepository repository() {
    return AuthApiRepository();
  }
}