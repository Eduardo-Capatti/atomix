import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signInAdmin({
    required String email,
    required String password,
  }) {
    if (email.trim() != 'admin@email.com' || password != '123456') {
      throw FirebaseAuthException(code: 'invalid-credential');
    }

    return signIn(email: email, password: password);
  }

  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await credential.user!.updateDisplayName(name);

    await _firestore.collection('usuarios').doc(credential.user!.uid).set({
      'nomeUsuario': name,
      'avatar_id': 0,
      'xp': 0,
    });

    return credential;
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> deleteCurrentUser() async {
    await _auth.currentUser?.delete();
  }
}
