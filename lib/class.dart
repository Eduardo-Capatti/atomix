import 'package:flutter/material.dart';
import 'basecard.dart'; // Onde estão seus cards com onTap
import 'class2.dart';  // Onde está sua LessonsScreen

class ModulesScreen extends StatelessWidget {
  const ModulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Módulos'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [ // Removido o 'const' daqui para permitir as funções onTap
          ModuleCard(
            title: 'Química Orgânica',
            totalLessons: 15,
            completedLessons: 10,
            difficulty: 'Média',
            progressColor: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LessonsScreen(moduleTitle: 'Química Orgânica'),
                ),
              );
            },
          ),
          ModuleCard(
            title: 'Química Geral',
            totalLessons: 10,
            completedLessons: 10,
            difficulty: 'Fácil',
            progressColor: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LessonsScreen(moduleTitle: 'Química Geral'),
                ),
              );
            },
          ),
          ModuleCard(
            title: 'Físico-Química',
            totalLessons: 20,
            completedLessons: 2,
            difficulty: 'Difícil',
            progressColor: Colors.red,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LessonsScreen(moduleTitle: 'Físico-Química'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}