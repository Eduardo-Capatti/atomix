
import 'package:flutter/material.dart';

import '../models/repositories/session_repository.dart';

final SessionRepository _sessionRepository = SessionRepository();

Future<void> formarSession (String idUsuario, String nomeUsuario, bool adminUsuario) async{
  await _sessionRepository.saveSession(idUsuario, nomeUsuario, adminUsuario);
}

Future<String> getIdUsuario() async{
  return _sessionRepository.getUserId();
} 

Future<String> getNomeUsuario() async{
  return _sessionRepository.getUserName();
} 

 
Future<bool> verificarSession() async{
  return _sessionRepository.hasSession();
}

Future<bool> verificarAdmin() async{
  return _sessionRepository.isAdmin();

}

void navegacaoSession(BuildContext context, String pagina){
  Navigator.pushNamedAndRemoveUntil(
    context,
    pagina,
    (Route<dynamic> route) => false
  );
}

Future<void> finalizarSession(BuildContext context) async{
  await _sessionRepository.clear();

  Navigator.pushNamedAndRemoveUntil(
    context,
    "/",
    (Route<dynamic> route) => false
  );
}

