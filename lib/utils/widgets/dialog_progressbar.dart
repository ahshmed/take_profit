
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/utils/theme_const.dart';

class DialogProgressBar extends StatelessWidget  {
  bool isLoading;
  bool forPagination;
  bool loaderRequired;

  DialogProgressBar(
      {Key? key,
      required this.isLoading,
      this.forPagination = false,
      this.loaderRequired = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return !(isLoading)
        ? const Offstage()
        : (forPagination)
            ? SizedBox(
                height: 70.h,
                child: Center(
                    child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Constant.clrPrimary),
                )),
              )
            : (loaderRequired)
                ? AbsorbPointer(
                    absorbing: true,
                    child: Container(
                      color: Colors.black.withOpacity(0.4),
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Constant.clrPrimary),
                          ),
                        ),
                      ),
                    ),
                  )
                : Container();
  }
}
