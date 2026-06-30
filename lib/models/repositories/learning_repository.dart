import 'package:cloud_firestore/cloud_firestore.dart';

import '../entities/lesson_models.dart';

class LearningRepository {
  final FirebaseFirestore _firestore;

  LearningRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchModules() {
    return _firestore.collection('modulo').snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchUserLessons(String idUsuario) {
    return _firestore
        .collection('usuarioAula')
        .where('idUsuario', isEqualTo: idUsuario)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchLessons(String idModulo) {
    return _firestore
        .collection('aula')
        .orderBy('ordem')
        .where('idModulo', isEqualTo: idModulo)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchCompletedLessons({
    required String idModulo,
    required String idUsuario,
  }) {
    return _firestore
        .collection('usuarioAula')
        .where('idModulo', isEqualTo: idModulo)
        .where('idUsuario', isEqualTo: idUsuario)
        .snapshots();
  }

  Future<List<ModuleModel>> fetchModules(String idUsuario) async {
    QuerySnapshot<Map<String, dynamic>> snapshot;

    try {
      snapshot = await _firestore.collection('modulo').orderBy('ordem').get();
    } catch (_) {
      snapshot = await _firestore.collection('modulo').get();
    }

    final docs = snapshot.docs.toList()
      ..sort(
        (a, b) => ((a.data()['ordem'] ?? 0) as num)
            .compareTo((b.data()['ordem'] ?? 0) as num),
      );

    return Future.wait(
      docs.map((doc) async {
        final listagemUsuarioAula = await _firestore
            .collection('usuarioAula')
            .where('idModulo', isEqualTo: doc.id)
            .where('idUsuario', isEqualTo: idUsuario)
            .get();

        final idsModulos = listagemUsuarioAula.docs
            .map((doc) => doc['idAula'] as String)
            .toSet();

        final dadosModulo = Map<String, dynamic>.from(doc.data());
        dadosModulo['completedLessons'] = idsModulos.length;

        return ModuleModel.fromMap(dadosModulo, doc.id);
      }),
    );
  }

  Future<List<LessonModel>> fetchLessons(String idModulo) async {
    QuerySnapshot<Map<String, dynamic>> snapshot;

    try {
      snapshot = await _firestore
          .collection('aula')
          .where('idModulo', isEqualTo: idModulo)
          .orderBy('ordem')
          .get();
    } catch (_) {
      snapshot = await _firestore
          .collection('aula')
          .where('idModulo', isEqualTo: idModulo)
          .get();
    }

    final docs = snapshot.docs.toList()
      ..sort(
        (a, b) => ((a.data()['ordem'] ?? 0) as num)
            .compareTo((b.data()['ordem'] ?? 0) as num),
      );

    return docs.map((doc) => LessonModel.fromMap(doc.data(), doc.id)).toList();
  }

  Future<Set<String>> fetchCompletedLessonIds({
    required String idModulo,
    required String idUsuario,
  }) async {
    final snapshot = await _firestore
        .collection('usuarioAula')
        .where('idModulo', isEqualTo: idModulo)
        .where('idUsuario', isEqualTo: idUsuario)
        .get();

    return snapshot.docs
        .map((doc) => doc.data()['idAula']?.toString() ?? '')
        .where((idAula) => idAula.isNotEmpty)
        .toSet();
  }

  Future<bool> isLessonCompleted({
    required String idAula,
    required String idUsuario,
  }) async {
    final snapshot = await _firestore
        .collection('usuarioAula')
        .where('idAula', isEqualTo: idAula)
        .where('idUsuario', isEqualTo: idUsuario)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> fetchLessonPages(String idAula) async {
    QuerySnapshot<Map<String, dynamic>> snapshot;

    try {
      snapshot = await _firestore
          .collection('conteudo')
          .where('idAula', isEqualTo: idAula)
          .orderBy('pagina')
          .get();
    } catch (_) {
      snapshot = await _firestore
          .collection('conteudo')
          .where('idAula', isEqualTo: idAula)
          .get();
    }

    return snapshot.docs.map((doc) => Map<String, dynamic>.from(doc.data())).toList()
      ..sort(
        (a, b) => ((a['pagina'] ?? 0) as num)
            .compareTo((b['pagina'] ?? 0) as num),
      );
  }
}
