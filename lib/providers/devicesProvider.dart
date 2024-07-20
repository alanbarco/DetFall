import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class DevicesProvider extends ChangeNotifier{
  final List<BluetoothDevice> _devices = [];
  List<BluetoothDevice> get devices => _devices;

  void add(BluetoothDevice device){
    if(!devices.contains(device)){
      _devices.add(device);
      notifyListeners();      
    }
  }
  void remove(BluetoothDevice device){
    _devices.remove(device);
    notifyListeners();
  }
}