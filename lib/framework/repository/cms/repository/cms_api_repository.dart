import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../utils/apis/api_end_points.dart';
import '../../../../utils/apis/api_result.dart';
import '../../../../utils/apis/network_exceptions.dart';
import '../../../../utils/apis/rest_client.dart';
import '../contract/cms_repository.dart';
import '../model/cms_response_model.dart';



class CmsApiRepository extends CmsRepository{

  /// CMS Page API
  @override
  Future cmsPageAPI(BuildContext context, Map<String, dynamic> _request) async{
    try{
        Response? response = await RestClient.postData(context, ApiEndPoints.cmsPage, _request);
        CmsResponseModel responseModel = cmsResponseModelFromJson(response.toString());
        return ApiResult.success(data: responseModel);
      }
      catch (err){
        return ApiResult.failure(error: NetworkExceptions.getDioException(err));
      }
  }

}