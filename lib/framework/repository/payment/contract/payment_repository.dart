import 'package:flutter/material.dart';

abstract class PaymentRepository{

  /// Payment API for Request Analysis
  Future paymentForRequestAnalysisAPI(BuildContext context, Map<String, dynamic> req);

  /// Payment API for Subscription
  Future paymentForSubscriptionAPI(BuildContext context, Map<String, dynamic> req);
}