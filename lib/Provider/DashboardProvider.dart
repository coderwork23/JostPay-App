import 'package:flutter/cupertino.dart';

class DashboardProvider with ChangeNotifier{
  int currentIndex = 0;

  changeBottomIndex(int newIndex){
    currentIndex = newIndex;
    notifyListeners();
  }
}