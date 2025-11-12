import 'dart:ui';

import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../framework/repository/recommender/model/btc_scenarios_list_response_model.dart';
import '../../../utils/const.dart';
import '../../../utils/theme_const.dart';
import '../../../utils/widgets/cache_image.dart';
import '../../../utils/widgets/common_image_asset.dart';


class ListItemWithImageWidget extends StatelessWidget  {
  int? listLength;
  List? listName;
  List<BTCImage>? imageList;
  String? imageName;
  bool showData;
  String recommenderId;
  bool? gridView;
  String? time;
  String? date;
  String? message;
  String? userType;
  Function()? editData;
  Function()? imageClick;
  String? isSameUser;

  ListItemWithImageWidget(
      {Key? key,
      this.editData,
      this.listLength,
      required this.showData,
      required this.recommenderId,
      this.userType,
      this.listName,
      this.imageList,
      this.gridView,
      this.date,
      this.time,
      this.message,
      required this.imageClick, required this.isSameUser,
      this.imageName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: (showData ||
                getUserEntityId() == recommenderId || isSameUser == '1')
            ? cardWidget(context)
            : Blur(
                borderRadius: BorderRadius.circular(10.r),
                blurColor: Constant.clrDarkByScaffoldTheme(context).withOpacity(0.2),
                child: cardWidget(context),
              ));
  }

  Widget cardWidget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.r), color: Constant.clrCardBGByTheme(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: imageClick,
            child: Padding(
              padding:
                  EdgeInsets.only(top: 3.h, left: 3.w, right: 3.w, bottom: 15.h),
              child: gridView == true
                  ? gridImageWidget()
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(5.r),
                      child: CacheImage(
                        imageURL: imageName.toString(),
                        height: 182.h,
                        width: 329.w,
                        contentMode: BoxFit.cover,
                      ),
                    ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15.h, right: 15.h, bottom: 15.h),
            child: Row(
              children: [
                Text(
                  date.toString(),
                  style: TextStyles.txtRegular10
                      (context).copyWith(color: Constant.clrWhiteGreyNewByTheme(context)),
                ),
                SizedBox(
                  width: 23.w,
                ),
                Expanded(
                  child: Text(
                    time.toString(),
                    style: TextStyles.txtRegular10
                        (context).copyWith(color: Constant.clrWhiteGreyNewByTheme(context)),
                  ),
                ),
                Visibility(
                  visible: userType == recommender ? true : false,
                  child: InkWell(
                    onTap: editData,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: CommonImageAsset(
                        strIcon: Constant.icEdit,
                        height: 14.h,
                        width: 14.h,
                        boxFit: BoxFit.cover,
                        clrImg: Constant.clrWhiteBlackByTheme(context),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15.h, right: 15.h, bottom: 0.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    message.toString(),
                    style: TextStyles.txtRegular12
                        (context).copyWith(color: Constant.clrBlackWhiteByTheme(context)),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ///BTC Scenarios Image List
  Widget gridImageWidget() {
    return GridView.builder(
      itemCount: (imageList?.length ?? 0) > 3 ? 3 : imageList?.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverQuiltedGridDelegate(
        crossAxisCount: 4,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        pattern: ((imageList?.length ?? 0) >= 4)
            ? [
                const QuiltedGridTile(2, 2),
                const QuiltedGridTile(1, 2),
                const QuiltedGridTile(1, 2)
              ]
            : ((imageList?.length ?? 0) == 3)
                ? [
                    const QuiltedGridTile(2, 2),
                    const QuiltedGridTile(1, 2),
                    const QuiltedGridTile(1, 2)
                  ]
                : ((imageList?.length ?? 0) == 2)
                    ? [const QuiltedGridTile(2, 2), const QuiltedGridTile(2, 2)]
                    : [const QuiltedGridTile(2, 4)],
      ),
      itemBuilder: (context, index) {
        return index == 2
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5.r),
                    child: CacheImage(
                        imageURL: imageList?[index].image.toString() ?? "",
                        height: 89.h,
                        width: 89.h),
                  ),
                  int.parse(imageList?.length.toString() ?? "") - 3 == 0
                      ? const Offstage()
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(5.r),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                            child: Container(
                              color: Colors.grey.withOpacity(0.01),
                              alignment: Alignment.center,
                              child: Text(
                                "+ ${int.parse(imageList?.length.toString() ?? "") - 3}",
                                style: TextStyles.txtMedium14(context).copyWith(
                                    fontSize: 13.sp, color: Constant.clrWhiteNew),
                              ),
                            ),
                          ),
                        ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(5.r),
                child: CacheImage(
                  imageURL: imageList?[index].image.toString() ?? "",
                  height: 89.h,
                  width: 89.h,
                  contentMode: BoxFit.cover,
                ),
              );
      },
    );
  }
}
