import 'dart:convert';
import 'dart:io';
import 'package:falldetapp/domain/models/log.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class LogService {
  late File _logFile;
  String apiURL = "";
  Future<void> _initLogFile() async {
    if (_logFile == null) {
      final directory = await getApplicationDocumentsDirectory();
      _logFile = File('${directory.path}/app_logs.txt');
      if (!(await _logFile.exists())) {
        await _logFile.create();
      }
    }
  }

  Future<void> writeLogEvent(Log log) async {
    await _initLogFile();
     final logJson = jsonEncode(log.toJson()) + '\n';
    await _logFile.writeAsString(logJson, mode: FileMode.append);
  }

  Future<void> sendToAPI() async {
    await _initLogFile();
    final logs = await _logFile!.readAsString();
    final logsArray = logs.split('\n').where((log) => log.isNotEmpty).map((log) => jsonDecode(log)).toList();
    print(logsArray);
    // final response = await http.post(
    //     Uri.parse(apiURL),
    //     headers: {'Content-Type': 'application/json'},
    //     body: jsonEncode(logsArray)
    // );
    // if(response.statusCode == 200){
    //   await _logFile.writeAsString('');
    // }else{
    //    throw Exception('Error al enviar logs: ${response.reasonPhrase}');
    // }
  }

   Future<void> clearLogFile() async {
    await _initLogFile();
    await _logFile!.writeAsString(''); // Escribir una cadena vacía para borrar el contenido
  }
}