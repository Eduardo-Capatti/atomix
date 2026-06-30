import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>> findById(String idUsuario) {
    return _firestore.collection('usuarios').doc(idUsuario).get();
  }

  Future<List<Map<String, dynamic>>> rankingUsers() async {
    final snapshot = await _firestore
        .collection('usuarios')
        .orderBy('xp', descending: true)
        .limit(50)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> updateAvatar(String idUsuario, int avatarId) {
    return _firestore.collection('usuarios').doc(idUsuario).update({
      'avatar_id': avatarId,
    });
  }

  Future<void> deleteUserData(String idUsuario) {
    return _firestore.collection('usuarios').doc(idUsuario).delete();
  }

  Future<void> addXp(String idUsuario, int xp) {
    return _firestore.collection('usuarios').doc(idUsuario).update({
      'xp': FieldValue.increment(xp),
    });
  }

  Future<void> completeLesson({
    required String idUsuario,
    required String idAula,
    required String idModulo,
    required int xp,
  }) async {
    final novoDoc = _firestore.collection('usuarioAula').doc();

    await novoDoc.set({
      'id': novoDoc.id,
      'idAula': idAula,
      'idModulo': idModulo,
      'idUsuario': idUsuario,
      'xp': xp,
    });
  }
}
