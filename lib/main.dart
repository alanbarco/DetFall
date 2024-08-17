import 'dart:io';
import 'dart:async';
import 'package:falldetapp/domain/models/log.dart';
import 'package:falldetapp/providers/buttonProvider.dart';
import 'package:falldetapp/providers/devicesProvider.dart';
import 'package:falldetapp/services/BLEService.dart';
import 'package:falldetapp/services/apiService.dart';
import 'package:falldetapp/services/logService.dart';
import 'package:falldetapp/services/notificactionService.dart';
import 'package:falldetapp/utils/util.dart';
import 'package:falldetapp/views/connectionScreen.dart';
import 'package:falldetapp/views/profileScreen.dart';
import 'package:falldetapp/views/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:timer_count_down/timer_count_down.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  HttpOverrides.global = MyHttpOverrides();
  await initNotifications();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => DevicesProvider()),
    ChangeNotifierProvider(create: (context) => ButtonProvider())
  ], child: MyApp()));
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
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'DetFall',
          theme: ThemeData(
            primarySwatch: colorCustom,
          ),
          home: child,
        );
      },
      child: SplashScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  final BLEService _bleService = BLEService();
  List<BluetoothDevice> _connectedDevices = [];
  int _currentIndex = 0;
  final ApiService apiService = ApiService();
  late Timer _timerCard;
  int _remainingTime = 60; // Tiempo en segundos
  String? sensor = '';
  late ValueNotifier<int> _countdownNotifier;
  Map<String, String> idCaracteristas = {"19b10001-e8f2-537e-4f6c-d104768a1214": "Movimientos"
  ,"143c87e6-058a-43e7-9d75-fbbea5c3c157": "Voz"};

  List<String> get serviciosBLE => [
    "143c87e6-058a-43e7-9d75-fbbea5c3c157",
    "19b10000-e8f2-537e-4f6c-d104768a1214",
    "19b10001-e8f2-537e-4f6c-d104768a1214"
  ];
  List<String> sensores = [];
  int _signalCount = 0;
  Timer? _timer;
  bool _isAlertSending = false;
  bool segundoPlano = false;
  bool _isDialogShowing = false;
  var buttonProvider;
  ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  final LogService logService = LogService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _countdownNotifier = ValueNotifier<int>(_remainingTime);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    var devicesProvider = Provider.of<DevicesProvider>(context);

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 25, 40, 76),
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
                    color: Color.fromRGBO(255, 255, 255, 1),
                  ),
                ),
              ),
              SizedBox(width: 15),
              Image.asset(
                './assets/images/logo.png',
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
                devicesProvider.add(device);
                try {
                  BluetoothDeviceState state = await device.state.first;
                  if (state == BluetoothDeviceState.connected) {
                    List<BluetoothService> services =
                        await device.discoverServices();
                    for (var service in services) {
                      if (serviciosBLE.contains(service.uuid.toString())) {
                        _isLoading.value = true;
                        var characteristics = service.characteristics;
                        for (BluetoothCharacteristic c in characteristics) {
                          if (serviciosBLE.contains(c.uuid.toString())) {
                            _listenToCharacteristic(c);
                          }
                        }
                        _isLoading.value = false;
                      }
                    }
                  } else {
                    // Si no está conectado, conéctate primero
                    await device.connect();
                    // Verifica nuevamente si el dispositivo está conectado
                    state = await device.state.first;
                    if (state == BluetoothDeviceState.connected) {
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
                    } else {
                      print('Error: El dispositivo no se pudo conectar.');
                    }
                  }
                } on PlatformException catch (e) {
                  if (e.code == 'already_connected') {
                    print('Error: El dispositivo ya está conectado.');
                  } else {
                    print('Error: $e');
                  }
                } catch (e) {
                  print('Error: $e');
                }
                            }
              devices = [];
            },
            isLoading: _isLoading,
          ),
          ProfileScreen(),
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
        selectedItemColor: Color.fromARGB(255, 39, 58, 129),
      ),
    );
  }

  
  void _listenToCharacteristic(BluetoothCharacteristic c) {
    sensores = [];
    c.setNotifyValue(true);
    c.value.listen((value) {
      if (value.isNotEmpty) {
        String stringValue = String.fromCharCodes(value);

        if (stringValue[0] == '1') {
          String data = stringValue.substring(2); 

          _timer?.cancel();
          if (_isAlertSending) {
            _isAlertSending = false;
          } else {
            _signalCount++;
          }

          _timer = Timer(Duration(seconds: 15), () {
            setState(() {
              _signalCount = 0;
            });
          });

          if (_signalCount > 0) {
            sensor = idCaracteristas[c.uuid.toString()];
            sensores.add(sensor!);
            _sendAlert();
            _signalCount = 0;
          }
        }
      }
    });
  }

  Future<void> _sendAlert() async {
    _isAlertSending = true;
    await showNotificationWithSound();
    if (!_isDialogShowing) {
      _showFallDetectedCard();
    }    
  }

  void _startCountdown() {
     _remainingTime = 60;
    _timerCard = Timer.periodic(Duration(milliseconds: 1100), (timer) {
      _remainingTime--;
      _countdownNotifier.value = _remainingTime;
      if (_remainingTime <= 0) {
        _timerCard.cancel();        
        
        if(_isDialogShowing){
          Navigator.of(context).pop();
          _isDialogShowing = false;
        }
        _sendAlertToApi();
        _remainingTime = 60;
      }
    });
  }
  Future<void> _sendAlertToApi() async {
    bool apiCallSuccess = await apiService.sendAlertToExternalApi(sensor!);
    if (apiCallSuccess) {
      notificacionCaida();
      Detalles detalle = Detalles(tipoEvento:"alerta", sensores:sensores, accion: "Envío de alerta exitoso");
      Log logEvent = Log(timestamp: DateTime.now(), nombreDispositivo: '001', evento: "Envío de alerta exitoso", detalles: detalle);
      logService.writeLogEvent(logEvent);
    } else {
      notificacionCaidaError();
      Detalles detalle = Detalles(tipoEvento:"alerta", sensores:sensores, accion: "Envío de alerta fallido");
      Log logEvent = Log(timestamp: DateTime.now(), nombreDispositivo: '001', evento: "Envío de alerta fallido", detalles: detalle);
      logService.writeLogEvent(logEvent);
    }
    _isAlertSending = false;
  }


  void _showFallDetectedCard() async {
    _startCountdown();
    setState(() {
      _isDialogShowing = true;
    });
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color.fromARGB(255, 246, 246, 246),
            title: Text(
              'ALERTA DE EMERGENCIA',
              style: TextStyle(
                  color: const Color.fromARGB(255, 237, 0, 0),
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            content: ValueListenableBuilder<int>(
            valueListenable: _countdownNotifier,
            builder: (context, value, child) {
              return Text(
                'Se detectó una señal de emergencia, descartar en $value segundos si no es correcto.',
                style: TextStyle(
                    color: Color.fromARGB(255, 19, 43, 146),
                    fontWeight: FontWeight.bold),
              );
            },
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 239, 22, 22),
                  onPrimary: Colors.white,
                ),
                onPressed: () async {
                  await flutterLocalNotificationsPlugin.cancel(0);
                  Detalles detalle = Detalles(tipoEvento:"alerta", sensores:sensores, accion: "Rechazo de alerta");
                  Log logEvent = Log(timestamp: DateTime.now(), nombreDispositivo: '001', evento: "Rechazo de alerta", detalles: detalle);
                  logService.writeLogEvent(logEvent);
                  setState(() {
                    _isDialogShowing = false;
                    _isAlertSending = false;
                    _timerCard.cancel();
                    _remainingTime = 60;
                  });
                  Navigator.of(context).pop();
                },
                child: Text('DESCARTAR'),
              ),
            ],
          );
        });
  }
}
