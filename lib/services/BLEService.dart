import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

class BLEService {
  final FlutterBlue _flutterBlue = FlutterBlue.instance;

  FlutterBlue get flutterBlue => _flutterBlue;

  Future<void> startScanning() async {
    final status = await Permission.location.request();
    if (await Permission.bluetoothScan.request().isGranted) {
      if (await Permission.bluetoothConnect.request().isGranted) {
        final serviceUuids = [
          Guid('19B10000-E8F2-537E-4F6C-D104768A1214'),
        ];
        await _flutterBlue.startScan(
            timeout: const Duration(seconds: 15), withServices: serviceUuids);
      }
    }
  }

  Future<void> stopScanning() async {
    await _flutterBlue.stopScan();
  }

  Future<void> connect(BluetoothDevice device) async {
    await device.connect();
  }

  Future<void> disconnect(BluetoothDevice device) async {
    await device.disconnect();
  }
}
