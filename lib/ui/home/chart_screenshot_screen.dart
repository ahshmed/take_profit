import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../framework/data_provider/home/home_provider.dart';
import '../../framework/repository/recommender/model/btc_scenarios_list_response_model.dart';
import '../../utils/const.dart';
import '../../utils/theme_const.dart';
import '../../utils/widgets/cache_image.dart';


class ChartScreenShotScreen extends ConsumerWidget {
  final String chartImage;
  final List<BTCImage>? btcImages;

  ChartScreenShotScreen({Key? key, this.chartImage = '', this.btcImages})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartScreenWatch = ref.watch(chartScreenshotProvider);
    return Scaffold(
      backgroundColor: Constant.clrBlackOrigin,
      appBar: AppBar(
        backgroundColor: Constant.clrBlackOrigin,
        leading: InkWell(
          splashColor: Constant.clrTransparent,
          highlightColor: Constant.clrTransparent,
          onTap: () {
            Navigator.pop(context);
          },
          child: Transform.rotate(
            angle: (getAppLanguage() == 'ar') ? pi : 0,
            child: Image.asset(
              Constant.icBack,
            ),
          ),
        ),
        actions: [
          Visibility(
            visible: (chartImage != ''),
            child: InkWell(
              splashColor: Constant.clrTransparent,
              highlightColor: Constant.clrTransparent,
              onTap: () {
                chartScreenWatch.setIsRotate(!chartScreenWatch.isRotate);
              },
              child: Icon(
                Icons.screen_rotation_rounded,
                size: 30.h,
              ),
            ),
          ),
          SizedBox(
            width: 20.w,
          )
        ],
      ),
      body: (chartImage != '')
          ? Transform.rotate(
              angle: chartScreenWatch.isRotate ? pi / 2 : 0,
              child: InteractiveViewer(
                maxScale: 20,
                child: Container(
                  padding: EdgeInsets.only(bottom: 30.h),
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: CacheImage(
                    imageURL: chartImage,
                    height: chartScreenWatch.isRotate == true
                        ? double.infinity
                        : MediaQuery.of(context).size.height,
                    width: chartScreenWatch.isRotate == true
                        ? MediaQuery.of(context).size.height
                        : double.maxFinite,
                    contentMode: BoxFit.contain,
                  ),
                ),
              ),
            )
          : Consumer(builder: (context, ref, child) {
              final chartScreenWatch = ref.watch(chartScreenshotProvider);
              return ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: btcImages?.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = btcImages?[chartScreenWatch.currentIndex]
                        .image
                        .toString();
                    return Stack(
                      children: [
                        InteractiveViewer(
                          maxScale: 20,
                          child: Container(
                            padding: EdgeInsets.only(bottom: 30.h),
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            alignment: Alignment.center,
                            child: CacheImage(
                              imageURL: item!,
                              height: MediaQuery.of(context).size.height,
                              width: chartScreenWatch.isRotate == true
                                  ? MediaQuery.of(context).size.height
                                  : double.maxFinite,
                              contentMode: BoxFit.contain,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                splashColor: Constant.clrTransparent,
                                highlightColor: Constant.clrTransparent,
                                onTap: () {
                                  if (chartScreenWatch.currentIndex != 0) {
                                    chartScreenWatch.updateCurrentIndex(
                                        chartScreenWatch.currentIndex - 1);
                                  }
                                },
                                child: Icon(
                                  Icons.keyboard_arrow_left,
                                  color: (chartScreenWatch.currentIndex != 0)
                                      ? Constant.clrWhite
                                      : Constant.clrBlackNew,
                                  size: 50,
                                ),
                              ),
                              InkWell(
                                splashColor: Constant.clrTransparent,
                                highlightColor: Constant.clrTransparent,
                                onTap: () {
                                  showLog(
                                      "btcImages?.length ${btcImages?.length}");
                                  if (chartScreenWatch.currentIndex <
                                      (int.parse(btcImages?.length.toString() ??
                                              '') -
                                          1)) {
                                    chartScreenWatch.updateCurrentIndex(
                                        chartScreenWatch.currentIndex + 1);
                                  }
                                },
                                child: Icon(
                                  Icons.keyboard_arrow_right,
                                  color: (chartScreenWatch.currentIndex <
                                          (int.parse(btcImages?.length
                                                      .toString() ??
                                                  '') -
                                              1))
                                      ? Constant.clrWhite
                                      : Constant.clrBlackNew,
                                  size: 50,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    );
                  });
            }),
    );
  }
}
