import 'package:flutter/material.dart';

abstract class MySubscriptionRepository {
  ///Subscription List API
  Future subscriptionListAPI(BuildContext context, int pageNo);

  ///Cancel Subscription API
  Future cancelSubscriptionAPI(BuildContext context, Map<String, dynamic> request);

  /// Recommender Subscription Packages API
  Future recommenderSubscriptionPackagesAPI(BuildContext context, Map<String, dynamic> request);

  /// Revenue Chart API
  Future revenueChartAPI(BuildContext context, Map<String, dynamic> rerequest);
}