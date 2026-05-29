import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'aulaAdmin.dart';
import 'basecard.dart';
import 'session.dart';

class ModuloAdmin extends StatefulWidget {
  const ModuloAdmin({super.key});

  @override
  State<ModuloAdmin> createState() => _ModuloAdminState();
}

class _ModuloAdminState extends State<ModuloAdmin> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _modulos = [];
  bool _isLoading = true;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _modulosListener;
  bool _ignorarListener = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!await verificarSession() || !await verificarAdmin()) {
        navegacaoSession(context, "/");
        return;
      }

      _iniciarListenerModulos();
    });
  }

  void _iniciarListenerModulos() {
    _modulosListener = _firestore
        .collection('modulo')
        .orderBy('ordem')
        .snapshots()
        .listen(
      (_) async {
        if (_ignorarListener) return;
        await _carregarModulos();
      },
      onError: (error) async {
        if (_ignorarListener) return;
        await _carregarModulos();
      },
    );
  }

  @override
  void dispose() {
    _modulosListener?.cancel();
    super.dispose();
  }

  Future<void> _carregarModulos() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    QuerySnapshot<Map<String, dynamic>> snapshot;

    try {
      snapshot = await _firestore.collection('modulo').orderBy('ordem').get();
    } catch (_) {
      snapshot = await _firestore.collection('modulo').get();

      for (int i = 0; i < snapshot.docs.length; i++) {
        await _firestore.collection('modulo').doc(snapshot.docs[i].id).set({
          'ordem': i,
        }, SetOptions(merge: true));
      }

      snapshot = await _firestore.collection('modulo').orderBy('ordem').get();
    }

    if (!mounted) return;

    setState(() {
      _modulos = snapshot.docs;
      _isLoading = false;
    });
  }

  Future<void> _salvarNovaOrdem() async {
    final batch = _firestore.batch();

    for (int i = 0; i < _modulos.length; i++) {
      batch.update(_firestore.collection('modulo').doc(_modulos[i].id), {
        'ordem': i,
      });
    }

    await batch.commit();
  }

  Future<void> _reordenarModulos(int oldIndex, int newIndex) async {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      final item = _modulos.removeAt(oldIndex);
      _modulos.insert(newIndex, item);
    });

    _ignorarListener = true;

    try {
      await _salvarNovaOrdem();
      await _carregarModulos();
    } finally {
      _ignorarListener = false;
    }
  }

  void _excluirModulo(String idModulo) async {
    final listaAulas = await _firestore
          .collection('aula')
          .where('idModulo', isEqualTo: idModulo)
          .get();

    final batch = _firestore.batch();

    batch.delete(
      _firestore.collection('modulo').doc(idModulo),
    );

    for (var aula in listaAulas.docs) {
      batch.delete(aula.reference);

      final conteudos = await _firestore
          .collection('conteudo')
          .where('idAula', isEqualTo: aula['id'])
          .get();

      for (var conteudo in conteudos.docs) {
        batch.delete(conteudo.reference);
      }
    }

    await batch.commit();

  }

  void _acessarAula(String idModulo, int quantidade) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AulaAdmin(
          idModulo: idModulo,
          quantidade: quantidade,
        ),
      ),
    );
  }

  Future<void> _abrirDialogoModulo({
    QueryDocumentSnapshot<Map<String, dynamic>>? modulo,
  }) async {
    final tituloController = TextEditingController(
      text: modulo?.data()['titulo']?.toString() ?? '',
    );
    final bool editando = modulo != null;
    String dificuldade = modulo?.data()['dificuldade']?.toString() ?? 'Fácil';

    final telaContext = context;
    bool criouModulo = false;

    final salvou = await showDialog<bool>(
      context: telaContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(editando ? 'Editar módulo' : 'Novo módulo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: tituloController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: dificuldade,
                    decoration: const InputDecoration(
                      labelText: 'Dificuldade',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Fácil', child: Text('Fácil')),
                      DropdownMenuItem(value: 'Média', child: Text('Média')),
                      DropdownMenuItem(value: 'Difícil', child: Text('Difícil')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() {
                        dificuldade = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final titulo = tituloController.text.trim();

                    if (titulo.isEmpty) return;

                    if (editando) {
                      await _firestore.collection('modulo').doc(modulo.id).update({
                        'titulo': titulo,
                        'dificuldade': dificuldade,
                      });
                    } else {
                      _ignorarListener = true;
                      criouModulo = true;
                      final novoDoc = _firestore.collection('modulo').doc();

                      await novoDoc.set({
                        'id': novoDoc.id,
                        'titulo': titulo,
                        'dificuldade': dificuldade,
                        'quantidade': 0,
                        'ordem': _modulos.length,
                      });
                    }

                    if (!dialogContext.mounted) return;
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted) return;

    if (salvou == true) {
      try {
        await _carregarModulos();
      } finally {
        if (criouModulo) {
          _ignorarListener = false;
        }
      }
    } else {
      _ignorarListener = false;
    }

    tituloController.dispose();
  }

  Widget _buildModuloCard(
    QueryDocumentSnapshot<Map<String, dynamic>> modulo,
    int index,
  ) {
    final data = modulo.data();
    final titulo = data['titulo']?.toString() ?? '';
    final dificuldade = data['dificuldade']?.toString() ?? '';
    final quantidade = data['quantidade'] ?? 0;

    return Card(
      key: ValueKey(modulo.id),
      margin: EdgeInsets.zero,
      color: Colors.transparent,
      elevation: 0,
      child: CustomAppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5,
          children: [
            const SizedBox(height: 8),
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Dificuldade: $dificuldade'),
            const SizedBox(height: 4),
            Text('Quantidade de aulas: $quantidade'),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => _abrirDialogoModulo(modulo: modulo),
                  icon: const Icon(Icons.edit),
                  tooltip: 'Editar módulo',
                ),
                IconButton(
                  onPressed: () => _excluirModulo(modulo.id),
                  icon: const Icon(Icons.delete),
                  tooltip: 'Excluir módulo',
                ),
                IconButton(
                  onPressed: () => _acessarAula(modulo.id, quantidade),
                  icon: const Icon(Icons.remove_red_eye),
                  tooltip: 'Acessar aulas do módulo',
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.drag_handle),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Módulos cadastrados'),
        actions: [
          IconButton(
            onPressed: () => _abrirDialogoModulo(),
            icon: const Icon(Icons.add),
            tooltip: 'Novo módulo',
          ),
          IconButton(
            onPressed: () => finalizarSession(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _modulos.isEmpty
              ? const Center(child: Text('Nenhum módulo cadastrado.'))
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: ReorderableListView(
                    buildDefaultDragHandles: false,
                    onReorder: _reordenarModulos,
                    children: [
                      for (int i = 0; i < _modulos.length; i++)
                        _buildModuloCard(_modulos[i], i),
                    ],
                  ),
                ),
    );
  }
}
