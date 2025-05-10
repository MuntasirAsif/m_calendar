import 'package:flutter/cupertino.dart';

class SelectedDaysModel{
  final List<int> selectedDateList;
  final BoxDecoration decoration;
  final Widget? child;
  SelectedDaysModel({required this.selectedDateList,required this.decoration,this.child});
}