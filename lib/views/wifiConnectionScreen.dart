import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class InternetController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  final FlutterBlue _flutterBlue = FlutterBlue.instance;

  @override
  void onInit() {
    super.onInit();
    _initialCheck();
    _connectivity.onConnectivityChanged.listen(_checkStatus);
    _flutterBlue.state.listen((state) {
      if (state == BluetoothState.off) {
        _showBluetoothDisconnectedMessage();
      } else if (state == BluetoothState.on && Get.isSnackbarOpen!) {
        Get.closeCurrentSnackbar();
      }
    });
  }

  Future<void> _initialCheck() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'));
      if (response.statusCode!= 200) {
        _showInternetDisconnectedMessage();
      }
    } catch (_) {
      _showInternetDisconnectedMessage();
    }

    var bluetoothState = await _flutterBlue.state.first;
    if (bluetoothState == BluetoothState.off) {
      _showBluetoothDisconnectedMessage();
    }
  }

  void _checkStatus(ConnectivityResult cr) {
    if (cr == ConnectivityResult.none) {
      _showInternetDisconnectedMessage();
    } else {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
    }
  }

  void _showInternetDisconnectedMessage() {
    Get.rawSnackbar(
      titleText: SizedBox(
        width: double.infinity,
        height: Get.size.height * (.954),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, color: Colors.white, size: 50),
            SizedBox(height: 10),
            Text('No hay conexión a Internet', style: TextStyle(color: Colors.white, fontSize: 20)),
            SizedBox(height: 10),
            Text('Por favor verifique su conexión a Internet', style: TextStyle(color: Colors.white, fontSize: 15)),
          ],
        ),
      ),
      messageText: Container(),
      backgroundColor: Colors.black87,
      isDismissible: false,
      duration: const Duration(days: 1),
    );
  }

  void _showBluetoothDisconnectedMessage() {
    Get.rawSnackbar(
      titleText: SizedBox(
        width: double.infinity,
        height: Get.size.height * (.954),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bluetooth_disabled, color: Colors.white, size: 50),
            SizedBox(height: 10),
            Text('No hay conexión a Bluetooth', style: TextStyle(color: Colors.white, fontSize: 20)),
            SizedBox(height: 10),
            Text('Por favor active Bluetooth', style: TextStyle(color: Colors.white, fontSize: 15)),
          ],
        ),
      ),
      messageText: Container(),
      backgroundColor: Colors.black87,
      isDismissible: false,
      duration: const Duration(days: 1),
    );
  }
}
