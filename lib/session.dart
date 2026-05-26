
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

void formarSession (String idUsuario, String nomeUsuario, bool adminUsuario) async{
  final prefs = await SharedPreferences.getInstance();

  await prefs.setString('idUsuario', idUsuario);
  await prefs.setString('nomeUsuario', nomeUsuario);
  await prefs.setBool('adminUsuario', adminUsuario);
}

Future<String> getIdUsuario() async{
  final prefs = await SharedPreferences.getInstance();

  return prefs.getString('idUsuario')!;
} 

Future<String> getNomeUsuario() async{
  final prefs = await SharedPreferences.getInstance();

  return prefs.getString('nomeUsuario')!;
} 

 
Future<bool> verificarSession() async{
  final prefs = await SharedPreferences.getInstance();
  String? idUsuario = prefs.getString("idUsuario");
  String? nomeUsuario = prefs.getString("nomeUsuario");
  bool adminUsuario = prefs.getBool("adminUsuario") ?? false;

  if(nomeUsuario != null && idUsuario != null){
    return true;
  }

  return false;
}

Future<bool> verificarAdmin() async{
  final prefs = await SharedPreferences.getInstance();
  bool adminUsuario = prefs.getBool("adminUsuario") ?? false;

  if(adminUsuario){
    return true;
  }

  return false;

}

void navegacaoSession(BuildContext context, String pagina){
  Navigator.pushNamedAndRemoveUntil(
    context,
    pagina,
    (Route<dynamic> route) => false
  );
}

void finalizarSession(BuildContext context) async{
  final prefs = await SharedPreferences.getInstance();

  await prefs.clear();

  Navigator.pushNamedAndRemoveUntil(
    context,
    "/",
    (Route<dynamic> route) => false
  );
}

