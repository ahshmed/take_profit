import 'package:flutter/material.dart';

abstract class SupportRepository {

  ///Support Api
  Future supportApi(BuildContext context, Map<String, dynamic> request);

}