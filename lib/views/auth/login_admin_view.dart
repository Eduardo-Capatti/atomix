import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/session_controller.dart';

class LoginPageAdmin extends StatefulWidget {
  const LoginPageAdmin({super.key});

  @override
  State<LoginPageAdmin> createState() => _LoginPageStateAdmin();
}

class _LoginPageStateAdmin extends State<LoginPageAdmin> {
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtSenha = TextEditingController();
  final AuthController _authController = AuthController();

  bool esconderSenha = true;

  //Autenticação no banco
  Future<void> onLogin(BuildContext context) async {
    try {
      await _authController.loginAdmin(txtEmail.text, txtSenha.text);

      //login deu certo!
      if (mounted) {
        Navigator.pushReplacementNamed(context, "/moduloAdmin");
      }
    } on FirebaseAuthException catch (ex) {
      //Tratamento de erros (ex: senha errada, usuário não existe)
      String errorMessage = _authController.translateLoginError(ex);
      //Mostra o erro na tela para o usuário (SnackBar)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void initState(){
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
        if(await verificarSession()){
          print("logado");

          if(await verificarAdmin()){
            navegacaoSession(context, "/moduloAdmin");
          }else{
            navegacaoSession(context, "/modulos");
          }
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      // O Center e SingleChildScrollView ajudam a evitar erro de sobreposição do teclado
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  "Bem-vindo",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: txtEmail,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: "E-mail",
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: txtSenha,
                  obscureText: esconderSenha,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: "Senha",
                    prefixIcon: Icon(
                      Icons.password_outlined,
                      color: Colors.blue[800],
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          esconderSenha = !esconderSenha;
                        });
                      },
                      icon: Icon(
                        esconderSenha ? Icons.visibility_off : Icons.visibility,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 2, 115, 207),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(
                      50,
                    ), // Deixa o botão mais largo
                  ),
                  // 7. Muda a ação do botão para chamar a nossa nova função
                  onPressed: () => onLogin(context),
                  child: const Text("Entrar"),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "É aluno?",
                      style: TextStyle(color: Colors.blue[900]),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.only(left: 5.0),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      // Mantemos o pushNamed aqui pois o usuário pode querer apenas ir na tela de cadastro e voltar
                      onPressed: () => Navigator.pushNamed(context, "/"),
                      child: Text(
                        "Entrar como aluno",
                        style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight(900),),
                      ),
                    ),
                  ],
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
