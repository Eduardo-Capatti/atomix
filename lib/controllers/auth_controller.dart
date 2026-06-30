import 'package:firebase_auth/firebase_auth.dart';

import '../models/repositories/auth_repository.dart';
import 'session_controller.dart';

class AuthController {
  final AuthRepository _authRepository;

  AuthController({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  Future<void> login(String email, String password) async {
    final credencial = await _authRepository.signIn(
      email: email,
      password: password,
    );

    await _createSession(credencial, false);
  }

  Future<void> loginAdmin(String email, String password) async {
    final credencial = await _authRepository.signInAdmin(
      email: email,
      password: password,
    );

    await _createSession(credencial, true);
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String repeatPassword,
  }) async {
    if (password != repeatPassword) {
      throw Exception('As senhas nao sao iguais!');
    }

    await _authRepository.register(
      name: name,
      email: email,
      password: password,
    );
  }

  Future<void> _createSession(UserCredential credencial, bool admin) async {
    final idUsuario = credencial.user!.uid;
    final nomeUsuario = credencial.user!.displayName ?? '';

    formarSession(idUsuario, nomeUsuario, admin);
  }

  String translateLoginError(FirebaseAuthException ex) {
    if (ex.code == 'user-not-found' || ex.code == 'invalid-credential') {
      return 'E-mail ou senha incorretos.';
    } else if (ex.code == 'wrong-password') {
      return 'Senha incorreta.';
    } else if (ex.code == 'invalid-email') {
      return 'Formato de e-mail invalido.';
    }

    return 'Erro ao fazer login.';
  }

  String translateRegisterError(FirebaseAuthException ex) {
    if (ex.code == 'weak-password') {
      return 'A senha fornecida e muito fraca (minimo 6 caracteres).';
    } else if (ex.code == 'email-already-in-use') {
      return 'Ja existe uma conta com este e-mail.';
    } else if (ex.code == 'invalid-email') {
      return 'O e-mail fornecido nao e valido.';
    }

    return ex.message ?? 'Erro desconhecido';
  }
}
