
class TimeAgo{

  ///  USAGE:
  /// TimeAgo.timeAgoSinceDate((startDate),(endDate)),


  static String timeAgoSinceDate(DateTime strStartDate, DateTime strEndDate) {
    Duration parse = strStartDate.difference(strEndDate).abs();
    if(parse.inDays ~/ 360 == 0){
      return "${((parse.inDays%360)~/30)} Month";
    } else if((parse.inDays%360)~/30 == 0){
      return  "${parse.inDays~/360} Years";
    }
    else{
      return  "${parse.inDays~/360} Yr ${((parse.inDays%360)~/30)} Mo";
    }
  }

  static String timeAgoHoursSinceDate(DateTime strStartTime, DateTime strEndTime) {
    Duration parse = strStartTime.difference(strEndTime).abs();
    if((parse.inMinutes ~/ 60) == 0){
      return  "${parse.inMinutes} Minutes";
    }else if((parse.inHours %60) ~/1  == 0){
      return  "${parse.inHours} Hours";
    }
    else{
      return "${(parse.inHours %60) ~/1} Hr ${parse.inMinutes % 60} Min";
    }
  }
}
