import 'dart:convert';
import 'dart:io';
import 'package:falldetapp/config/Config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:falldetapp/domain/models/log.dart';

class LogService {
  late File _logFile;
  String apiURL = "";

  Future<File> _getLogFile() async {
    final directory = await getApplicationDocumentsDirectory();
    _logFile = File('${directory.path}/app_logs.txt');
    if (!(await _logFile.exists())) {
      await _logFile.create();
    }
    return _logFile;
  }

  Future<void> writeLogEvent(Log log) async {
    final logFile = await _getLogFile();
    final logJson = jsonEncode(log.toJson()) + '\n';
    await logFile.writeAsString(logJson, mode: FileMode.append);
  }

  Future<void> sendToAPI() async {
    final logFile = await _getLogFile();
    final logs = await logFile.readAsString();
    final logsArray = logs
        .split('\n')
        .where((log) => log.isNotEmpty)
        .map((log) => jsonDecode(log))
        .toList();
    String url = '${Config.apiUrl}/alerta';
    String apiKey = Config.apiKey!;
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'X-API-Key': apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(logsArray), 
      );
      if (response.statusCode == 200) {
        await clearLogFile(); 
      } else {
        print('Error al enviar datos: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción: $e');
    }
  }

  Future<void> clearLogFile() async {
    final logFile = await _getLogFile();
    await logFile.writeAsString('');
  }
}
