import 'dart:convert';

import 'package:falldetapp/services/BLEService.dart';
import 'package:falldetapp/services/notificactionService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
class ConnectionView extends StatefulWidget {
  final BLEService bleService;
  final void Function(BluetoothDevice?) onDeviceConnected;
  final BluetoothDevice? connectedDevice;

  const ConnectionView({
    required this.bleService,
    required this.onDeviceConnected,
    required this.connectedDevice,
  });

  @override
  _ConnectionViewState createState() => _ConnectionViewState();
}

class _ConnectionViewState extends State<ConnectionView> {  
  StreamSubscription? _scanSubscription;
  List<BluetoothDevice> filteredDevices = [];
  List<BluetoothDevice> connectedDevices = [];

  @override
  void initState() {
    super.initState();
    startScanning();
  }

  void startScanning() {
    widget.bleService.startScanning();
    _scanSubscription =
        widget.bleService.flutterBlue.isScanning.listen((isScanning) {
      if (!isScanning) {
        widget.bleService.startScanning();
      }
    });
  }

  @override
  void dispose() {
    widget.bleService.stopScanning();
    _scanSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // List<BluetoothDevice> filteredDevices = [];
    return StreamBuilder<List<ScanResult>>(
      stream: widget.bleService.flutterBlue.scanResults,
      initialData: [],
      builder: (context, snapshot) {
        final scanResults = snapshot.data!;
        filteredDevices = scanResults
            .map((scanResult) => scanResult.device)
            .where((device) => device.name.isNotEmpty)
            .toList();

        if (widget.connectedDevice != null) {
          notificacionConexion();
          return Center(
            child: Container(
              height: 400,
              width: 400,
              child: Card(
                  color: Color.fromARGB(255, 251, 254, 255),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ListTile(
                            title: Center(
                          child: Text(
                              'Detector conectado correctamente!',
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                        )),
                        // Image.asset('assets/images/alert_icon.png', height: 150),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Color.fromARGB(221, 20, 70, 124),
                            onPrimary: Colors.white,
                            fixedSize: const Size(200, 50),
                          ),
                          onPressed: () async {
                            await widget.bleService
                                .disconnect(widget.connectedDevice!);
                            widget.onDeviceConnected(null);
                          },
                          child: const Text('Desconectar'),
                        ),
                      ])),
            ),
          );
        } else if (filteredDevices.isEmpty) {
          return Column(
            children: [
              SizedBox(height: 160),
              const Center(
                child: Text(
                  'Detector no encontrado',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              // Center(
              //   child: ElevatedButton(
              //     onPressed: () => apiPrueba(),
              //     child: Text('Haz clic aquí'),
              //   ),
              // )
            ],
          );
        } else {
          return ListView.builder(
            itemCount: filteredDevices.length,
            itemBuilder: (context, index) {
              final device = filteredDevices[index];
              return Card(
                margin: const EdgeInsets.all(40),
                color: Colors.black87,
                elevation: 2,
                child: ListTile(
                  title: Center(
                      child: Text(
                    device.name,
                    style: const TextStyle(color: Colors.white),
                  )),
                  //subtitle: Text(device.id.toString()),
                  onTap: () async {
                          if (connectedDevices.length < 2 && !connectedDevices.contains(device)) {
                            await widget.bleService.stopScanning();
                            await widget.bleService.connect(device);
                            setState(() {
                              connectedDevices.add(device);
                            });
                            widget.onDeviceConnected(device);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('ERROR.'))
                            );
                          }
                        },
                ),
              );
            },
          );
        }
      },
    );
  }
}
  Future<bool> apiPrueba() async {
    try {
      final response = await http.post(
          Uri.parse("http://192.168.100.60:8000/alerta"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(
              <String, String>{"mensaje": "prueba", "location": "prueba"}));
      if (response.statusCode == 200) {
        return true;
      }else{
        return false;
      }
    } catch (e) {
      print('Error al enviar alerta a API externa: $e');
      return false;
    }
  }