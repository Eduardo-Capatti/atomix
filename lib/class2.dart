import 'package:flutter/material.dart';
import 'basecard.dart';
import 'models.dart';
// Certifique-se de importar os arquivos da LeaderboardPage e da CustomBottomNavBar 
// caso eles estejam em arquivos separados no seu projeto.
 import 'leaderboard.dart';
import 'navmenu.dart';

final List<LessonModel> _aulasData = [
  LessonModel(
    id: '1',
    title: 'Introdução ao Carbono',
    estimatedTime: '12 min',
    imageUrl: 'https://images.unsplash.com/photo-1603126857599-f6e157fa2fe6?w=200',
  ),
  LessonModel(
    id: '2',
    title: 'Cadeias Carbônicas',
    estimatedTime: '18 min',
    imageUrl: 'https://images.unsplash.com/photo-1532187875605-2fe35851146a?w=200',
  ),
  LessonModel(
    id: '3',
    title: 'Hidrocarbonetos',
    estimatedTime: '25 min',
    imageUrl: 'https://images.unsplash.com/photo-1581093588401-fbb62a02f120?w=200',
  ),
];

class LessonsScreen extends StatefulWidget {
  final String moduleTitle;

  const LessonsScreen({super.key, required this.moduleTitle});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Aba 0: Scaffold individual protegendo a tela de aulas e sua AppBar
    final telaAulas = Scaffold(
      appBar: AppBar(
        title: Text(widget.moduleTitle), // Acessa o título passado no construtor
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (var lesson in _aulasData)
            LessonCard(
              lesson: lesson,
              onTap: () {
                Navigator.pushNamed(context, "/conteudo");
              },
            ),
        ],
      ),
    );

    // Array contendo as páginas completas para alternância
    final List<Widget> telas = [
      telaAulas,
      const LeaderboardPage(), // Renderiza a página de ranking que criamos antes
    ];

    // Scaffold Principal que gerencia apenas a troca de corpo e o menu inferior
    return Scaffold(
      body: telas[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}