import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtSenha = TextEditingController();

  bool esconderSenha = true; // controla visibilidade

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_person_outlined,
              size: 80,
              color: Colors.blue[900],
            ),
            SizedBox(height: 20),

            Text(
              "Bem-vindo",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            SizedBox(height: 20),

            TextField(
              controller: txtEmail,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "E-mail",
                prefixIcon: Icon(Icons.email_outlined, color: Colors.blue[800]),
              ),
            ),
            SizedBox(height: 20),

            TextField(
              controller: txtSenha,
              obscureText: esconderSenha,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Senha",
                prefixIcon: Icon(Icons.password_outlined, color: Colors.blue[800]),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      esconderSenha = !esconderSenha; // alterna estado
                    });
                  },
                  icon: Icon(
                    esconderSenha
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.blue[800],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 2, 115, 207),
                foregroundColor: Colors.white,
              ),
              onPressed: () =>
                  Navigator.pushNamed(context, "/modulos"),
              child: Text("Entrar"),
            ),

            TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, "/cadastro"),
              child: Text(
                "Cadastrar-se",
                style: TextStyle(color: Colors.blue[900]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}