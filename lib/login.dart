import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Future<void>? _loginFuture;

  void _login() {
    _loginFuture = _attemptLogin();
  }

  Future<void> _attemptLogin() async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'username': _usernameController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => MainPage()));
    } else {
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erreur'),
          content: Text('Les données que vous avez saisies sont incorrects'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUsernameField() {
    return TextField(
      controller: _usernameController,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: 'Nom d\'utilisateur',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        fillColor: Colors.white,
        filled: true,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      textAlign: TextAlign.center,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Mot de passe',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        fillColor: Colors.white,
        filled: true,
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: () => _login(),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      ),
      child: Text('Se connecter',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Connexion",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildUsernameField(),
              SizedBox(height: 20),
              _buildPasswordField(),
              SizedBox(height: 40),
              FutureBuilder<void>(
                future: _loginFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else {
                    return _buildLoginButton();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
