import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InternetController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection(); // Verifica el estado de la conexión al iniciar
    _connectivity.onConnectivityChanged.listen(Netstatus);
  }

  // Verifica el estado de la conexión al iniciar
  void _checkInitialConnection() async {
    ConnectivityResult result = await _connectivity.checkConnectivity();
    Netstatus(result);
  }

  // ignore: non_constant_identifier_names
  void Netstatus(ConnectivityResult cr) {
    if (cr == ConnectivityResult.none) {
      Get.rawSnackbar(
        titleText: SizedBox(
          width: double.infinity,
          height: Get.size.height * (.954),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, color: Colors.white, size: 50),
              SizedBox(height: 10),
              Text('No internet connection', style: TextStyle(color: Colors.white, fontSize: 20)),
              SizedBox(height: 10),
              Text('Please check your internet connection', style: TextStyle(color: Colors.white, fontSize: 15)),
            ],
          ),
        ),
        messageText: Container(),
        backgroundColor: Colors.black87,
        isDismissible: false,
        duration: const Duration(days: 1),
      );
    } else {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
    }
  }
}