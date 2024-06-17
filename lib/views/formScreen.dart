import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class FormScreen extends StatefulWidget {
  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  _saveForm() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('nombre', _nameController.text);
      await prefs.setString('celular', _phoneController.text);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Text("Por favor ingresa tus datos para continuar",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 50),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre completo',
                  labelStyle: TextStyle(color: Colors.black), // Color del label
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Color.fromARGB(
                            221, 20, 70, 124)), // Borde cuando está enfocado
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black), // Borde cuando está habilitado
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu nombre y apellido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Número Celular',
                  labelStyle: TextStyle(color: Colors.black), // Color del label
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Color.fromARGB(
                            221, 20, 70, 124)), // Borde cuando está enfocado
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black), // Borde cuando está habilitado
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu número celular';
                  } else if (value.length != 10) {
                    return 'El número celular debe tener 10 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: 50),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(221, 20, 70, 124),
                    onPrimary: Colors.white,
                    minimumSize: Size(double.infinity, 50)),
                onPressed: _saveForm,
                child: Text('Enviar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
