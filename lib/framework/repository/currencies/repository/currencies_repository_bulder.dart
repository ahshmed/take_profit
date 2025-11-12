import '../contract/currencies_repository.dart';
import 'currencies_api_repository.dart';

class CurrenciesRepositoryBuilder {
  static CurrenciesRepository repository() {
    return CurrenciesApiRepository();
  }
}