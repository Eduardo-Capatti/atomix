import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/entities/lesson_models.dart';
import '../models/repositories/learning_repository.dart';
import 'session_controller.dart';

class LessonsController {
  final LearningRepository _repository;

  LessonsController({LearningRepository? repository})
      : _repository = repository ?? LearningRepository();

  Future<String> currentUserId() => getIdUsuario();

  Stream<QuerySnapshot<Map<String, dynamic>>> watchLessons(String idModulo) {
    return _repository.watchLessons(idModulo);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchCompletedLessons({
    required String idModulo,
    required String idUsuario,
  }) {
    return _repository.watchCompletedLessons(
      idModulo: idModulo,
      idUsuario: idUsuario,
    );
  }

  Future<List<LessonModel>> fetchLessons(String idModulo) {
    return _repository.fetchLessons(idModulo);
  }

  Future<Set<String>> fetchCompletedLessonIds({
    required String idModulo,
    required String idUsuario,
  }) {
    return _repository.fetchCompletedLessonIds(
      idModulo: idModulo,
      idUsuario: idUsuario,
    );
  }
}
