import 'package:falldetapp/providers/buttonProvider.dart';
import 'package:falldetapp/providers/devicesProvider.dart';
import 'package:falldetapp/services/BLEService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'package:provider/provider.dart';

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
  List<BluetoothDevice> filteredDevices = [];
  List<BluetoothDevice> connectedDevices = [];
  bool hasFallDetectorConnected = false;
  bool hasVoiceDetectorConnected = false;
  var devicesProvider;
  var buttonProvider;

  @override
  void initState() {
    super.initState();
    devicesProvider = Provider.of<DevicesProvider>(context, listen: false);
    buttonProvider = Provider.of<ButtonProvider>(context, listen: false);
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
    _disconnectSubscription =
        widget.bleService.deviceDisconnectedStream?.listen((device) {
      setState(() {
        connectedDevices.remove(device);
        devicesProvider.remove(device);
        if (devicesProvider.devices.isEmpty) {
          buttonProvider.changeStatus(true);
        }
        widget.onDevicesConnected(connectedDevices);
        device.disconnect();
      });
    });
  }

  void connectToDevices() async {
    buttonProvider.changeStatus(false);
    setState(() {
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

    await Future.delayed(Duration(seconds: 30));
    buttonProvider.changeStatus(true);
    setState(() {
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
    final devicesProviderWatch = context.read<DevicesProvider>().devices;
    final buttonProviderWatch = context.read<ButtonProvider>();

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
          hasFallDetectorConnected = devicesProviderWatch.any((device) {
            return device.name.contains("DetFall");
          });
          bool hasVoiceDetectorConnected = devicesProviderWatch.any((device) {
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
              } else if (hasVoiceDetectorConnected ||
                  hasFallDetectorConnected) {
                return Center(
                  child: Container(
                    height: 500,
                    width: 400,
                    child: Card(
                        color: Color.fromARGB(255, 251, 254, 255),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Colors.blue[900]!, // Azul marino
                            width: 2.0, // Ancho del borde
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(
                                Icons.sensors,
                                size: 100,
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
                                              30), // Espacio entre los textos
                                      Text(
                                        'El detector está configurado para: ',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 20), //
                                      hasVoiceDetectorConnected
                                          ? ListTile(
                                              leading: Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                              ),
                                              title: Text(
                                                'Voz',
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      SizedBox(height: 8),
                                      hasFallDetectorConnected
                                          ? ListTile(
                                              leading: Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                              ),
                                              title: Text(
                                                'Movimientos',
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            )
                                          : Container(),
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
              } else {
                return Column(
                  children: [
                    SizedBox(height: 160),
                    const Center(
                      child: Text(
                        'Detector no encontrado',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
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
            SizedBox(height: 30),
            Icon(
              Icons.bluetooth,
              size: 90,
              color: Colors.blue,
            ),
            SizedBox(height: 80),
            ListTile(
              title: Text(
                'Sensores disponibles:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            hasFallDetector
                ? ListTile(
                    leading: Icon(
                      Icons.horizontal_rule,
                      color: Colors.black,
                    ),
                    title: Text('Movimientos'),
                  )
                : Container(),
            SizedBox(height: 20),
            hasVoiceDetector
                ? ListTile(
                    leading: Icon(
                      Icons.horizontal_rule,
                      color: Colors.black,
                    ),
                    title: Text('Voz'),
                  )
                : Container(),
            SizedBox(height: 40),
            Container(
                height: 70,
                width: 320,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(221, 20, 70, 124),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      textStyle: TextStyle(fontSize: 20),
                      foregroundColor: Colors.white),
                  onPressed:
                      buttonProviderWatch.activo ? connectToDevices : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bluetooth_connected,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Text('Conectar detector'),
                    ],
                  ),
                ))
          ]);
        }
      },
    );
  }
}
