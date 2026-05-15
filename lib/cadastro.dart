import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  bool esconderSenha = true;
  bool esconderRepetirSenha = true;

  // Função de registro integrada
  Future<void> onRegister(BuildContext context) async {
    //Verificar se as senhas são iguais
    if (txtSenha.text != txtRepetirSenha.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("As senhas não são iguais!"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      //Criar usuário
      var credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: txtEmail.text
                .trim(), // .trim() remove espaços vazios acidentais
            password: txtSenha.text,
          );

      // Colocar nome do usuário no perfil
      await credential.user!.updateDisplayName(txtNome.text);

      //verificação se tudo estiver correto ir para a página de módulos
      if (mounted) {
        Navigator.pushReplacementNamed(context, "/modulos");
      }
    } on FirebaseAuthException catch (ex) {
      // Traduzir os erros dos firebase para o português
      String errorMessage = ex.message ?? "Erro desconhecido";

      if (ex.code == 'weak-password') {
        errorMessage = 'A senha fornecida é muito fraca (mínimo 6 caracteres).';
      } else if (ex.code == 'email-already-in-use') {
        errorMessage = 'Já existe uma conta com este e-mail.';
      } else if (ex.code == 'invalid-email') {
        errorMessage = 'O e-mail fornecido não é válido.';
      }

      final snackBar = SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

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
        margin: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          // Adicionado para evitar erro de tela pequena com o teclado
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_add_outlined,
                size: 80,
                color: Colors.blue[900],
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
            ],
          ),
        ),
      ),
    );
  }
}
