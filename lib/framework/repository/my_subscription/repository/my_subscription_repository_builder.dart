
import '../contract/my_subscription_repository.dart';
import 'my_subscription_api_repository.dart';

class MySubscriptionRepositoryBuilder {
  static MySubscriptionRepository repository() {
    return MySubscriptionApiRepository();
  }
}