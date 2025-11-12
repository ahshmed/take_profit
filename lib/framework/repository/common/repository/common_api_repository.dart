import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../utils/apis/api_end_points.dart';
import '../../../../utils/apis/api_result.dart';
import '../../../../utils/apis/network_exceptions.dart';
import '../../../../utils/apis/rest_client.dart';
import '../contract/common_repository.dart';
import '../model/check_for_update_response.dart';
import '../model/crypto_currency_response_model.dart';
import '../model/get_url_for_crypto_currency_price_response_model.dart';
import '../model/kucoin_response_model.dart';


class CommonApiRepository implements CommonRepository {
  @override
  Future apiGetCryptoCurrencyPriceLive(BuildContext context, String url) async {
    try {
      Response? response =
          await RestClient.postDataForCurrency(context, url, {});
      CryptoCurrencyResponseModel responseModel =
          cryptoCurrencyResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    } catch (err) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  @override
  Future getKuCoinToken(BuildContext context, String url) async {
    try {
      Response? response = await RestClient.postDataForKuCoin(context, url, {});
      KuCoinResponse responseModel = KuCoinResponse.fromJson(response.data);
      return ApiResult.success(data: responseModel);
    } catch (err) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  @override
  Future getUrlForCryptoCurrencyPrice(BuildContext context) async {
    try {
      Response? response =
          await RestClient.getData(context, ApiEndPoints.cryptoCurrency);
      GetUrlForCryptoCurrencyPriceResponseModel responseModel =
          getUrlForCryptoCurrencyPriceResponseModelFromJson(
              response.toString());
      return ApiResult.success(data: responseModel);
    } catch (err) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }

  @override
  Future checkForUpdate(BuildContext context, int versionNumber, String system) async {
    try {
      Response? response =
          await RestClient.getData(context, "${ApiEndPoints.checkForUpdate}?number=$versionNumber&system=$system");
      CheckForUpdateResponseModel responseModel =
      checkForUpdateResponseModelFromJson(response.toString());
      return ApiResult.success(data: responseModel);
    } catch (err) {
      return ApiResult.failure(error: NetworkExceptions.getDioException(err));
    }
  }
}
