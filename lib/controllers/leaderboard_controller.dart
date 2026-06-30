import '../models/repositories/user_repository.dart';

class LeaderboardController {
  final UserRepository _repository;

  LeaderboardController({UserRepository? repository})
      : _repository = repository ?? UserRepository();

  Future<List<Map<String, dynamic>>> rankingUsers() {
    return _repository.rankingUsers();
  }
}
