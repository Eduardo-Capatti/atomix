import 'package:flutter/material.dart';

class CadastroPage extends StatefulWidget {
  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  TextEditingController txtNome = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtSenha = TextEditingController();
  TextEditingController txtRepetirSenha = TextEditingController();

  bool esconderSenha = true;
  bool esconderRepetirSenha = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.blue[900],
      ),

      body: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add_outlined,
              size: 80,
              color: Colors.blue[900],
            ),

            SizedBox(height: 16),

            Text(
              "Cadastro",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),

            SizedBox(height: 16),

            TextField(
              controller: txtNome,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Nome",
                prefixIcon:
                    Icon(Icons.person_outline, color: Colors.blue[800]),
              ),
            ),

            SizedBox(height: 16),

            TextField(
              controller: txtEmail,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "E-mail",
                prefixIcon:
                    Icon(Icons.email_outlined, color: Colors.blue[800]),
              ),
            ),

            SizedBox(height: 16),

            TextField(
              controller: txtSenha,
              obscureText: esconderSenha,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Senha",
                prefixIcon:
                    Icon(Icons.password_outlined, color: Colors.blue[800]),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      esconderSenha = !esconderSenha;
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

            SizedBox(height: 16),

            TextField(
              controller: txtRepetirSenha,
              obscureText: esconderRepetirSenha,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Repetir senha",
                prefixIcon:
                    Icon(Icons.password_outlined, color: Colors.blue[800]),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      esconderRepetirSenha = !esconderRepetirSenha;
                    });
                  },
                  icon: Icon(
                    esconderRepetirSenha
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.blue[800],
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
              ),
              onPressed: () =>
                  Navigator.pushNamed(context, "/modulos"),
              child: Text("Criar conta"),
            ),
          ],
        ),
      ),
    );
  }
}