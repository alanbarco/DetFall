import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static String? get apiUrl => dotenv.env['API_ESPOL_ALERT'] ;
  static String? get apiKey => dotenv.env['API_KEY'] ;
}
