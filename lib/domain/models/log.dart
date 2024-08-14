import 'package:meta/meta.dart';
import 'dart:convert';

String logToJson(Log data) => json.encode(data.toJson());

class Log {
    DateTime timestamp;
    String nombreDispositivo;
    String evento;
    Detalles detalles;

    Log({
        required this.timestamp,
        required this.nombreDispositivo,
        required this.evento,
        required this.detalles,
    });

    Map<String, dynamic> toJson() => {
        "timestamp": timestamp.toIso8601String(),
        "nombre_dispositivo": nombreDispositivo,
        "evento": evento,
        "detalles": detalles.toJson(),
    };
}

class Detalles {
    String tipoEvento;
    List<String> sensores;
    String accion;
    Detalles({
        required this.tipoEvento,
        required this.sensores,
        required this.accion
    });


    Map<String, dynamic> toJson() => {
        "tipo_evento": tipoEvento,
        "sensores_enlazados": List<dynamic>.from(sensores.map((x) => x)),
        "accion": accion
    };
}