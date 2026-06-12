import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'session.dart';

class LoginPageAdmin extends StatefulWidget {
  const LoginPageAdmin({super.key});

  @override
  State<LoginPageAdmin> createState() => _LoginPageStateAdmin();
}

class _LoginPageStateAdmin extends State<LoginPageAdmin> {
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtSenha = TextEditingController();

  bool esconderSenha = true;

  //Autenticação no banco
  Future<void> onLogin(BuildContext context) async {
    try {

      //login deu certo!
      if (txtEmail.text.trim() != "admin@email.com" && txtSenha.text != "123456") {
        throw FirebaseAuthException(
          code: 'invalid-credential'
        );
      }
      UserCredential credencial = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: txtEmail.text
            .trim(), //limpa espaços vazios que o usuário possa ter digitado sem querer
        password: txtSenha.text,
      );

      //login deu certo!
      if (mounted) {
        String idUsuario = credencial.user!.uid;
        String nomeUsuario = credencial.user!.displayName ?? "";
        formarSession(idUsuario, nomeUsuario, true);
        Navigator.pushReplacementNamed(context, "/moduloAdmin");
      }
    } on FirebaseAuthException catch (ex) {
      //Tratamento de erros (ex: senha errada, usuário não existe)
      String errorMessage = "Erro ao fazer login.";

      // Tradução das mensagens de erro
      if (ex.code == 'user-not-found' || ex.code == 'invalid-credential') {
        errorMessage = 'E-mail ou senha incorretos.';
      } else if (ex.code == 'wrong-password') {
        errorMessage = 'Senha incorreta.';
      } else if (ex.code == 'invalid-email') {
        errorMessage = 'Formato de e-mail inválido.';
      }
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
                        padding: EdgeInsets.only(left: 5.0, top:5.0),
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
