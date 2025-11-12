import 'package:flutter/material.dart';

abstract class MasterRepository{

  Future apiMasterSubscriptionPackageList(BuildContext context, Map<String, dynamic> req);
}