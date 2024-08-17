import 'dart:convert';

import 'package:falldetapp/config/Config.dart';
import 'package:falldetapp/domain/models/alerta.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  Future<bool> sendAlertToExternalApi(String sensor) async {
    Ubicacion ubicacion = await _getCurrentLocation();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('nombre');
    String? phone = prefs.getString('celular');
    DateTime fecha = DateTime.now();
    Alerta alerta = Alerta(dispositivo: "001", sensor: sensor, ubicacion: ubicacion, nombre: name!, telefono: phone!, fecha: fecha);

    return await _sendAlertToApi(alerta);
  }
  // Future<bool> apiPrueba() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? name = prefs.getString('nombre');
  //   String? phone = prefs.getString('celular');
  //   try {
  //     print("enviando a API...");
  //     final response = await http.post(
  //         Uri.parse("https://apidetfall.onrender.com/alerta"),
  //         headers: <String, String>{
  //           'Content-Type': 'application/json; charset=UTF-8',
  //         },
  //         body: jsonEncode(
  //             <String, String>{"mensaje": "Nombre de persona en emergencia: ${name} Celular:${phone}", "location": "prueba"}));
  //     return response.statusCode == 200;
  //   } catch (e) {
  //     print('Error al enviar alerta a API externa: $e');
  //     return false;
  //   }
  // }
  Future<Ubicacion> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    Ubicacion ubicacion = Ubicacion(latitud: position.latitude, longitud: position.longitude);
    //return "Lat: ${position.latitude}, Long: ${position.longitude}";
    return ubicacion;
  }

  Future<bool> _sendAlertToApi(Alerta alerta) async {    
    String url = '${Config.apiUrl}/alerta';
    String apiKey = Config.apiKey!;
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'X-API-Key': apiKey,
          'Content-Type': 'application/json',
        },
        body: alerta.toJson(),
      );
      return (response.statusCode == 200);
    } catch (e) {
      return false;
    }
  }
}
