import 'package:flutter_blue/flutter_blue.dart' as blue;
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:location/location.dart';
class BLEService {
  final blue.FlutterBlue _flutterBlue = blue.FlutterBlue.instance;
  bool _isRequestingPermission = false;
  blue.FlutterBlue get flutterBlue => _flutterBlue;
  Future<void> startScanning() async {
  if (_isRequestingPermission) {
    print("Ya hay una solicitud de permisos en curso");
    return;
  }

  _isRequestingPermission = true;

  try {
    Location location = Location();

    // Verificar y solicitar permiso de ubicación
    final locationPermissionStatus = await location.requestPermission();
    if (locationPermissionStatus == PermissionStatus.granted) {      
      // Verificar si la ubicación está habilitada
      bool isLocationEnabled = await location.serviceEnabled();
      if (!isLocationEnabled) {
        // Solicitar al usuario que habilite la ubicación
        isLocationEnabled = await location.requestService();
        if (!isLocationEnabled) {
          print("El usuario no habilitó el servicio de ubicación");
          return;
        }
      }

      final bluetoothScanStatus = await perm.Permission.bluetoothScan.request();
      if (bluetoothScanStatus.isGranted) {
        final bluetoothConnectStatus = await perm.Permission.bluetoothConnect.request();
        if (bluetoothConnectStatus.isGranted) {

          // Verificar si el Bluetooth está habilitado
          FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;
          bool? isBluetoothOn = await bluetooth.isEnabled;

          if (!isBluetoothOn!) {
            // Si el Bluetooth no está habilitado, solicitar al usuario que lo habilite
            await bluetooth.requestEnable();
            // Esperar un momento para dar tiempo a que el Bluetooth se habilite
            await Future.delayed(Duration(seconds: 2));
          }

          final serviceUuids = [
            blue.Guid('19B10000-E8F2-537E-4F6C-D104768A1214'),
            blue.Guid('143C87E6-058A-43E7-9D75-FBBEA5C3C157')
          ];
          await _flutterBlue.startScan(
              timeout: const Duration(seconds: 15), withServices: serviceUuids);
        }
      }
    }
  } on PlatformException catch (e) {
    print("Error al solicitar permisos: ${e.message}");
  } finally {
    _isRequestingPermission = false;
  }
}
  // Future<void> startScanning() async {
  //   final status = await Permission.location.request();
  //   if (await Permission.bluetoothScan.request().isGranted) {
  //     if (await Permission.bluetoothConnect.request().isGranted) {
  //       final serviceUuids = [
  //         Guid('19B10000-E8F2-537E-4F6C-D104768A1214'),
  //         Guid('143C87E6-058A-43E7-9D75-FBBEA5C3C157')
  //       ];
  //       await _flutterBlue.startScan(
  //           timeout: const Duration(seconds: 15), withServices: serviceUuids);
  //     }
  //   }
  // }

  Future<void> stopScanning() async {
    await _flutterBlue.stopScan();
  }

  Future<void> connect(blue.BluetoothDevice device) async {
    await device.connect();
  }

  Future<void> disconnect(blue.BluetoothDevice device) async {
    await device.disconnect();
  }
}
