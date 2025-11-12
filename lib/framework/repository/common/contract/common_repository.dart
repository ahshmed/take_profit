import 'package:flutter/cupertino.dart';

abstract class CommonRepository{


  Future apiGetCryptoCurrencyPriceLive(BuildContext context, String url);

  Future getUrlForCryptoCurrencyPrice(BuildContext context);

  Future checkForUpdate(BuildContext context, int versionNumber, String system);

  Future getKuCoinToken(BuildContext context, String url);
}