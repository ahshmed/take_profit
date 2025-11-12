
import 'package:take_profit/framework/repository/request_analysis/repository/request_analysis_api_repository.dart';

import '../contract/request_analysis_repository.dart';

class RequestAnalysisRepositoryBuilder {
  static RequestAnalysisRepository repository(){
    return RequestAnalysisApiRepository();
  }
}