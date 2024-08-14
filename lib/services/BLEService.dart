import 'dart:async';

import 'package:flutter_blue/flutter_blue.dart' as blue;
import 'package:flutter_blue/gen/flutterblue.pb.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'notificactionService.dart';
class BLEService {
  final blue.FlutterBlue _flutterBlue = blue.FlutterBlue.instance;
  bool _isRequestingPermission = false;
  blue.FlutterBlue get flutterBlue => _flutterBlue;  
  late StreamSubscription<blue.ScanResult> _scanSubscription;
  final StreamController<blue.BluetoothDevice> _deviceDisconnectedController = StreamController<blue.BluetoothDevice>.broadcast();
  Stream<blue.BluetoothDevice>? get deviceDisconnectedStream => _deviceDisconnectedController.stream;



  Future<void> startScanning() async {
    if (_isRequestingPermission) {
      print("Ya hay una solicitud de permisos en curso");
      return;
    }
    _isRequestingPermission = true;
    try {
      //verificacion de localizacion
      Location location = Location();
      final locationPermissionStatus = await location.requestPermission();
      if (locationPermissionStatus == PermissionStatus.granted) {
        bool isLocationEnabled = await location.serviceEnabled();
        if (!isLocationEnabled) {
          isLocationEnabled = await location.requestService();
          if (!isLocationEnabled) {
            print("El usuario no habilitó el servicio de ubicación");
            return;
          }
        }
        // verificacion de bluetooth
        final bluetoothScanStatus =
            await perm.Permission.bluetoothScan.request();
        if (bluetoothScanStatus.isGranted) {
          final bluetoothConnectStatus =
              await perm.Permission.bluetoothConnect.request();
          if (bluetoothConnectStatus.isGranted) {
            FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
            bool? isBluetoothOn = await bluetooth.isEnabled;
            if (!isBluetoothOn!) {
              await bluetooth.requestEnable();
              await Future.delayed(Duration(seconds: 2));
            }

            final serviceUuids = [
              blue.Guid('19B10000-E8F2-537E-4F6C-D104768A1214'),
              blue.Guid('143C87E6-058A-43E7-9D75-FBBEA5C3C157')
            ];
            await _flutterBlue.startScan(
                timeout: const Duration(seconds: 15),
                withServices: serviceUuids);
          }
        }
      }
    } on PlatformException catch (e) {
      print("Error al solicitar permisos: ${e.message}");
    } finally {
      _isRequestingPermission = false;
    }
  }

  Future<void> stopScanning() async {
    await _flutterBlue.stopScan();
  }

  Future<void> connect(blue.BluetoothDevice device) async {
  // Obtener el estado actual del dispositivo
  var currentState = await device.state.first;

  // Verificar si el dispositivo ya está conectado
  if (currentState != blue.BluetoothDeviceState.connected) {
    // Conectar solo si el dispositivo no está ya conectado
    await device.connect();
  } else {
    print("El dispositivo ya está conectado");
  }

  // Escuchar el estado del dispositivo para manejar desconexiones
  device.state.listen((state) {
    if (state == blue.BluetoothDeviceState.disconnected) {
      _deviceDisconnectedController.add(device);
      notificationBattery();
    }
  });
  
}


  Future<void> disconnect(blue.BluetoothDevice device) async {
    await device.disconnect();
  }

}