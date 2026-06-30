import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/session_controller.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  TextEditingController txtNome = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtSenha = TextEditingController();
  TextEditingController txtRepetirSenha = TextEditingController();
  final AuthController _authController = AuthController();

  bool esconderSenha = true;
  bool esconderRepetirSenha = true;

  // Função de registro integrada
  Future<void> onRegister(BuildContext context) async {
    try {
      await _authController.register(
        name: txtNome.text,
        email: txtEmail.text,
        password: txtSenha.text,
        repeatPassword: txtRepetirSenha.text,
      );

      //verificação se tudo estiver correto ir para a página de módulos
      if (mounted) {
        Navigator.pushReplacementNamed(context, "/");
      }
    } on FirebaseAuthException catch (ex) {
      // Traduzir os erros dos firebase para o português
      String errorMessage = _authController.translateRegisterError(ex);

      final snackBar = SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (ex) {
      final snackBar = SnackBar(
        content: Text(ex.toString().replaceFirst('Exception: ', '')),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await verificarSession()) {
        print("logado");

        if (await verificarAdmin()) {
          navegacaoSession(context, "/moduloAdmin");
        } else {
          navegacaoSession(context, "/modulos");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.blue[900],
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            // Adicionado para evitar erro de tela pequena com o teclado
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
                const SizedBox(height: 16),
                Text(
                  "Cadastro",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: txtNome,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: "Nome",
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
                TextField(
                  controller: txtRepetirSenha,
                  obscureText: esconderRepetirSenha,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: "Repetir senha",
                    prefixIcon: Icon(
                      Icons.password_outlined,
                      color: Colors.blue[800],
                    ),
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
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(
                      50,
                    ), // Deixa o botão mais largo
                  ),
                  // Chama a nossa nova função passando o context
                  onPressed: () => onRegister(context),
                  child: const Text("Criar conta"),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Já tem uma conta?",
                      style: TextStyle(color: Colors.blue[900]),
                    ),

                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.only(left: 5.0),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      // Mantemos o pushNamed aqui pois o usuário pode querer apenas ir na tela de cadastro e voltar
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, "/"),
                      child: Text(
                        "Entrar",
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontWeight: FontWeight(900),
                        ),
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
