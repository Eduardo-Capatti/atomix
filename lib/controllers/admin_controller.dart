import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/repositories/admin_repository.dart';
import 'session_controller.dart';

class AdminController {
  final AdminRepository _repository;

  AdminController({AdminRepository? repository})
      : _repository = repository ?? AdminRepository();

  Future<bool> canAccessAdminArea() async {
    return await verificarSession() && await verificarAdmin();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchModules() {
    return _repository.watchModules();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchModules() {
    return _repository.fetchModules();
  }

  Future<void> saveModuleOrder(List<QueryDocumentSnapshot<Map<String, dynamic>>> modulos) {
    return _repository.saveModuleOrder(modulos);
  }

  Future<void> createModule({
    required String titulo,
    required String dificuldade,
    required int ordem,
  }) {
    return _repository.createModule(
      titulo: titulo,
      dificuldade: dificuldade,
      ordem: ordem,
    );
  }

  Future<void> updateModule({
    required String idModulo,
    required String titulo,
    required String dificuldade,
  }) {
    return _repository.updateModule(
      idModulo: idModulo,
      titulo: titulo,
      dificuldade: dificuldade,
    );
  }

  Future<void> deleteModule(String idModulo) {
    return _repository.deleteModule(idModulo);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchLessons(String idModulo) {
    return _repository.watchLessons(idModulo);
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchLessons(String idModulo) {
    return _repository.fetchLessons(idModulo);
  }

  Future<void> saveLessonOrder(List<QueryDocumentSnapshot<Map<String, dynamic>>> aulas) {
    return _repository.saveLessonOrder(aulas);
  }

  Future<void> updateModuleLessonCount(String idModulo, int delta) {
    return _repository.updateModuleLessonCount(idModulo, delta);
  }

  Future<void> deleteLesson(String idAula) {
    return _repository.deleteLesson(idAula);
  }

  Future<void> createLesson({
    required String idModulo,
    required String titulo,
    required String tempoEstimado,
    required int totalXP,
    required String url,
    required int ordem,
  }) {
    return _repository.createLesson(
      idModulo: idModulo,
      titulo: titulo,
      tempoEstimado: tempoEstimado,
      totalXP: totalXP,
      url: url,
      ordem: ordem,
    );
  }

  Future<void> updateLesson({
    required String idAula,
    required String titulo,
    required String tempoEstimado,
    required int totalXP,
    required String url,
  }) {
    return _repository.updateLesson(
      idAula: idAula,
      titulo: titulo,
      tempoEstimado: tempoEstimado,
      totalXP: totalXP,
      url: url,
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchPages(String idAula) {
    return _repository.watchPages(idAula);
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchPages(String idAula) {
    return _repository.fetchPages(idAula);
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchOrderedPages(String idAula) {
    return _repository.fetchOrderedPages(idAula);
  }

  Future<void> setPageData({
    required String idPagina,
    required Map<String, dynamic> data,
  }) {
    return _repository.setPageData(idPagina: idPagina, data: data);
  }

  Future<void> createPage({
    required String idAula,
    required int pagina,
  }) {
    return _repository.createPage(idAula: idAula, pagina: pagina);
  }

  Future<void> deletePage(String idPagina) {
    return _repository.deletePage(idPagina);
  }

  Future<void> swapPages({
    required String idPaginaAtual,
    required int numeroAtual,
    required String idPaginaDestino,
    required int numeroDestino,
  }) {
    return _repository.swapPages(
      idPaginaAtual: idPaginaAtual,
      numeroAtual: numeroAtual,
      idPaginaDestino: idPaginaDestino,
      numeroDestino: numeroDestino,
    );
  }

  Future<void> updatePageContents({
    required String idPagina,
    required List<Map<String, dynamic>> conteudos,
  }) {
    return _repository.updatePageContents(
      idPagina: idPagina,
      conteudos: conteudos,
    );
  }

  bool contentListsAreEqual(dynamic original, List<Map<String, dynamic>> normalizado) {
    if (original is! List) {
      return normalizado.isEmpty;
    }

    return jsonEncode(original) == jsonEncode(normalizado);
  }

  List<Map<String, dynamic>> normalizeContents(List<Map<String, dynamic>> conteudos) {
    for (int i = 0; i < conteudos.length; i++) {
      conteudos[i]['ordem'] = i;

      if (conteudos[i]['tipo'] == 'exercicio') {
        conteudos[i]['tipo2'] = conteudos[i]['tipo2']?.toString() ?? 'texto';
        conteudos[i]['pergunta'] = conteudos[i]['pergunta']?.toString() ?? '';
        conteudos[i]['resposta'] = (conteudos[i]['resposta'] as num?)?.toInt() ?? 1;
        conteudos[i]['conteudo'] = List<String>.from(conteudos[i]['conteudo'] as List? ?? []);
      }
    }

    return conteudos;
  }
}
