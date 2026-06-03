import 'package:flutter/material.dart';

import 'base64.dart';
import 'models.dart';

class CustomAppCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final BoxDecoration? decoration;

  const CustomAppCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: decoration ??
          BoxDecoration(
            color: backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
      child: child,
    );
  }
}

class ModuleCard extends StatelessWidget {
  final ModuleModel module;
  final VoidCallback? onTap;

  const ModuleCard({
    super.key,
    required this.module,
    this.onTap,
  });

  Color get progressColor {
    final percentage = module.progress * 100;
    if (percentage < 33) return Colors.red;
    if (percentage < 67) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: CustomAppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              module.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Aulas: ${module.completedLessons}/${module.totalLessons}'),
                Text(
                  'Dificuldade: ${module.difficulty}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: module.progress,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                color: progressColor,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text('${(module.progress * 100).toInt()}% concluido'),
            ),
          ],
        ),
      ),
    );
  }
}

class LessonCard extends StatelessWidget {
  final LessonModel lesson;
  final VoidCallback? onTap;
  final bool isCompleted;

  const LessonCard({
    super.key,
    required this.lesson,
    this.onTap,
    this.isCompleted = false,
  });

  BoxDecoration _buildCompletedDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF4CAF50),
          const Color(0xFF2E7D32),
        ],
      ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: const Color(0xFF2E9E44),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF2E9E44).withOpacity(0.18),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[300],
      child: const Icon(Icons.broken_image),
    );
  }

  Widget _buildLessonImage() {
    final bytes = converterBase64EmBytes(lesson.imageUrl);

    if (bytes != null) {
      return Image.memory(
        bytes,
        width: 80,
        height: 60,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) => _buildFallbackImage(),
      );
    }

    return Image.network(
      lesson.imageUrl,
      width: 80,
      height: 60,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) => _buildFallbackImage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final infoColor = isCompleted ? Colors.white.withOpacity(0.92) : Colors.grey;
    final actionColor = isCompleted ? Colors.white : Colors.blue;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: CustomAppCard(
        decoration: isCompleted ? _buildCompletedDecoration() : null,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildLessonImage(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isCompleted ? Colors.white : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: infoColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${lesson.estimatedTime} minutos",
                        style: TextStyle(color: infoColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.play_circle_outline, color: actionColor),
          ],
        ),
      ),
    );
  }
}
