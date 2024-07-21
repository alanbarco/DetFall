import 'package:flutter/material.dart';

class ButtonProvider extends ChangeNotifier{
  bool _activo = true;

  bool get activo => _activo;

  void changeStatus(bool status){
    _activo = status;
    notifyListeners();
  } 
}