import 'dart:convert';
import 'dart:developer';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../const.dart';
import 'dio_logger.dart';


class RestClient {
  static var dio = Dio();

  static Future<Response> getData(BuildContext context, String endpoint) async {
    try {
      String token = getUserAccessToken();

      Map<String, dynamic>? headers = {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "contentType": "application/json",
        "Accept-Language": getAppLanguage(),
      };

      var dioAuth = Dio(BaseOptions(
        headers: headers,
      ));
      dioAuth.interceptors.add(DioLogger(context));
      Response response = await dioAuth.get(endpoint);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Response> postData(
      BuildContext context, String endpoint, dynamic req) async {
    try {
      String data = jsonEncode(req);
      String token = getUserAccessToken();

      Map<String, dynamic>? headers = {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "contentType": "application/json",
        "Accept-Language": getAppLanguage(),
      };

      var dioAuth = Dio(BaseOptions(
        headers: headers,
        receiveTimeout: const Duration(seconds: 50),
      ));
      dioAuth.interceptors.add(DioLogger(context));
      Response response = await dioAuth.post(endpoint, data: data);
      print(response.data.toString());
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Response> postDataForKuCoin(
      BuildContext context, String endpoint, dynamic req) async {
    try {
      String data = jsonEncode(req);

      Map<String, dynamic>? headers = {
        "Accept": "application/json",
        "contentType": "application/json",
      };

      var dioAuth = Dio(BaseOptions(
        headers: headers,
        receiveTimeout: const Duration(seconds: 50),
        baseUrl: "https://api.kucoin.com/api/v1/",
      ));
      dioAuth.interceptors.add(DioLogger(context));
      Response response = await dioAuth.post(endpoint, data: data);
      print(response.data.toString());
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Response> postDataForCurrency(
      BuildContext context, String endpoint, dynamic req) async {
    try {
      String data = jsonEncode(req);
      String token = getUserAccessToken();

      Map<String, dynamic>? headers = {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "contentType": "application/json",
        "Accept-Language": getAppLanguage(),
      };

      var dioAuth = Dio(BaseOptions(
        headers: headers,
        receiveTimeout: const Duration(seconds: 50),
      ));
      // dioAuth.interceptors.add(DioLogger(context));
      Response response = await dioAuth.post(endpoint, data: data);
      log(endpoint);
      log("ggggg");
      log(response.data.toString());
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Response> postForm(
      BuildContext context, String endpoint, FormData formData) async {
    try {
      String token = getUserAccessToken();

      Map<String, dynamic>? headers = {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "contentType": "application/json",
        "Accept-Language": getAppLanguage(),
      };

      var dioAuth = Dio(BaseOptions(
        headers: headers,
      ));
      dioAuth.interceptors.add(DioLogger(context));
      Response response = await dioAuth.post(endpoint, data: formData);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Response> putData(
      BuildContext context, String endpoint, Map<String, dynamic> req,
      {String? s, String? userId}) async {
    try {
      String data = jsonEncode(req);
      String token = getUserAccessToken();

      Map<String, dynamic>? headers = {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "contentType": "application/json",
        "Accept-Language": getAppLanguage(),
      };

      var dioAuth = Dio(BaseOptions(
        headers: headers,
      ));
      dioAuth.interceptors.add(DioLogger(context));
      Response response = await dioAuth.put(endpoint, data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Response> putForm(
      BuildContext context, String endpoint, FormData formData) async {
    try {
      String token = getUserAccessToken();

      Map<String, dynamic>? headers = {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "contentType": "application/json",
        "Accept-Language": getAppLanguage(),
      };

      var dioAuth = Dio(BaseOptions(
        headers: headers,
      ));
      dioAuth.interceptors.add(DioLogger(context));
      Response response = await dioAuth.put(endpoint, data: formData);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  static Future<Response> deleteData(
      BuildContext context, String endpoint, Map<String, dynamic> req) async {
    try {
      String data = jsonEncode(req);
      String token = getUserAccessToken();

      Map<String, dynamic>? headers = {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "contentType": "application/json",
        "Accept-Language": getAppLanguage(),
      };

      var dioAuth = Dio(BaseOptions(headers: headers));
      dioAuth.interceptors.add(DioLogger(context));
      Response response = await dioAuth.delete(endpoint, data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
