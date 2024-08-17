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
        "nombreDispositivo": nombreDispositivo,
        "evento": evento,
        "detalles": detalles.toJson(),
    };
}

class Detalles {
    String tipoEvento;
    List<String> sensores;
    String? sensor;
    String accion;
    Detalles({
        required this.tipoEvento,
        required this.sensores,
        required this.accion
    });


    Map<String, dynamic> toJson() => {
        "tipoEvento": tipoEvento,
        "sensores": List<dynamic>.from(sensores.map((x) => x)),
        "sensor": sensor,
        "accion": accion
    };
}