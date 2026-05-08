import 'package:flutter/material.dart';
import 'basecard.dart';

class LessonsScreen extends StatelessWidget {
  final String moduleTitle;

  const LessonsScreen({super.key, required this.moduleTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(moduleTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          LessonCard(
            title: 'Introdução ao Carbono',
            estimatedTime: '12 min',
            imageUrl: 'https://images.unsplash.com/photo-1603126857599-f6e157fa2fe6?w=200',
          ),
          LessonCard(
            title: 'Cadeias Carbônicas',
            estimatedTime: '18 min',
            imageUrl: 'https://images.unsplash.com/photo-1532187875605-2fe35851146a?w=200',
          ),
          LessonCard(
            title: 'Hidrocarbonetos',
            estimatedTime: '25 min',
            imageUrl: 'https://images.unsplash.com/photo-1581093588401-fbb62a02f120?w=200',
          ),
        ],
      ),
    );
  }
}