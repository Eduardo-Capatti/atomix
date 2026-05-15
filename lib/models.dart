// Modelo para o Módulo
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
    return ModuleModel(
      id: id,
      title: map['title'] ?? '',
      totalLessons: map['totalLessons'] ?? 0,
      completedLessons: map['completedLessons'] ?? 0,
      difficulty: map['difficulty'] ?? 'Iniciante',
    );
  }

  double get progress => totalLessons > 0 ? completedLessons / totalLessons : 0.0;
}

// Modelo para a Aula
class LessonModel {
  final String id;
  final String title;
  final String estimatedTime;
  final String imageUrl;

  LessonModel({
    required this.id,
    required this.title,
    required this.estimatedTime,
    required this.imageUrl,
  });

  factory LessonModel.fromMap(Map<String, dynamic> map, String id) {
    return LessonModel(
      id: id,
      title: map['title'] ?? '',
      estimatedTime: map['estimatedTime'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}