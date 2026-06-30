import 'package:shared_preferences/shared_preferences.dart';

class SessionRepository {
  Future<void> saveSession(String idUsuario, String nomeUsuario, bool adminUsuario) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('idUsuario', idUsuario);
    await prefs.setString('nomeUsuario', nomeUsuario);
    await prefs.setBool('adminUsuario', adminUsuario);
  }

  Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('idUsuario')!;
  }

  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nomeUsuario')!;
  }

  Future<bool> hasSession() async {
    final prefs = await SharedPreferences.getInstance();
    final idUsuario = prefs.getString('idUsuario');
    final nomeUsuario = prefs.getString('nomeUsuario');

    return nomeUsuario != null && idUsuario != null;
  }

  Future<bool> isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('adminUsuario') ?? false;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
