import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'aula.dart';
import 'basecard.dart';
import 'leaderboard.dart';
import 'models.dart';
import 'navmenu.dart';

class ModulesScreen extends StatefulWidget {
  const ModulesScreen({super.key});

  @override
  State<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends State<ModulesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _selectedIndex = 0;
  bool _isLoading = true;
  List<ModuleModel> _modulos = [];

  @override
  void initState() {
    super.initState();
    _carregarModulos();
  }

  Future<void> _carregarModulos() async {
    setState(() {
      _isLoading = true;
    });

    QuerySnapshot<Map<String, dynamic>> snapshot;

    try {
      snapshot = await _firestore.collection('modulo').orderBy('ordem').get();
    } catch (_) {
      snapshot = await _firestore.collection('modulo').get();
    }

    if (!mounted) return;

    final docs = snapshot.docs.toList()
      ..sort(
        (a, b) => ((a.data()['ordem'] ?? 0) as num)
            .compareTo((b.data()['ordem'] ?? 0) as num),
      );

    setState(() {
      _modulos = docs
          .map((doc) => ModuleModel.fromMap(doc.data(), doc.id))
          .toList();
      _isLoading = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final telaModulos = Scaffold(
      appBar: AppBar(
        title: const Text('Meus Modulos'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _modulos.isEmpty
              ? const Center(child: Text('Nenhum modulo cadastrado.'))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    for (final module in _modulos)
                      ModuleCard(
                        module: module,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LessonsScreen(
                                idModulo: module.id,
                                moduleTitle: module.title,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
    );

    final List<Widget> telas = [telaModulos, const LeaderboardPage()];

    return Scaffold(
      body: telas[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
