//Importação necessária para o login
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/session_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtSenha = TextEditingController();
  final AuthController _authController = AuthController();

  bool esconderSenha = true;

  //Autenticação no banco
  Future<void> onLogin(BuildContext context) async {
    try {
      await _authController.login(txtEmail.text, txtSenha.text);

      //login deu certo!
      if (mounted) {
        //"/home" para ir direto para o MenuPrincipal criado
        Navigator.pushReplacementNamed(context, "/modulos");
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
                      "Não tem uma conta?",
                      style: TextStyle(color: Colors.blue[900]),
                    ),

                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.only(left: 5.0),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        "/cadastro",
                        (route) => false,
                      ),
                      child: Text(
                        "Cadastrar-se",
                        style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight(900),),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "É professor?",
                      style: TextStyle(color: Colors.blue[900]),
                    ),

                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.only(left: 5.0),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => Navigator.pushReplacementNamed(context, "/loginAdmin"),
                      child: Text(
                        "Entrar como professor",
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
