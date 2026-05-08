import 'package:flutter/material.dart';
import 'login.dart';   
import 'cadastro.dart'; 
import 'class2.dart';
import 'class.dart';
import 'conteudo.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: "/", 
      routes: {
        "/": (context) => LoginPage(),
        "/cadastro": (context) => CadastroPage(),
        "/modulos": (context) => ModulesScreen(),
        "/conteudo": (context) => Conteudo(),
      },
    ),
  );
}