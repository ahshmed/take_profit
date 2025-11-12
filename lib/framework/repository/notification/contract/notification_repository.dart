import 'package:flutter/material.dart';

abstract class NotificationRepository {

  ///Notification List Api
  Future notificationListApi(BuildContext context,Map<String, dynamic> data);

  ///Delete Notification Api
  Future notificationDeleteAPI(BuildContext context, Map<String, dynamic> data);

  ///Notification Count Api
  Future notificationCountApi(BuildContext context);
}