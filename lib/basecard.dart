import 'package:flutter/material.dart';

import 'base64.dart';
import 'models.dart';

class CustomAppCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const CustomAppCard({super.key, required this.child, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
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

  const LessonCard({
    super.key,
    required this.lesson,
    this.onTap,
  });

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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: CustomAppCard(
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${lesson.estimatedTime} minutos",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.play_circle_outline, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
