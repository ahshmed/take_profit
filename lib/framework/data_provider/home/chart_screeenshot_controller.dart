import 'package:flutter/material.dart';

class ChartScreenShotController extends ChangeNotifier{

  bool isRotate = false;

  setIsRotate(){
    isRotate = !isRotate;
    notifyListeners();
  }

  int currentIndex = 0;


  updateCurrentIndex(index){
    currentIndex = index;
    notifyListeners();
  }

}