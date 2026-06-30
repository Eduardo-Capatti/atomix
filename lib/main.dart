import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'views/auth/cadastro_view.dart';
import 'views/auth/login_admin_view.dart';
import 'views/auth/login_view.dart';
import 'views/admin/modulo_admin_view.dart';
import 'views/student/modulo_view.dart';

final firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyBRzmKhbB2o4p5zXzKyCmyQ_3zd1303H-4",
  authDomain: "atomix-93312.firebaseapp.com",
  projectId: "atomix-93312",
  storageBucket: "atomix-93312.firebasestorage.app",
  messagingSenderId: "347375933900",
  appId: "1:347375933900:web:667fa90b8da691c3b22569",
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        "/moduloAdmin": (context) => ModuloAdmin(),
      },
    ),
  );
}
