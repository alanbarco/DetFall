// To parse this JSON data, do
//
//     final alerta = alertaFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

Alerta alertaFromJson(String str) => Alerta.fromJson(json.decode(str));

String alertaToJson(Alerta data) => json.encode(data.toJson());

class Alerta {
    Ubicacion ubicacion;
    String nombre;
    String telefono;
    String sensor;
    DateTime fecha;
    String dispositivo;

    Alerta({
        required this.ubicacion,
        required this.nombre,
        required this.telefono,
        required this.sensor,
        required this.fecha,
        required this.dispositivo,
    });

    factory Alerta.fromJson(Map<String, dynamic> json) => Alerta(
        ubicacion: Ubicacion.fromJson(json["ubicacion"]),
        nombre: json["nombre"],
        telefono: json["telefono"],
        sensor: json["sensor"],
        fecha: json["fecha"],
        dispositivo: json["dispositivo"],
    );

    Map<String, dynamic> toJson() => {
        "ubicacion": ubicacion.toJson(),
        "nombre": nombre,
        "telefono": telefono,
        "sensor": sensor,
        "fecha": fecha.toIso8601String(),
        "dispositivo": dispositivo,
    };
}

class Ubicacion {
    double latitud;
    double longitud;

    Ubicacion({
        required this.latitud,
        required this.longitud,
    });

    factory Ubicacion.fromJson(Map<String, dynamic> json) => Ubicacion(
        latitud: json["latitud"],
        longitud: json["longitud"],
    );

    Map<String, dynamic> toJson() => {
        "latitud": latitud,
        "longitud": longitud,
    };
}
