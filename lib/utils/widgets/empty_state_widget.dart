import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:take_profit/utils/extension/string_extension.dart';
import 'package:take_profit/utils/widgets/round_button.dart';
import 'package:take_profit/utils/widgets/show_up_transition.dart';

import '../theme_const.dart';

class EmptyStateWidget extends StatelessWidget  {
  final EmptyState emptyStateFor;
  final bool isButtonShow;
  final Function()? onTap;
  EmptyStateWidget(
      {Key? key,
      required this.emptyStateFor,
      this.isButtonShow = false,
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imgName = "";
    String title = "";
    String subTitle = "";
    String buttonText = "";

    switch (emptyStateFor) {
      case EmptyState.noRecommenderFound:
        imgName = Constant.icNoRecommender;
        title = "${"Key_ItIsVoid".localized}!";
        subTitle = "Key_CouldNotFindAnyRecommender".localized;
        break;
      case EmptyState.noRecommenderMatchedRN:
        imgName = Constant.icNoMatchedRecommenderFound;
        title = "Key_ItsEmpty".localized + "!";
        subTitle = "Key_NoRecommenderMatch".localized;
        break;
      case EmptyState.noSubscribeRecommender:
        imgName = Constant.icNoSubscribeRecommenderFound;
        title = "Key_NoDataFound".localized;
        subTitle = "Key_NoSubscribedRecommender".localized;
        break;
      case EmptyState.noSearchFound:
        imgName = Constant.icNoSearchData;
        title = "Key_NothingFound".localized;
        subTitle = "Key_TrySomeDifferentWordsPhrases".localized;
        break;
      case EmptyState.zeroActiveSignals:
        imgName = Constant.icNoActiveSignals;
        title = "Key_ZeroActiveSignals".localized;
        subTitle = "Key_GetStartedCreatingNow".localized;
        break;
      case EmptyState.noClosedSignalFound:
        imgName = Constant.icNoActiveSignals;
        title = "Key_NothingToShow".localized;
        subTitle = "Key_ThereIsNoClosedSignal".localized;
        break;
      case EmptyState.noSearchCurrencyFound:
        imgName = Constant.icNoSearchData;
        title = "Key_UhOhThereNothing".localized;
        subTitle = "Key_TrySomeOtherSearchTerms".localized;
        break;
      case EmptyState.noBTCScenariosFound:
        imgName = Constant.icNoBTCScenario;
        title = "Key_CouldNotFindAnything".localized;
        subTitle = "Key_ThereAreNoBTCScenarios".localized;
        buttonText = "Key_AddBTCScenarios".localized;
        break;
      case EmptyState.noSocialFoundForToday:
        imgName = Constant.icNoSocial;
        title = "Key_NothingFound".localized;
        subTitle = "Key_ThereNoSocialActivityToShow".localized;
        buttonText = "Key_AddSocial".localized;
        break;
      case EmptyState.noSocialFoundForYesterday:
        imgName = Constant.icNoSocial;
        title = "Key_NothingFound".localized;
        subTitle = "Key_NoSocialActivityFromYesterday".localized;
        break;
      case EmptyState.noSocialFoundForThisDay:
        imgName = Constant.icNoSocial;
        title = "Key_NothingFound".localized;
        subTitle = "Key_NoSocialActivityFoundForThisDay".localized;
        break;
      case EmptyState.noNotificationFound:
        imgName = Constant.icNoNotifications;
        title = "Key_ItIsBlank".localized;
        subTitle = "Key_YouHaveNoNewNotificationSoFar".localized;
        break;
      case EmptyState.noTermsFound:
        imgName = Constant.icNoTermsAndCondition;
        title = "Key_NotFound".localized;
        subTitle = "Key_NoTermsOfServicesToShow".localized;
        break;
      case EmptyState.noCurrencyFound:
        imgName = Constant.icNoCurrency;
        title = "Key_SorryNotFound".localized;
        subTitle = "Key_NoCurrencyAvailableRightNow".localized;
        break;
      case EmptyState.noActiveSignalFound:
        imgName = Constant.icNoActiveSignals;
        title = "Key_NoActiveSignal".localized;
        subTitle = "Key_ThisRecommenderDoesNotHaveAnyActiveSignal".localized;
        break;
      case EmptyState.noPendingSignalFound:
        imgName = Constant.icNoActiveSignals;
        title = "Key_NoPendingSignal".localized;
        subTitle = "Key_ThisRecommenderDoesNotHaveAnyPendingSignal".localized;
        break;
      case EmptyState.noBTCScenarios:
        imgName = Constant.icNoBTCScenario;
        title = "Key_NoBTCScenarios".localized;
        subTitle = "Key_ThisRecommenderDoesNotHaveAnyBTCScenarios".localized;
        break;

      case EmptyState.noDataFound:
        imgName = Constant.icNoBTCScenario;
        title = "Key_NoDataFound".localized;
        subTitle = "Key_PleaseTryAgainLater".localized;
        break;
      case EmptyState.noActivityFound:
        imgName = Constant.icNoSocial;
        title = "Key_NoActivityFound".localized;
        subTitle = "Key_NoSocialActivityByThisRecommender".localized;
        break;
      case EmptyState.zeroSubscriptions:
        imgName = Constant.icNoSubscribeRecommenderFound;
        title = "Key_OopsZeroSubscribes".localized;
        subTitle = "Key_SubscribeToSomeGoodRecommendersNow".localized;
        break;
      case EmptyState.noFavouriteFound:
        imgName = Constant.icNoFavourites;
        title = "Key_NoFavorites".localized;
        subTitle = "Key_StartAddingWhatYouLikeToYourFavoritesNow".localized;
        break;
      case EmptyState.paymentFailed:
        imgName = Constant.icPaymentFailed;
        title = "Key_OhOhPaymentFailed".localized;
        subTitle = "Key_TryAgainLater".localized;
        break;
      case EmptyState.somethingsWentWrong:
        imgName = Constant.icSomethingWentWrong;
        title = "Key_ThereSomeError".localized;
        subTitle = "Key_LooksLikeThereIsSomeErrorHoldTight".localized;
        break;
      case EmptyState.noPlanToChoose:
        imgName = Constant.icNoPlans;
        title = "Key_NoPlanFound".localized;
        subTitle = "Key_NoPlansSubtitle".localized;
        break;
        case EmptyState.noPlanToFound:
        imgName = Constant.icNoPlans;
        title = "Key_NoPlanFound".localized;
        subTitle = "Key_Atleastoneplanisneeded".localized;
        break;
      case EmptyState.noResultFound:
        imgName = Constant.icNoResultFound;
        title = "Key_NoResultFound".localized;
        subTitle = "Key_ItLooklikePlanyouarelookingfornoexits".localized;
        break;
        case EmptyState.emptyFavouriteCurrency:
        imgName = Constant.svgEmptyFavouriteCurerncy;
        title = "";
        subTitle = "";
        break;
      default:
        imgName = Constant.icSomethingWentWrong;
        title = "Key_ThereSomeError".localized;
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30.w),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// image
            ShowUpTransition(
              delay: 150,
              child: SvgPicture.asset(
                imgName,
                height: 130.h,
                width: 130.h,
              ),
            ),
            SizedBox(height: 30.h),

            /// title
            ShowUpTransition(
              delay: 150,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: Constant.fwSemiBold,
                  fontSize: 16.sp,
                  color: Constant.clrTextByTheme(context),
                ),
              ),
            ),

            /// blank height
            SizedBox(
              height: 10.h,
            ),

            /// description
            ShowUpTransition(
              delay: 150,
              child: Text(
                subTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: Constant.fwRegular, fontSize: 12.sp, color: Constant.clrBlackNew),
              ),
            ),
            Visibility(
              visible: onTap != null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 30.h,
                  ),
                  RoundButton(
                    label: buttonText,
                    bgColor: Constant.clrPrimary,
                    titleColor: Constant.clrWhite,
                    fontSize: 12.sp,
                    onTap: onTap,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum EmptyState {
  // somethingWentWrong,
  // noData,
  // noCurrency,
  // noSocialData,
  // noSignalData,
  // noBTCSenarios,
  // emptyCart,
  // shop,
  // runWay,
  // noAssessment,

  noRecommenderFound,
  noRecommenderMatchedRN,
  zeroActiveSignals,
  noSubscribeRecommender,
  noSearchFound,
  noSearchCurrencyFound,
  noClosedSignalFound,
  noActiveSignalFound,
  noPendingSignalFound,
  noBTCScenariosFound,
  noSocialFoundForToday,
  noSocialFoundForYesterday,
  noSocialFoundForThisDay,
  noNotificationFound,
  noTermsFound,
  noCurrencyFound,
  noBTCScenarios,
  noActivityFound,
  noFavouriteFound,
  zeroSubscriptions,
  paymentFailed,
  somethingsWentWrong,
  noDataFound,
  noPlanToChoose,
  noPlanToFound,
  noResultFound,
  emptyFavouriteCurrency
}
