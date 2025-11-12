import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synchronized/synchronized.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

import '../../../utils/apis/api_end_points.dart';
import '../../../utils/apis/api_result.dart';
import '../../../utils/apis/network_exceptions.dart';
import '../../../utils/const.dart';
import '../../repository/common/contract/common_repository.dart';
import '../../repository/common/model/check_for_update_response.dart';
import '../../repository/common/model/crypto_currency_response_model.dart';
import '../../repository/common/model/get_url_for_crypto_currency_price_response_model.dart';
import '../../repository/common/model/kucoin_response_model.dart';
import '../../repository/common/repository/common_repository_builder.dart';


final commonProvider = ChangeNotifierProvider((ref) => CommonController());

class CommonController extends ChangeNotifier {
  /// Api Properties
  bool isLoading = false;
  bool isError = false;
  bool askForUpdate = false;

  String cryptoUrl = '';
  VersionUpdateStatus versionUpdateStatus = VersionUpdateStatus.none;

  int versionNumber = 4; //TODO increase on each version
  String system = Platform.isIOS ? "IOS" : "Android";

  bool showClosedSignal = false;
  bool showSocialPosts = false;
  String guideUrl = "";

  String whatsapp = "";
  final Lock _lock = Lock();

  void updateUi() {
    try {
      notifyListeners();
    } catch(e){
    }
  }

  void updateIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void updateIsError(bool value) {
    isError = value;
    notifyListeners();
  }

  void updateAskForUpdate(bool value) {
    askForUpdate = value;
    notifyListeners();
  }

  void clearProvider() {
    isLoading = false;
    isError = false;
    notifyListeners();
  }

  final CommonRepository commonRepository =
      CommonRepositoryBuilder.repository();

  CryptoCurrencyResponseModel cryptoCurrencyResponseModel =
      CryptoCurrencyResponseModel();

  /// Get Realtime Pricing from 3rd Party Api
  Future<void> getCryptoCurrencyAPI(BuildContext context) async {
    if (cryptoCurrencyResponseModel.data != null &&
        (cryptoCurrencyResponseModel.data?.isNotEmpty == true)) {
      return;
    }
    updateIsLoading(true);
    updateIsError(false);

    ApiResult apiResult = await commonRepository.apiGetCryptoCurrencyPriceLive(
        context, cryptoUrl);

      apiResult.when(success: (data) async {
      updateIsLoading(false);

      cryptoCurrencyResponseModel = data as CryptoCurrencyResponseModel;
      getLivePrices(context);
    }, failure: (NetworkExceptions error) {
      showLog("error----${error}");

      updateIsLoading(false);
      updateIsError(true);

      String errorMsg = NetworkExceptions.getErrorMessage(error);
      if (errorMsg != '') {
        // currencyTimerHome?.cancel();
        // showMessageDialog(context, 'Third Party Api is not Working', () {});
      }
      showLog("errorMsg $errorMsg");
      // showMessageDialog(context, errorMsg, null);
    });
    notifyListeners();
  }

  Future<void> getLivePrices(context) async {
    getBinancePrices();
    getKuCoinPrices(context);
  }

  Future<void> getBinancePrices() async {
    if (cryptoCurrencyResponseModel.data != null &&
        (cryptoCurrencyResponseModel.data?.isNotEmpty == true)) {

      try {
        final wsUrl = Uri.parse(
            'wss://stream.binance.com:9443/ws/!miniTicker@arr');
        final channel = WebSocketChannel.connect(wsUrl);

        await channel.ready;

        channel.stream.listen((message) async {
          await _lock.synchronized(() async {
            List<BinanceCryptoCurrencyData> data = jsonDecode(message).map<
                BinanceCryptoCurrencyData>((e) =>
                BinanceCryptoCurrencyData.fromJson(e))
                .toList();
            for (var e in data) {
              e.symbol = e.symbol!.length > 4 ? e.symbol!.substring(
                  e.symbol!.length - 4, e.symbol!.length) == "USDT" ? e.symbol!
                  .substring(0, e.symbol!.length - 4) : "" : "";
            }

            if (cryptoCurrencyResponseModel.data != null &&
                (cryptoCurrencyResponseModel.data?.isNotEmpty == true)) {
              cryptoCurrencyResponseModel.data?.forEach((e) {
                var list = data.where((element) =>
                element.symbol != "" &&
                    element.symbol!.toLowerCase() == e.symbol!.toLowerCase())
                    .toList();
                if (list.isNotEmpty) {
                  e.priceUsd = list[0].priceUsd;
                  e.updatedByBinance = true;
                }
              });
              try {
                notifyListeners();
              }catch(e){
              }
            } else {
              updateIsError(true);
            }
          });
        }, onError: (error) {
          print("Binanceee Errorr");
          Future.delayed(const Duration(seconds: 1), () => getBinancePrices());
        }, onDone: () {
          print("Binanceee Donnne");
          Future.delayed(const Duration(seconds: 1), () => getBinancePrices());
        });
        print("cryptoData.length ${cryptoCurrencyResponseModel.data?.length}");
      } catch(e){
        print(e);
        print("Binanceee Errorr catch");
        Future.delayed(const Duration(seconds: 1), () => getBinancePrices());
      }
    } else {
      updateIsError(true);
    }
  }

  Future<void> getKuCoinPrices(context) async {
    if (cryptoCurrencyResponseModel.data != null &&
        (cryptoCurrencyResponseModel.data?.isNotEmpty == true)) {

      ApiResult apiResult = await commonRepository
          .getKuCoinToken(
          context, "bullet-public");
      apiResult.when(success: (data) async {
        kuCoinWebSocket(context, data);
      }, failure: (NetworkExceptions error) {
        showLog("error----$error");
      });
    }
  }

  Future<void> kuCoinWebSocket(context, KuCoinResponse response) async {
    if (cryptoCurrencyResponseModel.data != null &&
        (cryptoCurrencyResponseModel.data?.isNotEmpty == true)) {
      if(response.code == "200000") {
        try {
          final wsUrl = Uri.parse(
              "${response.data?.instanceServers?.endpoint}?token=${response.data
                  ?.token}");
          final channel = WebSocketChannel.connect(wsUrl);

          await channel.ready;

          channel.stream.listen((message) async {
            await _lock.synchronized(() async {
              var socketData = json.decode(message);
              if(socketData['type'] == "welcome") {
                channel.sink.add(
                    json.encode({"type": "subscribe", "topic": "/market/ticker:all"}));
              }
              else if(socketData['type'] == "message"){
                  String symbol = socketData['subject'];
                  if(symbol.length > 5 && symbol.substring(symbol.length - 5, symbol.length) == "-USDT") {
                    symbol = symbol.substring(0, symbol.length - 5);

                    String priceUsd = socketData['data']['price'] ?? "0.0";

                    cryptoCurrencyResponseModel.data?.forEach((e) async {
                      if (e.updatedByBinance == false && e.symbol!.toLowerCase() == symbol.toLowerCase()) {
                          e.priceUsd = priceUsd;
                      }
                    });
                    try {
                      notifyListeners();
                    } catch(e){
                    }
                  }

              } });
          }, onError: (error) {
            print("KuCoin Errorr");
            Future.delayed(
                const Duration(seconds: 2), () => getKuCoinPrices(context));
          }, onDone: () {
            print("KuCoin Donnne");
            Future.delayed(
                const Duration(seconds: 2), () => getKuCoinPrices(context));
          });
          print(
              "cryptoData.length ${cryptoCurrencyResponseModel.data?.length}");
        } catch (e) {
          print(e);
          print("KuCoin Errorr catch");
          Future.delayed(
              const Duration(seconds: 2), () => getKuCoinPrices(context));
        }
      }
    } else {
      updateIsError(true);
    }
  }

  GetUrlForCryptoCurrencyPriceResponseModel
      getUrlForCryptoCurrencyPriceResponseModel =
      GetUrlForCryptoCurrencyPriceResponseModel();

  /// Get Realtime Pricing from 3rd Party Api
  Future<void> getUrlForCryptoCurrencyPrice(BuildContext context) async {
    updateIsLoading(true);
    updateIsError(false);

    ApiResult apiResult =
        await commonRepository.getUrlForCryptoCurrencyPrice(context);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      getUrlForCryptoCurrencyPriceResponseModel =
          data as GetUrlForCryptoCurrencyPriceResponseModel;

      if (getUrlForCryptoCurrencyPriceResponseModel.status ==
          ApiEndPoints.apiStatus_200) {
        // getUrlForCryptoCurrencyPriceResponseModel.data;
        cryptoUrl = getUrlForCryptoCurrencyPriceResponseModel
                .data?.cryptoCurrencyApiUrl ??
            "";

        showLog(
            "getUrlForCryptoCurrencyPriceResponseModel ${getUrlForCryptoCurrencyPriceResponseModel.data?.cryptoCurrencyApiUrl}");
      } else {
        updateIsError(true);
      }
    }, failure: (NetworkExceptions error) {
      updateIsLoading(false);
      updateIsError(true);

      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showMessageDialog(context, errorMsg, null);
    });
    notifyListeners();
  }


  CheckForUpdateResponseModel checkForUpdateResponseModel = CheckForUpdateResponseModel();

  /// Check For App New Available Update Api
  Future<void> checkForUpdate(BuildContext context) async {
    updateIsLoading(true);
    updateIsError(false);

    ApiResult apiResult =
    await commonRepository.checkForUpdate(context, versionNumber, system);

    apiResult.when(success: (data) async {
      updateIsLoading(false);
      checkForUpdateResponseModel = data as CheckForUpdateResponseModel;

      if (checkForUpdateResponseModel.status ==
          ApiEndPoints.apiStatus_200) {

        versionUpdateStatus = checkForUpdateResponseModel.data?.required == 0 ? VersionUpdateStatus.optional
            : checkForUpdateResponseModel.data?.required == 1 ? VersionUpdateStatus.required
            : VersionUpdateStatus.none;
        showClosedSignal = checkForUpdateResponseModel.data?.showClosedSignal == 1;
        showSocialPosts = checkForUpdateResponseModel.data?.showSocialPosts == 1;
        guideUrl = checkForUpdateResponseModel.data?.guideUrl ?? "";
        whatsapp = checkForUpdateResponseModel.data?.whatsapp ?? "";

        if(checkForUpdateResponseModel.data?.required  == 0 && getSkipVersion() < int.parse(checkForUpdateResponseModel.data?.latest ?? "1")) {

          updateAskForUpdate(true);
        } else if (checkForUpdateResponseModel.data?.required == 1){
          updateAskForUpdate(true);
        } else {
          updateAskForUpdate(false);
        }

        showLog(
            "CheckForUpdateResponseModel requires: ${checkForUpdateResponseModel.data?.required}");
      } else {
        updateIsError(true);
      }
    }, failure: (NetworkExceptions error) {
      updateIsLoading(false);
      updateIsError(true);

      String errorMsg = NetworkExceptions.getErrorMessage(error);
      showMessageDialog(context, errorMsg, null);
    });
    notifyListeners();
  }
}
