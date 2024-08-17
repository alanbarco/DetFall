import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController _nombreController = TextEditingController();
  TextEditingController _celularController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nombreController.text = prefs.getString('nombre') ?? '';
      _celularController.text = prefs.getString('celular') ?? '';
    });
  }

  Future<void> _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('nombre', _nombreController.text);
    await prefs.setString('celular', _celularController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.person,
              size: 30, 
            ),
            SizedBox(width: 10),
            Text(
              'Perfil',
              style: TextStyle(
                fontSize: 30, 
                fontWeight: FontWeight.bold, 
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nombre'),
              enabled: _isEditing,
            ),
            TextField(
              controller: _celularController,
              decoration: InputDecoration(labelText: 'Celular'),
              enabled: _isEditing,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 68, 117, 170),
                    onPrimary: Colors.white,
                    fixedSize: const Size(150, 50),
                  ),
                  child: Text(_isEditing ? 'Cancelar' : 'Editar'),
                ),
                if (_isEditing)
                  ElevatedButton(
                    onPressed: () async {
                      await _savePreferences();
                      setState(() {
                        _isEditing = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 68, 117, 170),
                      onPrimary: Colors.white,
                      fixedSize: const Size(150, 50),
                    ),
                    child: Text('Aceptar'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _celularController.dispose();
    super.dispose();
  }
}
