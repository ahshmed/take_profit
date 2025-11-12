import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

abstract class SignalRepository {

  ///Create Signal Api
  Future createSignalApi(BuildContext context, FormData request);

  /// Signal list Api
  Future signalListApi(BuildContext context, Map<String, dynamic> request);

  ///close Signal Api
  Future closeSignalApi(BuildContext context, Map<String, dynamic> request);

  ///Create Signal Api
  Future editSignalApi(BuildContext context, FormData request);

  ///Signal Details Api
  Future signalDetailsAPI(BuildContext context, Map<String, dynamic> request);

  ///All Signal List Api
  Future allSignalListAPI(BuildContext context, Map<String, dynamic> request);

  /// close All Signal Api
  Future closedAllSignalApi(BuildContext context);

  Future enableSignalNotification(BuildContext context, Map<String, dynamic> request);
}