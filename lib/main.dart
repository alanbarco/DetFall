import 'dart:io';
import 'dart:async';
import 'package:falldetapp/services/BLEService.dart';
import 'package:falldetapp/services/apiService.dart';
import 'package:falldetapp/services/notificactionService.dart';
import 'package:falldetapp/views/connectionScreen.dart';
import 'package:falldetapp/views/wifiConnectionScreen.dart';
import 'package:falldetapp/views/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  await initNotifications();
  Get.put(InternetController(), permanent: true);
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
    return GetMaterialApp(
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

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver{
  final BLEService _bleService = BLEService();
  List<BluetoothDevice> _connectedDevices = [];
  int _currentIndex = 0;
  final ApiService apiService = ApiService();
  // List<String> serviciosBLE = [
  //   "143c87e6-058a-43e7-9d75-fbbea5c3c157",
  //   "19b10000-e8f2-537e-4f6c-d104768a1214"
  // ];
  List<String> serviciosBLE = [
    "143c87e6-058a-43e7-9d75-fbbea5c3c157"
  ];
  //PRUEBAS
  int _signalCount = 0;
  Timer? _timer;
  bool _isAlertSent = false;

  @override
  void initState() {
    super.initState();
    // Escucha eventos cuando la app está en foreground
    WidgetsBinding.instance.addObserver(this);
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }
   @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Mostrar diálogo cuando la aplicación vuelve al primer plano
      if (_isAlertSent) {
        _showFallDetectedDialog();
      }
    }
  }

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
            connectedDevices: _connectedDevices,
            onDevicesConnected: (List<BluetoothDevice> devices) async {
              setState(() {
                _connectedDevices = devices;
              });
              for (var device in devices) {
                if (device != null) {
                  List<BluetoothService> services =
                      await device.discoverServices();
                  for (var service in services) {
                    if (serviciosBLE.contains(service.uuid.toString())) {
                      var characteristics = service.characteristics;
                      for (BluetoothCharacteristic c in characteristics) {
                        if (serviciosBLE.contains(c.uuid.toString())) {
                          _listenToCharacteristic(c);
                        }
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
            icon: Icon(Icons.person_rounded),
            label: 'Perfil',
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
        _timer?.cancel();

        if (_isAlertSent) {
          _isAlertSent = false;
        } else {
          _signalCount++;
        }

        _timer = Timer(Duration(seconds: 15), () {
          setState(() {
            _signalCount = 0;
          });
        });

        if (_signalCount == 1) {
          _sendAlert();
          _isAlertSent = true;
          _signalCount = 0;
        }
      }
    });
  }

  Future<void> _sendAlert() async {
    _isAlertSent = true;
    await showNotificationWithSound();
     _timer = Timer(Duration(minutes: 1), () async {
      if (_isAlertSent) {
        print("ENVIANDO ALERTA...");
        bool apiCallSuccess = await apiService.apiPrueba();
        if (apiCallSuccess) {
          notificacionCaida();
        } else {
          print('Fallo al enviar la alerta a la API.');
        }
        _isAlertSent = false;
      }
    });
  }
  void _showFallDetectedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alerta'),
          content: Text('Se detectó una caída, ¿es correcto?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                // User pressed NO, cancel the alert and reset the state
                _isAlertSent = false;
                _signalCount = 0;
                _timer?.cancel();
                await flutterLocalNotificationsPlugin.cancel(0);
                Navigator.of(context).pop();
              },
              child: Text('NO'),
            ),
          ],
        );
      },
    );
  }
}
