import 'dart:convert';
import 'package:falldetapp/providers/devicesProvider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:falldetapp/services/BLEService.dart';
import 'package:falldetapp/services/notificactionService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:timer_count_down/timer_count_down.dart';

class ConnectionView extends StatefulWidget {
  final BLEService bleService;
  final void Function(List<BluetoothDevice>) onDevicesConnected;
  final List<BluetoothDevice>? connectedDevices;
  final ValueNotifier<bool> isLoading;

  const ConnectionView({
    required this.bleService,
    required this.isLoading,
    required this.onDevicesConnected,
    required this.connectedDevices,
  });

  @override
  _ConnectionViewState createState() => _ConnectionViewState();
}

class _ConnectionViewState extends State<ConnectionView> {
  StreamSubscription? _scanSubscription;
  late StreamSubscription<BluetoothDevice>? _disconnectSubscription;
  bool _isLoading = true;
  Map<String, bool> _connectionStatus = {};
  List<BluetoothDevice> filteredDevices = [];
  List<BluetoothDevice> connectedDevices = [];
  bool _isButtonEnabled = true;
  bool hasFallDetectorConnected = false;
  bool hasVoiceDetectorConnected = false;
  var devicesProvider;
  

  @override
  void initState() {
    super.initState();
    devicesProvider = Provider.of<DevicesProvider>(context, listen: false);    
    startScanning();
  }

  void startScanning() async {
    widget.bleService.startScanning();
    _scanSubscription =
        widget.bleService.flutterBlue.isScanning.listen((isScanning) {
      if (!isScanning) {
        widget.bleService.startScanning();
      }
    });
    subscriptionDevices();
  }

  void subscriptionDevices() {
    _disconnectSubscription = widget.bleService.deviceDisconnectedStream?.listen((device) {
      setState(() {
        connectedDevices.remove(device);
        devicesProvider.remove(device);
        widget.onDevicesConnected(connectedDevices);
      });
    });
  }

  void connectToDevices() async {
    setState(() {
      _isButtonEnabled = false;
      _isLoading = true;
    });
    for (var device in filteredDevices) {
      if (!connectedDevices.contains(device)) {
        await widget.bleService.connect(device);
        devicesProvider.add(device);
        setState(() {
          connectedDevices.add(device);
        });
      }
    }
    widget.onDevicesConnected(connectedDevices);

    await Future.delayed(Duration(seconds: 60));
    setState(() {
      _isButtonEnabled = true;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    widget.bleService.stopScanning();
    _scanSubscription?.cancel();
    _disconnectSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> serviceUuids = [
      "143c87e6-058a-43e7-9d75-fbbea5c3c157",
      "19b10000-e8f2-537e-4f6c-d104768a1214",
    ];
    final sachaUuid = '143c87e6-058a-43e7-9d75-fbbea5c3c157';
    final caidaUuid = '19b10000-e8f2-537e-4f6c-d104768a1214';
    final devicesProviderWatch = context.watch<DevicesProvider>().devices;
    bool allDevicesConnected =
        _connectionStatus.values.every((isConnected) => isConnected);
    bool noDevicesConnected =
        _connectionStatus.values.every((isConnected) => !isConnected);

    return StreamBuilder<List<ScanResult>>(
      stream: widget.bleService.flutterBlue.scanResults,
      initialData: [],
      builder: (context, snapshot) {
        final scanResults = snapshot.data!;
        filteredDevices = scanResults.map((result) => result.device).toList();

        bool hasFallDetector = filteredDevices.any((device) {
          return device.name.contains("DetFall");
        });
        bool hasVoiceDetector = filteredDevices.any((device) {
          return device.name.contains("Sacha");
        });
        if (devicesProviderWatch.isNotEmpty) {
           hasFallDetectorConnected =
              devicesProviderWatch.any((device) {
            return device.name.contains("DetFall");
          });
          bool hasVoiceDetectorConnected =
              devicesProviderWatch.any((device) {
            return device.name.contains("Sacha");
          });
          return ValueListenableBuilder<bool>(
            valueListenable: widget.isLoading,
            builder: (context, isLoading, child) {
              if (_isLoading) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 5.0,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Enlazando detector',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
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
                              SvgPicture.asset(
                                'assets/images/check.svg',
                                height: 100,
                                width: 100,
                              ),
                              ListTile(
                                title: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '¡Enlace exitoso!',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                          height:
                                              8), // Espacio entre los textos
                                      Text(
                                        'El detector está configurado para: ',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        hasVoiceDetectorConnected ? 'Voz' : '',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      SizedBox(
                                          height:
                                              8), // Espacio entre los textos
                                      Text(
                                        hasFallDetectorConnected
                                            ? 'Movimientos'
                                            : '',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Color.fromARGB(221, 20, 70, 124),
                                  onPrimary: Colors.white,
                                  fixedSize: const Size(200, 50),
                                ),
                                onPressed: () async {
                                  for (var device in widget.connectedDevices!) {
                                    await widget.bleService.disconnect(device);
                                    widget.onDevicesConnected([]);
                                  }
                                },
                                child: const Text('Desconectar'),
                              ),
                            ])),
                  ),
                );
              }
            },
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
            ],
          );
        } else {
          return Column(children: [
            SizedBox(width: 40),
            SvgPicture.asset(
              'assets/images/ble.svg',
              height: 100,
              width: 100,
            ),
            ListTile(
              title: Text(
                'Sensores disponibles:',
                style: TextStyle(
                  fontSize: 20, // Tamaño del texto
                  fontWeight: FontWeight
                      .bold, // Estilo en negrita Color del texto Espaciado entre letras
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              title: Text('Movimientos'),
            ),
            ListTile(
              leading: Icon(
                hasVoiceDetector ? Icons.check_circle : Icons.cancel,
                color: hasVoiceDetector ? Colors.green : Colors.red,
              ),
              title: Text('Voz'),
            ),
            Container(
                height: 250,
                child: Card(
                  margin: const EdgeInsets.all(40),
                  color: Color.fromARGB(221, 20, 70, 124),
                  elevation: 2,
                  child: ListTile(
                    title: Center(
                        child: Text(
                      'Presiona para enlazar el detector',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    )),
                    onTap: _isButtonEnabled ? connectToDevices : null,
                  ),
                ))
          ]);
        }
      },
    );
  }
}
