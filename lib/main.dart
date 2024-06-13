import 'dart:io';
import 'dart:async';
import 'package:falldetapp/services/BLEService.dart';
import 'package:falldetapp/services/apiService.dart';
import 'package:falldetapp/services/notificactionService.dart';
import 'package:falldetapp/views/connection.dart';
import 'package:falldetapp/views/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  await initNotifications();
  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'DetFall',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        home: SplashScreen());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final BLEService _bleService = BLEService();
  BluetoothDevice? _connectedDevice;
  int _currentIndex = 0;
  final ApiService apiService = ApiService();

  //PRUEBAS
  int _signalCount = 0;
  Timer? _timer;
  bool _isAlertSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 225, 228, 229),
          elevation: 0,
          toolbarHeight: 80,
          centerTitle: false,
          titleSpacing: 0,
          title: Row(
            children: [
              Transform(
                transform: Matrix4.translationValues(10, 0, 0),
                child: const Text(
                  'DetFall',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(width: 15),
              Image.asset(
                './assets/images/alert_icon.png',
                height: 60,
                width: 80,
              ),
            ],
          )),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          ConnectionView(
            bleService: _bleService, // Pass the BLEManager instance
            connectedDevice: _connectedDevice,
            onDeviceConnected: (BluetoothDevice? device) async {
              setState(() {
                _connectedDevice = device;
              });

              if (device != null) {
                print('Connected to ${device.name}');
                List<BluetoothService> services =
                    await device.discoverServices();
                for (var service in services) {
                  if (service.uuid.toString() ==
                      '19b10000-e8f2-537e-4f6c-d104768a1214') {
                    print('Found the correct service');
                    var characteristics = service.characteristics;
                    for (BluetoothCharacteristic c in characteristics) {
                      if (c.uuid.toString() ==
                          '19b10001-e8f2-537e-4f6c-d104768a1214') {
                        print('Found the correct characteristic');
                        _listenToCharacteristic(c);
                      }
                    }
                  }
                }
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bluetooth_connected_rounded),
            label: 'Dectector',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_applications_rounded),
            label: 'Opciones',
          ),
        ],
        selectedItemColor: Color.fromARGB(255, 68, 170, 153),
      ),
    );
  }

  void _listenToCharacteristic(BluetoothCharacteristic c) {
    c.setNotifyValue(true);
    c.value.listen((value) {
      if (value.isNotEmpty && value[0] == 1) {
        if (_isAlertSent) {
          _signalCount = 0;
          _isAlertSent = false;
        }
        _timer?.cancel();
        _signalCount++;
        _timer = Timer(Duration(seconds: 15), () {
          setState(() {
            _signalCount = 0;
          });
        });

        if (_signalCount == 1) {
          _sendAlert();
          _signalCount = 0;
          _isAlertSent = true;
        }
      }
    });
  }

  Future<void> _sendAlert() async {
    print("ENVIANDO ALERTA...");
    // bool apiCallSuccess = (await externalApiService.sendAlertToExternalApi("https://200.10.147.201:5025/api/BotonPanic"));
    bool apiCallSuccess = (await apiService.apiPrueba());
    if (apiCallSuccess) {
      notificacionCaida();
      // showDialog(
      //   context: context,
      //   builder: (BuildContext context) {
      //     final alertDialog = AlertDialog(
      //       title: Text('Alerta'),
      //       content: Text('¡Alerta enviada!'),
      //       actions: [
      //         ElevatedButton(
      //           onPressed: () {
      //             Navigator.of(context).pop();
      //           },
      //           child: Text('Cerrar'),
      //         ),
      //       ],
      //     );

      //     Timer(Duration(seconds: 5), () {
      //       Navigator.of(context).pop();
      //     });

      //     return alertDialog;
      //   },
      // );
    } else {
      print('Failed to send alert to either Twilio or the external API.');
    }
  }
}
