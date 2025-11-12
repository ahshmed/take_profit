import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

abstract class SocialRepository {

  /// Social List Api
  Future socialListApi(BuildContext context, Map<String, dynamic> request);

  ///Create new social Api
  Future addNewSocialApi(BuildContext context, FormData request);

  ///Edit Social Api
  Future editSocialApi(BuildContext context, FormData request);


}