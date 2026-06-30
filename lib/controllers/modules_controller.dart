import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/entities/lesson_models.dart';
import '../models/repositories/learning_repository.dart';
import 'session_controller.dart';

class ModulesController {
  final LearningRepository _repository;

  ModulesController({LearningRepository? repository})
      : _repository = repository ?? LearningRepository();

  Future<bool> canAccessStudentArea() async {
    return await verificarSession() && !await verificarAdmin();
  }

  Future<String> currentUserId() => getIdUsuario();

  Stream<QuerySnapshot<Map<String, dynamic>>> watchModules() {
    return _repository.watchModules();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchUserLessons(String idUsuario) {
    return _repository.watchUserLessons(idUsuario);
  }

  Future<List<ModuleModel>> fetchModules(String idUsuario) {
    return _repository.fetchModules(idUsuario);
  }
}
