import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/repositories/auth_repository.dart';
import '../models/repositories/user_repository.dart';
import 'session_controller.dart';

class SettingsController {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  SettingsController({
    AuthRepository? authRepository,
    UserRepository? userRepository,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _userRepository = userRepository ?? UserRepository();

  User? get currentUser => _authRepository.currentUser;

  Future<DocumentSnapshot<Map<String, dynamic>>> loadCurrentUser() async {
    return _userRepository.findById(await getIdUsuario());
  }

  Future<void> sendPasswordReset() async {
    final email = currentUser?.email;

    if (email == null || email.isEmpty) {
      throw Exception('Nao foi possivel localizar o e-mail do usuario.');
    }

    await _authRepository.sendPasswordResetEmail(email);
  }

  Future<void> saveAvatar(int avatarId) async {
    await _userRepository.updateAvatar(await getIdUsuario(), avatarId);
  }

  Future<void> deleteAccount() async {
    if (currentUser == null) {
      throw Exception('Usuario nao encontrado.');
    }

    await _userRepository.deleteUserData(await getIdUsuario());
    await _authRepository.deleteCurrentUser();
  }
}
