class ModuleModel {
  final String id;
  final String title;
  final int totalLessons;
  final int completedLessons;
  final String difficulty;

  ModuleModel({
    required this.id,
    required this.title,
    required this.totalLessons,
    required this.completedLessons,
    required this.difficulty,
  });

  factory ModuleModel.fromMap(Map<String, dynamic> map, String id) {
    final totalLessons = (map['quantidade'] as num?)?.toInt() ?? 0;
    final completedLessons =
        (map['completedLessons'] as num?)?.toInt() ?? 0;
    return ModuleModel(
      id: id,
      title: map['titulo']?.toString() ?? '',
      totalLessons: totalLessons,
      completedLessons: completedLessons.clamp(0, totalLessons).toInt(),
      difficulty: map['dificuldade']?.toString() ?? 'Fácil',
    );
  }

  double get progress =>
      totalLessons > 0 ? completedLessons / totalLessons : 0.0;
}

class LessonModel {
  final String id;
  final String title;
  final String estimatedTime;
  final String imageUrl;
  final int totalXP;

  LessonModel({
    required this.id,
    required this.title,
    required this.estimatedTime,
    required this.imageUrl,
    required this.totalXP
  });

  factory LessonModel.fromMap(Map<String, dynamic> map, String id) {
    return LessonModel(
      id: id,
      title: map['titulo']?.toString() ?? map['title']?.toString() ?? '',
      estimatedTime: map['tempoEstimado']?.toString() ?? '',
      imageUrl: map['url']?.toString() ?? '',
      totalXP: map['totalXP'] ?? 0,
    );
  }
}
