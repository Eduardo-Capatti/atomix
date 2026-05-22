import 'package:flutter/material.dart';
import 'basecard.dart'; 
import 'aula.dart'; 
import 'navmenu.dart';
import 'models.dart';
import 'leaderboard.dart';

final List<ModuleModel> _modulosData = [
  ModuleModel(
    id: '1',
    title: 'Química Orgânica',
    totalLessons: 15,
    completedLessons: 12,
    difficulty: 'Média',
  ),
  ModuleModel(
    id: '2',
    title: 'Química Geral',
    totalLessons: 10,
    completedLessons: 10,
    difficulty: 'Fácil',
  ),
  ModuleModel(
    id: '3',
    title: 'Físico-Química',
    totalLessons: 20,
    completedLessons: 2,
    difficulty: 'Difícil',
  ),
];

class ModulesScreen extends StatefulWidget {
  const ModulesScreen({super.key});

  @override
  State<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends State<ModulesScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    final telaModulos = Scaffold(
      appBar: AppBar(
        title: const Text('Meus Módulos'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (var module in _modulosData)
            ModuleCard(
              module: module,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        LessonsScreen(moduleTitle: module.title),
                  ),
                );
              },
            ),
        ],
      ),
    );

    final List<Widget> _telas = [
      telaModulos,
      const LeaderboardPage()
    ];

    return Scaffold(
      body: _telas[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
