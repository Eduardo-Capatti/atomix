import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'basecard.dart';
import 'conteudo.dart';
import 'leaderboard.dart';
import 'models.dart';
import 'navmenu.dart';
import 'session.dart';

class LessonsScreen extends StatefulWidget {
  final String idModulo;
  final String moduleTitle;

  const LessonsScreen({
    super.key,
    required this.idModulo,
    required this.moduleTitle,
  });

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _aulasListener;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _usuarioAulasListener;

  int _selectedIndex = 0;
  bool _isLoading = true;
  List<LessonModel> _aulas = [];
  Set<String> _aulasConcluidas = {};

  @override
  void initState() {
    super.initState();
    _iniciarListenerAulas();
    _iniciarListenerUsuarioAulas();
  }

  void _iniciarListenerAulas() {
    _aulasListener = _firestore
        .collection('aula')
        .orderBy('ordem')
        .where("idModulo", isEqualTo: widget.idModulo)
        .snapshots()
        .listen(
      (_) async {
        await _carregarAulas();
      },
      onError: (error) async {
        await _carregarAulas();
      },
    );
  }

  void _iniciarListenerUsuarioAulas() async {
    final idUsuario = await getIdUsuario();
    if (!mounted) return;

    _usuarioAulasListener = _firestore
        .collection('usuarioAula')
        .where('idModulo', isEqualTo: widget.idModulo)
        .where('idUsuario', isEqualTo: idUsuario)
        .snapshots()
        .listen(
      (_) async {
        await _carregarAulasConcluidas(idUsuario);
      },
      onError: (error) async {
        await _carregarAulasConcluidas(idUsuario);
      },
    );
  }

  @override
  void dispose() {
    _aulasListener?.cancel();
    _usuarioAulasListener?.cancel();
    super.dispose();
  }

  Future<void> _carregarAulas() async {
    setState(() {
      _isLoading = true;
    });

    QuerySnapshot<Map<String, dynamic>> snapshot;

    try {
      snapshot = await _firestore
          .collection('aula')
          .where('idModulo', isEqualTo: widget.idModulo)
          .orderBy('ordem')
          .get();
    } catch (_) {
      snapshot = await _firestore
          .collection('aula')
          .where('idModulo', isEqualTo: widget.idModulo)
          .get();
    }

    final docs = snapshot.docs.toList()
      ..sort(
        (a, b) => ((a.data()['ordem'] ?? 0) as num)
            .compareTo((b.data()['ordem'] ?? 0) as num),
      );

    if (!mounted) return;

    setState(() {
      _aulas = docs
          .map((doc) => LessonModel.fromMap(doc.data(), doc.id))
          .toList();
      _isLoading = false;
    });
  }

  Future<void> _carregarAulasConcluidas([String? idUsuarioAtual]) async {
    final idUsuario = idUsuarioAtual ?? await getIdUsuario();

    final snapshot = await _firestore
        .collection('usuarioAula')
        .where('idModulo', isEqualTo: widget.idModulo)
        .where('idUsuario', isEqualTo: idUsuario)
        .get();

    if (!mounted) return;

    setState(() {
      _aulasConcluidas = snapshot.docs
          .map((doc) => doc.data()['idAula']?.toString() ?? '')
          .where((idAula) => idAula.isNotEmpty)
          .toSet();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final telaAulas = Scaffold(
      appBar: AppBar(
        title: Text(widget.moduleTitle),
        
        actions: [
          IconButton(
              onPressed: ()=>{finalizarSession(context)},
              disabledColor: Colors.grey,
              icon: const Icon(Icons.logout, size: 30),
          ),
        ],
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _aulas.isEmpty
              ? const Center(child: Text('Nenhuma aula cadastrada.'))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    for (final lesson in _aulas)
                      LessonCard(
                        lesson: lesson,
                        isCompleted: _aulasConcluidas.contains(lesson.id),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Conteudo(
                                idAula: lesson.id,
                                tituloAula: lesson.title,
                                idModulo: widget.idModulo,
                                moduleTitle: widget.moduleTitle,
                                totalXP: lesson.totalXP
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
    );

    final List<Widget> telas = [
      telaAulas,
      const LeaderboardPage(),
    ];

    return Scaffold(
      body: telas[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
