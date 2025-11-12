
import '../contract/notification_repository.dart';
import 'notification_api_repository.dart';

class NotificationRepositoryBuilder {
  static NotificationRepository repository() {
    return NotificationApiRepository();
  }
}