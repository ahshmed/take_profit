import 'package:flutter/material.dart';

abstract class HomeRepository {

  ///Trending List Api
  Future trendingListApi(BuildContext context, Map<String, dynamic> request);

  ///Recommender Detail Api
  Future recommenderDetailApi(BuildContext context, Map<String, dynamic> request);

  ///Recommender List Api
  Future recommenderListApi(BuildContext context, Map<String, dynamic> request);

  /// Home Recommender Details
  Future homeRecommenderDetailsApi(BuildContext context);

}