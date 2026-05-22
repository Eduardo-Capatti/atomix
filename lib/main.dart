import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'login.dart'; 
import 'loginAdmin.dart'; 
import 'moduloAdmin.dart'; 
import 'cadastro.dart'; 
import 'aula.dart';
import 'modulo.dart';
import 'conteudo.dart';
import 'leaderboard.dart';

// Configuração do Firebase convertida para Dart
final firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyBRzmKhbB2o4p5zXzKyCmyQ_3zd1303H-4",
  authDomain: "atomix-93312.firebaseapp.com",
  projectId: "atomix-93312",
  storageBucket: "atomix-93312.firebasestorage.app",
  messagingSenderId: "347375933900",
  appId: "1:347375933900:web:667fa90b8da691c3b22569",
);

void main() async {
  // Garante que o Flutter inicialize os bindings antes do Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase com as credenciais do Atômix
  await Firebase.initializeApp(
    options: firebaseOptions,
  );

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/", 
      routes: {
        "/": (context) => LoginPage(),
        "/cadastro": (context) => CadastroPage(),
        "/loginAdmin": (context) => LoginPageAdmin(),
        "/modulos": (context) => ModulesScreen(),
        "/conteudo": (context) => Conteudo(),
        "/moduloAdmin": (context) => ModuloAdmin(),
      },
    ),
  );
}
