import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'aula.dart';
import 'basecard.dart';
import 'configuracoes.dart';
import 'leaderboard.dart';
import 'models.dart';
import 'navmenu.dart';
import 'session.dart';

class ModulesScreen extends StatefulWidget {
  const ModulesScreen({super.key});

  @override
  State<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends State<ModulesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _modulosListener;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _aulasListener;

  int _selectedIndex = 0;
  bool _isLoading = true;
  List<ModuleModel> _modulos = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!await verificarSession() || await verificarAdmin()) {
        navegacaoSession(context, "/");
      }
      _iniciarListeners();
    });
  }

  void _iniciarListeners() async {
    final idUsuario = await getIdUsuario();
    _modulosListener = _firestore
        .collection('modulo')
        .snapshots()
        .listen((_) => _carregarModulos());

    _aulasListener = _firestore
        .collection('usuarioAula')
        .where('idUsuario', isEqualTo: idUsuario)
        .snapshots()
        .listen((_) => _carregarModulos());
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
      final idUsuario = await getIdUsuario();
      final resultados = await _buscarModulos(idUsuario);

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

  Future<List<ModuleModel>> _buscarModulos(String idUsuario) async {
    QuerySnapshot<Map<String, dynamic>> snapshot;

    try {
      snapshot = await _firestore.collection('modulo').orderBy('ordem').get();
    } catch (_) {
      snapshot = await _firestore.collection('modulo').get();
    }

    final docs = snapshot.docs.toList()
      ..sort(
        (a, b) => ((a.data()['ordem'] ?? 0) as num)
            .compareTo((b.data()['ordem'] ?? 0) as num),
      );

    return Future.wait(
      docs.map((doc) async {
        final listagemUsuarioAula = await _firestore
            .collection('usuarioAula')
            .where('idModulo', isEqualTo: doc.id)
            .where('idUsuario', isEqualTo: idUsuario)
            .get();

        final idsModulos = listagemUsuarioAula.docs
            .map((doc) => doc['idAula'] as String)
            .toSet();

        final dadosModulo = Map<String, dynamic>.from(doc.data());
        dadosModulo['completedLessons'] = idsModulos.length;

        return ModuleModel.fromMap(dadosModulo, doc.id);
      }),
    );
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
        title: const Text('Meus Módulos'),
        backgroundColor: Colors.blueAccent,
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
