import 'package:flutter/material.dart';

abstract class FavouriteRepository {

  ///Favourite List Api
  Future favouriteListApi(BuildContext context, Map<String, dynamic> request);

  ///Manage Favourite Api
  Future manageFavouriteApi(BuildContext context, Map<String, dynamic> request);

}