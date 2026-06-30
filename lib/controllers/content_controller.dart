import '../models/repositories/learning_repository.dart';
import 'session_controller.dart';

class ContentController {
  final LearningRepository _repository;

  ContentController({LearningRepository? repository})
      : _repository = repository ?? LearningRepository();

  Future<List<Map<String, dynamic>>> fetchLessonPages(String idAula) {
    return _repository.fetchLessonPages(idAula);
  }

  Future<bool> isLessonCompleted(String idAula) async {
    return _repository.isLessonCompleted(
      idAula: idAula,
      idUsuario: await getIdUsuario(),
    );
  }
}
