import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

abstract class RequestAnalysisRepository {

  /// Get Request analysis List API
  Future getRequestAnalysisListAPI(BuildContext context, Map<String,dynamic> requestData);

  /// New Request Analysis
  Future newRequestAnalysisAPI(BuildContext context,FormData formData);

  /// Complete Request Analysis
  Future completeRequestAnalysis(BuildContext context, Map<String, dynamic> requestData);

  /// Request Analysis Details
  Future requestAnalysisDetails(BuildContext context, Map<String, dynamic> requestData);
}