import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../controllers/lessons_controller.dart';
import '../../models/entities/lesson_models.dart';
import '../widgets/basecard.dart';
import '../widgets/navmenu.dart';
import 'configuracoes_view.dart';
import 'conteudo_view.dart';
import 'leaderboard_view.dart';

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
  final LessonsController _controller = LessonsController();
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
    _aulasListener = _controller.watchLessons(widget.idModulo).listen(
      (_) async {
        await _carregarAulas();
      },
      onError: (error) async {
        await _carregarAulas();
      },
    );
  }

  void _iniciarListenerUsuarioAulas() async {
    final idUsuario = await _controller.currentUserId();
    if (!mounted) return;

    _usuarioAulasListener = _controller
        .watchCompletedLessons(idModulo: widget.idModulo, idUsuario: idUsuario)
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

  void _mostrarErro(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _carregarAulas() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final aulas = await _controller.fetchLessons(widget.idModulo);

      if (!mounted) return;

      setState(() {
        _aulas = aulas;
        _isLoading = false;
      });
    } on FirebaseException catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      _mostrarErro('Erro ao carregar aulas.');
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      _mostrarErro('Erro ao carregar aulas.');
    }
  }

  Future<void> _carregarAulasConcluidas([String? idUsuarioAtual]) async {
    try {
      final idUsuario = idUsuarioAtual ?? await _controller.currentUserId();
      final aulasConcluidas = await _controller.fetchCompletedLessonIds(
        idModulo: widget.idModulo,
        idUsuario: idUsuario,
      );

      if (!mounted) return;

      setState(() {
        _aulasConcluidas = aulasConcluidas;
      });
    } on FirebaseException catch (_) {
      _mostrarErro('Erro ao carregar progresso das aulas.');
    } catch (_) {
      _mostrarErro('Erro ao carregar progresso das aulas.');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    final telaAulas = Scaffold(
      backgroundColor: Colors.blue[50], 
      appBar: AppBar(
        title: Text(widget.moduleTitle),
        backgroundColor: const Color(0xFF0066CC),
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
      const ConfiguracoesPage(),
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
