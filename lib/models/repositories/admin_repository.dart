import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRepository {
  final FirebaseFirestore _firestore;

  AdminRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _modulos =>
      _firestore.collection('modulo');
  CollectionReference<Map<String, dynamic>> get _aulas =>
      _firestore.collection('aula');
  CollectionReference<Map<String, dynamic>> get _conteudos =>
      _firestore.collection('conteudo');

  Stream<QuerySnapshot<Map<String, dynamic>>> watchModules() {
    return _modulos.orderBy('ordem').snapshots();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchModules() async {
    QuerySnapshot<Map<String, dynamic>> snapshot;

    try {
      snapshot = await _modulos.orderBy('ordem').get();
    } catch (_) {
      snapshot = await _modulos.get();

      for (int i = 0; i < snapshot.docs.length; i++) {
        await _modulos.doc(snapshot.docs[i].id).set({'ordem': i}, SetOptions(merge: true));
      }

      snapshot = await _modulos.orderBy('ordem').get();
    }

    return snapshot.docs;
  }

  Future<void> saveModuleOrder(List<QueryDocumentSnapshot<Map<String, dynamic>>> modulos) async {
    final batch = _firestore.batch();

    for (int i = 0; i < modulos.length; i++) {
      batch.update(_modulos.doc(modulos[i].id), {'ordem': i});
    }

    await batch.commit();
  }

  Future<void> createModule({
    required String titulo,
    required String dificuldade,
    required int ordem,
  }) async {
    final novoDoc = _modulos.doc();

    await novoDoc.set({
      'id': novoDoc.id,
      'titulo': titulo,
      'dificuldade': dificuldade,
      'quantidade': 0,
      'ordem': ordem,
    });
  }

  Future<void> updateModule({
    required String idModulo,
    required String titulo,
    required String dificuldade,
  }) {
    return _modulos.doc(idModulo).update({
      'titulo': titulo,
      'dificuldade': dificuldade,
    });
  }

  Future<void> deleteModule(String idModulo) async {
    final listaAulas = await _aulas.where('idModulo', isEqualTo: idModulo).get();
    final batch = _firestore.batch();

    batch.delete(_modulos.doc(idModulo));

    for (final aula in listaAulas.docs) {
      batch.delete(aula.reference);

      final conteudos = await _conteudos.where('idAula', isEqualTo: aula['id']).get();

      for (final conteudo in conteudos.docs) {
        batch.delete(conteudo.reference);
      }
    }

    await batch.commit();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchLessons(String idModulo) {
    return _aulas.orderBy('ordem').where('idModulo', isEqualTo: idModulo).snapshots();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchLessons(String idModulo) async {
    QuerySnapshot<Map<String, dynamic>> snapshot;

    try {
      snapshot = await _aulas.orderBy('ordem').where('idModulo', isEqualTo: idModulo).get();
    } catch (_) {
      snapshot = await _aulas.where('idModulo', isEqualTo: idModulo).get();

      for (int i = 0; i < snapshot.docs.length; i++) {
        await _aulas.doc(snapshot.docs[i].id).set({'ordem': i}, SetOptions(merge: true));
      }

      snapshot = await _aulas.where('idModulo', isEqualTo: idModulo).orderBy('ordem').get();
    }

    return snapshot.docs;
  }

  Future<void> saveLessonOrder(List<QueryDocumentSnapshot<Map<String, dynamic>>> aulas) async {
    final batch = _firestore.batch();

    for (int i = 0; i < aulas.length; i++) {
      batch.update(_aulas.doc(aulas[i].id), {'ordem': i});
    }

    await batch.commit();
  }

  Future<void> updateModuleLessonCount(String idModulo, int delta) {
    return _modulos.doc(idModulo).update({'quantidade': FieldValue.increment(delta)});
  }

  Future<void> deleteLesson(String idAula) async {
    final listaConteudo = await _conteudos.where('idAula', isEqualTo: idAula).get();
    final batch = _firestore.batch();

    batch.delete(_aulas.doc(idAula));

    for (final conteudo in listaConteudo.docs) {
      batch.delete(conteudo.reference);
    }

    await batch.commit();
  }

  Future<void> createLesson({
    required String idModulo,
    required String titulo,
    required String tempoEstimado,
    required int totalXP,
    required String url,
    required int ordem,
  }) async {
    final novoDoc = _aulas.doc();

    await novoDoc.set({
      'id': novoDoc.id,
      'idModulo': idModulo,
      'titulo': titulo,
      'tempoEstimado': tempoEstimado,
      'totalXP': totalXP,
      'url': url,
      'ordem': ordem,
    });
  }

  Future<void> updateLesson({
    required String idAula,
    required String titulo,
    required String tempoEstimado,
    required int totalXP,
    required String url,
  }) {
    return _aulas.doc(idAula).update({
      'titulo': titulo,
      'tempoEstimado': tempoEstimado,
      'totalXP': totalXP,
      'url': url,
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchPages(String idAula) {
    return _conteudos.where('idAula', isEqualTo: idAula).snapshots();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchPages(String idAula) async {
    QuerySnapshot<Map<String, dynamic>> snapshot;

    try {
      snapshot = await _conteudos.where('idAula', isEqualTo: idAula).orderBy('pagina').get();
    } catch (_) {
      snapshot = await _conteudos.where('idAula', isEqualTo: idAula).get();
    }

    return snapshot.docs.toList()
      ..sort(
        (a, b) => ((a.data()['pagina'] ?? 0) as num)
            .compareTo((b.data()['pagina'] ?? 0) as num),
      );
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchOrderedPages(String idAula) async {
    final snapshot = await _conteudos.where('idAula', isEqualTo: idAula).orderBy('pagina').get();
    return snapshot.docs.toList();
  }

  Future<void> setPageData({
    required String idPagina,
    required Map<String, dynamic> data,
  }) {
    return _conteudos.doc(idPagina).set(data, SetOptions(merge: true));
  }

  Future<void> createPage({
    required String idAula,
    required int pagina,
  }) async {
    final novoDoc = _conteudos.doc();

    await novoDoc.set({
      'id': novoDoc.id,
      'idAula': idAula,
      'pagina': pagina,
      'conteudos': <Map<String, dynamic>>[],
    });
  }

  Future<void> deletePage(String idPagina) {
    return _conteudos.doc(idPagina).delete();
  }

  Future<void> swapPages({
    required String idPaginaAtual,
    required int numeroAtual,
    required String idPaginaDestino,
    required int numeroDestino,
  }) async {
    final batch = _firestore.batch();

    batch.update(_conteudos.doc(idPaginaAtual), {'pagina': numeroDestino});
    batch.update(_conteudos.doc(idPaginaDestino), {'pagina': numeroAtual});

    await batch.commit();
  }

  Future<void> updatePageContents({
    required String idPagina,
    required List<Map<String, dynamic>> conteudos,
  }) {
    return _conteudos.doc(idPagina).update({'conteudos': conteudos});
  }
}
