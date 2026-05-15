import 'package:flutter/material.dart';
import 'basecard.dart'; // Onde estão seus cards com onTap
import 'class2.dart'; // Onde está sua LessonsScreen
import 'navmenu.dart';
import 'models.dart';
import 'leaderboard.dart';
// Lista estática com os dados dos módulos
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

  // Array contendo as telas que serão alternadas pelo BottomNavBar
  @override
  Widget build(BuildContext context) {
    final List<Widget> _telas = [
      // Índice 0: Lista gerada dinamicamente a partir da lista estática
      ListView(
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
      // Índice 1: Leader Board
      const LeaderboardPage()
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Módulos'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: _telas[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
