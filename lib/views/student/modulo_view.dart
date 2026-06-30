import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../controllers/modules_controller.dart';
import '../../controllers/session_controller.dart';
import '../../models/entities/lesson_models.dart';
import '../widgets/basecard.dart';
import '../widgets/navmenu.dart';
import 'aula_view.dart';
import 'configuracoes_view.dart';
import 'leaderboard_view.dart';

class ModulesScreen extends StatefulWidget {
  const ModulesScreen({super.key});

  @override
  State<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends State<ModulesScreen> {
  final ModulesController _controller = ModulesController();
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _modulosListener;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _aulasListener;

  int _selectedIndex = 0;
  bool _isLoading = true;
  List<ModuleModel> _modulos = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!await _controller.canAccessStudentArea()) {
        navegacaoSession(context, "/");
      }
      _iniciarListeners();
    });
  }

  void _iniciarListeners() async {
    final idUsuario = await _controller.currentUserId();
    _modulosListener = _controller.watchModules().listen((_) => _carregarModulos());
    _aulasListener = _controller.watchUserLessons(idUsuario).listen((_) => _carregarModulos());
  }

  @override
  void dispose() {
    _modulosListener?.cancel();
    _aulasListener?.cancel();
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

  Future<void> _carregarModulos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final idUsuario = await _controller.currentUserId();
      final resultados = await _controller.fetchModules(idUsuario);

      if (!mounted) return;

      setState(() {
        _modulos = resultados;
        _isLoading = false;
      });
    } on FirebaseException catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      _mostrarErro('Erro ao carregar módulos.');
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      _mostrarErro('Erro ao carregar módulos.');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final telaModulos = Scaffold(
      backgroundColor: Colors.blue[50], 
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Meus Módulos'),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _modulos.isEmpty
              ? const Center(child: Text('Nenhum módulo cadastrado.'))
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

    final List<Widget> telas = [
      telaModulos,
      const LeaderboardPage(),
      const ConfiguracoesPage(),
    ];

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: telas[_selectedIndex],
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}
