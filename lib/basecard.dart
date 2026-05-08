import 'package:flutter/material.dart';

// Este é o seu "esqueleto" que gerencia a parte visual externa
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

// Implementação do Card de Módulo (Matérias)
class ModuleCard extends StatelessWidget {
  final String title;
  final int totalLessons;
  final int completedLessons;
  final String difficulty;
  final Color progressColor;
  final VoidCallback? onTap; // Adicionado para navegação

  const ModuleCard({
    super.key,
    required this.title,
    required this.totalLessons,
    required this.completedLessons,
    required this.difficulty,
    this.progressColor = Colors.blue,
    this.onTap, // Adicionado no construtor
  });

  @override
  Widget build(BuildContext context) {
    double progress = completedLessons / totalLessons;

    return InkWell(
      onTap: onTap, // Aciona a navegação definida ao chamar o card
      borderRadius: BorderRadius.circular(12),
      child: CustomAppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Aulas: $completedLessons/$totalLessons'),
                Text('Dificuldade: $difficulty', style: const TextStyle(fontStyle: FontStyle.italic)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                color: progressColor,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text('${(progress * 100).toInt()}% concluído'),
            ),
          ],
        ),
      ),
    );
  }
}

// Implementação do Card de Aula
class LessonCard extends StatelessWidget {
  final String title;
  final String estimatedTime;
  final String imageUrl;
  final VoidCallback? onTap; // Adicionado para navegação

  const LessonCard({
    super.key,
    required this.title,
    required this.estimatedTime,
    required this.imageUrl,
    this.onTap, // Adicionado no construtor
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:() =>
                  Navigator.pushNamed(context, "/conteudo"), // Aciona a navegação definida ao chamar o card
      borderRadius: BorderRadius.circular(12),
      child: CustomAppCard(
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 80,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  width: 80,
                  height: 60,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        estimatedTime,
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