// class LogService{
//   static Future<void> sendLog(String mensaje){
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? name = prefs.getString('nombre');
//     String? phone = prefs.getString('celular');
//     try {
//       print("enviando a API...");
//       final response = await http.post(
//           Uri.parse("https://apidetfall.onrender.com/alerta"),
//           headers: <String, String>{
//             'Content-Type': 'application/json; charset=UTF-8',
//           },
//           body: jsonEncode(
//               <String, String>{"mensaje": "Nombre de persona en emergencia: ${name} Celular:${phone}", "location": "prueba"}));
//       if (response.statusCode == 200) {
//         return true;
//       }else{
//         return false;
//       }
//     } catch (e) {
//       print('Error al enviar alerta a API externa: $e');
//       return false;
//     }
//   }
// }