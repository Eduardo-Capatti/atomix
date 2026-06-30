import '../models/repositories/user_repository.dart';
import 'session_controller.dart';

class CompletionController {
  final UserRepository _repository;

  CompletionController({UserRepository? repository})
      : _repository = repository ?? UserRepository();

  Future<void> completeLesson({
    required int xp,
    required String idAula,
    required String idModulo,
  }) async {
    final idUsuario = await getIdUsuario();

    await _repository.addXp(idUsuario, xp);
    await _repository.completeLesson(
      idUsuario: idUsuario,
      idAula: idAula,
      idModulo: idModulo,
      xp: xp,
    );
  }
}
