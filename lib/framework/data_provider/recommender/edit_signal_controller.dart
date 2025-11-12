import 'dart:io';
import 'package:flutter/material.dart';

class EditSignalScreenController extends ChangeNotifier {
  String strTechnicalAnalysisEn = "";
  String strTechnicalAnalysisErrorEn = "";

  bool isValidate = false;

  bool checkImageValidation = false;
  String chartPic = "";
  File chartFile = File('');
  File tempChartFile = File('');

  removeCharPic(bool isRemoveImg) {
    chartPic = "";
    chartFile = File('');
    checkValidation();
    notifyListeners();
  }

  updateChartPic(String photoFile, File file) async {
    chartPic = photoFile;
    chartFile = file;
    if (chartPic.isNotEmpty) {
      checkImageValidation = true;
    } else {
      checkImageValidation = false;
    }
    print("chartPic $chartPic");
    checkValidation();
    notifyListeners();
  }

  checkValidation() {
    isValidate = (strTechnicalAnalysisEn != "" &&
        strTechnicalAnalysisErrorEn == "" &&
        chartPic != "");
    notifyListeners();
  }

  clearProvider() {
    isValidate = false;
    chartPic = "";
    strTechnicalAnalysisEn = "";
    strTechnicalAnalysisErrorEn = "";
    notifyListeners();
  }

  ///Check Technical Analysis validation
  checkEnTechnicalAnalysisValidation(BuildContext context, String value) {
    strTechnicalAnalysisEn = value;
    // strTechnicalAnalysisErrorEn = "";

    // String removeWhiteSpace = value.replaceAll(" ", "");
    // if (removeWhiteSpace.isEmpty) {
      // strTechnicalAnalysisErrorEn = getLocalValue("Key_AddTechnicalAnalysisEnMsg");
    // }

    checkValidation();
    notifyListeners();
  }
}
