// import 'dart:convert';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:trader/utils/const.dart';
// import 'package:trader/utils/theme_const.dart';
//
//
// /*
// * https://medium.com/flutter-community/dio-interceptors-in-flutter-17be4214f363
// * -> use print for all data while api call
// *
// * https://www.thetopsites.net/article/58461668.shtml
// * recall api when token is expired and generate new token and call past api again
// * */
//
//
// class CacheInterceptor extends Interceptor with Constant{
//
//   var dio = Dio();
//
//   String apiType;
//   Dio previous;
//   BuildContext context;
//
//   CacheInterceptor(this.context, this.previous, this.apiType);
//
//
//   static String apiPOST = "POST";
//   static String apiGET = "GET";
//   static String apiGETQUERYPARAMETER = "GETQUERYPARAMETER";
//   static String apiPUT = "PUT";
//   static String apiPUTQUERYPARAMETER = "PUTQUERYPARAMETER";
//   static String apiDELETE = "DELETE";
//
//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
//     super.onRequest(options, handler);
//   }
//
//   @override
//   void onResponse(Response response, ResponseInterceptorHandler handler) {
//
//     super.onResponse(response, handler);
//   }
//
//   @override
//   Future<void> onError(DioError error, ErrorInterceptorHandler handler) async {
//     showLog("onError Interceptor");
//     if (error.response?.statusCode == 401) {
//       RequestOptions options = error.requestOptions;
//
//       showLog("onError Interceptor Lock request...");
//       // Lock to block the incoming request until the token updated
//       previous.lock();
//       previous.interceptors.responseLock.lock();
//       previous.interceptors.errorLock.lock();
//
//       try {
//         //await apiRefreshToken();
//
//         previous.unlock();
//         previous.interceptors.responseLock.unlock();
//         previous.interceptors.errorLock.unlock();
//         showLog("onError Interceptor Unlock request...");
//
//         /*
//         * -- calling past api with new token and parameters
//         * */
//
//         String accessToken = getUserAccessToken();
//
//         var dioauth = Dio(BaseOptions(headers: {
//           "Authorization": "Bearer " + accessToken,
//           "content-type": "application/json",
//         }));
//
//         showLog("options.path : ${options.path}");
//         showLog("options : $options");
//
//         Response? response;
//
//         if (apiType == apiGET) {
//           response = await dioauth.get(options.path);
//         } else if (apiType == apiGETQUERYPARAMETER) {
//           response = await dioauth.get(options.path,
//               queryParameters: options.queryParameters);
//         } else if (apiType == apiPOST) {
//           response = await dioauth.post(options.path, data: options.data);
//         } else if (apiType == apiPUT) {
//           response = await dioauth.put(options.path, data: options.data);
//         } else if (apiType == apiPUTQUERYPARAMETER) {
//           response = await dioauth.put(options.path,
//               queryParameters: options.queryParameters);
//         } else if (apiType == apiDELETE) {
//           response = await dioauth.delete(options.path);
//         }
//
//         return handler.resolve(response!);
//       } catch (e) {
//         logout(context);
//       }
//     }
//     // return error;
//   }
//
//
//
//
//   Future apiRefreshToken() async {
//
// //    SharedPreferences pref = await SharedPreferences.getInstance();
// //    String refresh_token = pref.getString(prefStr_REFRESH_TOKEN);
// //
// //    RefreshRequest refreshRequest = RefreshRequest();
// //    refreshRequest.refreshToken = refresh_token;
// //    refreshRequest.grantType = ApiEndpoints.static_GRANTTYPE;
// //
// //    String data = refreshRequestToJson(refreshRequest);
// //    showLog("apiRefreshToken data :-: $data");
//
//
//     try{
//
//       String credential = "kody-client:kody-secret";
//
//       Options opt = Options(
//           headers: {
//             "Authorization" : "Basic "+base64.encode(utf8.encode(credential)),
//             "content-type": "application/x-www-form-urlencoded",
//             "No-Auth": "True",
//           }
//       );
//
//
// //      Response response = await dio.post(ApiEndpoints.apiRefreshToken, queryParameters: refreshRequest.toJson(), options: opt);
//
// //      if (response.statusCode == 200) {
//
// //        RefreshResponce refreshResponce = refreshResponceFromJson(response.toString());
// //        showLog("apiRefreshToken :-: ${refreshResponceToJson(refreshResponce)}");
// //
// //        sharePref_saveString(prefStr_SCOPE, refreshResponce.scope);
// //        sharePref_saveString(prefStr_ACCESS_TOKEN, refreshResponce.accessToken);
// //        sharePref_saveString(prefStr_TOKEN_TYPE, refreshResponce.tokenType);
// //        sharePref_saveString(prefStr_REFRESH_TOKEN, refreshResponce.refreshToken);
// //        sharePref_saveInt(prefInt_EXPIRES_IN, refreshResponce.expiresIn);
//
// //        return;
// //      }else{
//         /*showSnackBar(errPleaseLoginAgain);
//
//         Future.delayed(Duration(milliseconds: 750), (){
//
//         });*/
// //        logout(context);
// //      }
// //
//     }
//     on DioError catch(e){
// //      showLog("Logout --> ${e.response.statusCode}");
// //      logout(context);
//     }
//
//
//
//   }
//
//
//
//
//
// }