import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'base64.dart';
import 'basecard.dart';
import 'conteudoAdmin.dart';
import 'session.dart';

class AulaAdmin extends StatefulWidget {
  final String idModulo;
  final int quantidade;

  const AulaAdmin({
    super.key,
    required this.idModulo,
    required this.quantidade,
  });

  @override
  State<AulaAdmin> createState() => _AulaAdminState();
}

class _AulaAdminState extends State<AulaAdmin> {
  late int quantidade = widget.quantidade;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _aulas = [];
  bool _isLoading = true;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _aulaListener;

  bool _ignorarListener = false;

  @override
  void initState() {
    super.initState();
    _iniciarListenerAula();
  }

  void _iniciarListenerAula() {
    _aulaListener = _firestore
        .collection('aula')
        .orderBy('ordem')
        .where('idModulo', isEqualTo: widget.idModulo)
        .snapshots()
        .listen(
      (_) async {
        if(_ignorarListener) return;
        await _carregarAulas();
      },
      onError: (error) async {
        if(_ignorarListener) return;
        await _carregarAulas();
      },
    );
  }

  @override
  void dispose() {
    _aulaListener?.cancel();
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
          .orderBy('ordem')
          .where('idModulo', isEqualTo: widget.idModulo)
          .get();
    } catch (_) {
      snapshot = await _firestore
          .collection('aula')
          .where('idModulo', isEqualTo: widget.idModulo)
          .get();

      for (int i = 0; i < snapshot.docs.length; i++) {
        await _firestore.collection('aula').doc(snapshot.docs[i].id).set({
          'ordem': i,
        }, SetOptions(merge: true));
      }

      snapshot = await _firestore
          .collection('aula')
          .where('idModulo', isEqualTo: widget.idModulo)
          .orderBy('ordem')
          .get();
    }

    if (!mounted) return;

    setState(() {
      _aulas = snapshot.docs;
      _isLoading = false;
    });
  }

  Future<void> _salvarNovaOrdem() async {
    final batch = _firestore.batch();

    for (int i = 0; i < _aulas.length; i++) {
      batch.update(_firestore.collection('aula').doc(_aulas[i].id), {
        'ordem': i,
      });
    }

    await batch.commit();
  }

  Future<void> _reordenarAulas(int oldIndex, int newIndex) async {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      final item = _aulas.removeAt(oldIndex);
      _aulas.insert(newIndex, item);
    });

    _ignorarListener = true;

    try {
      await _salvarNovaOrdem();
      await _carregarAulas();
    } finally {
      _ignorarListener = false;
    }
  }

  Future<void> _atualizarQuantidadeAulasModulo(int delta) async {
    quantidade += delta;

    await _firestore.collection('modulo').doc(widget.idModulo).update({
      'quantidade': FieldValue.increment(delta),
    });
  }

  void _excluirAula(String idAula) async {
    final listaConteudo = await _firestore
    .collection('conteudo')
    .where('idAula', isEqualTo: idAula)
    .get();

    final batch = _firestore.batch();

    batch.delete(
      _firestore.collection('aula').doc(idAula),
    );

    for (var conteudo in listaConteudo.docs) {
      batch.delete(conteudo.reference);
    }

    await batch.commit();
    await _atualizarQuantidadeAulasModulo(-1);
  }

  void _acessarConteudo(String idAula) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConteudoAdmin(idAula: idAula),
      ),
    );
  }

  Widget _buildImagemPreview(
    String valor, {
    double altura = 140,
    String emptyLabel = 'Nenhuma imagem cadastrada.',
    String invalidLabel = 'Imagem invalida.',
  }) {
    final texto = valor.trim();

    if (texto.isEmpty) {
      return _buildPlaceholder(emptyLabel, altura: altura);
    }

    final bytes = converterBase64EmBytes(texto);

    if (bytes == null) {
      return _buildPlaceholder(invalidLabel, altura: altura);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.memory(
        bytes,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(invalidLabel, altura: altura);
        },
      ),
    );
  }

  Widget _buildPlaceholder(String texto, {double altura = 140}) {
    return Container(
      width: double.infinity,
      height: altura,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          texto,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<void> _abrirDialogoAula({
    QueryDocumentSnapshot<Map<String, dynamic>>? aula,
  }) async {
    final tituloController = TextEditingController(
      text: aula?.data()['titulo']?.toString() ?? '',
    );
    final totalXPController = TextEditingController(
      text: aula?.data()['totalXP']?.toString() ?? '',
    );
    final tempoEstimadoController = TextEditingController(
      text: aula?.data()['tempoEstimado']?.toString() ?? '',
    );
    final bool editando = aula != null;
    String imagemBase64 = aula?.data()['url']?.toString() ?? '';
    String? erroFormulario;
    bool atualizaQuantidadeModulo = false;

    final telaContext = context;
    final salvou = await showDialog<bool>(
      context: telaContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(editando ? 'Editar aula' : 'Nova aula'),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),
                      TextField(
                        controller: tituloController,
                        decoration: const InputDecoration(
                          labelText: 'Titulo',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: tempoEstimadoController,
                        decoration: const InputDecoration(
                          labelText: 'Tempo estimado (em minutos)',
                          border: OutlineInputBorder(),
                          suffixIcon: Tooltip(
                            message: 'Informe o tempo esperado para o aluno concluir a aula em minutos.',
                            child: const Icon(Icons.info_outline),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),         
                      TextField(
                          controller: totalXPController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Total XP',
                            border: OutlineInputBorder(),
                            suffixIcon: Tooltip(
                              message: 'Informe a quantidade de pontos que o aluno receberá ao finalizar a aula.\nExemplo: 10, o aluno recebe 10 pontos se não errar nenhum exercício.',
                              child: const Icon(Icons.info_outline),
                            ),
                          ),
                      ),
                   
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final imagem = await selecionarImagemBase64();

                            if (imagem == null) {
                              return;
                            }

                            setDialogState(() {
                              imagemBase64 = imagem;
                              erroFormulario = null;
                            });
                          },
                          icon: const Icon(Icons.upload),
                          label: const Text('Selecionar imagem'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildImagemPreview(
                        imagemBase64,
                        altura: 180,
                        emptyLabel: 'Nenhuma imagem selecionada.',
                        invalidLabel: 'A imagem informada e invalida.',
                      ),
                      if (erroFormulario != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          erroFormulario!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
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

                    final tempoEstimado = tempoEstimadoController.text.trim();
                    final url = imagemBase64.trim();
                    final totalXPTexto = totalXPController.text.trim();
                    final totalXP = int.tryParse(totalXPTexto);

                    if (titulo.isEmpty) {
                      setDialogState(() {
                        erroFormulario = 'Preencha o titulo antes de salvar.';
                      });
                      return;
                    }

                    if (totalXPTexto.isEmpty || totalXP == null || totalXP < 0) {
                      setDialogState(() {
                        erroFormulario =
                            'Informe um Total XP numerico valido.';
                      });
                      return;
                    }

                    if (url.isNotEmpty && converterBase64EmBytes(url) == null) {
                      setDialogState(() {
                        erroFormulario = 'A imagem informada e invalida.';
                      });
                      return;
                    }

                    if (editando) {
                      await _firestore.collection('aula').doc(aula.id).update({
                        'titulo': titulo,
                        'tempoEstimado': tempoEstimado,
                        'totalXP': totalXP,
                        'url': url,
                      });
                    } else {
                      _ignorarListener = true;
                      atualizaQuantidadeModulo = true;

                      final novoDoc = _firestore.collection('aula').doc();

                      await novoDoc.set({
                        'id': novoDoc.id,
                        'idModulo': widget.idModulo,
                        'titulo': titulo,
                        'tempoEstimado': tempoEstimado,
                        'totalXP': totalXP,
                        'url': url,
                        'ordem': _aulas.length,
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
        if (atualizaQuantidadeModulo) {
          await _atualizarQuantidadeAulasModulo(1);
        }

        await _carregarAulas();
      } finally {
        _ignorarListener = false;
      }
    } else {
      _ignorarListener = false;
    }
    
    tituloController.dispose();
    totalXPController.dispose();
    tempoEstimadoController.dispose();
  }

  Widget _buildAulaCard(
    QueryDocumentSnapshot<Map<String, dynamic>> aula,
    int index,
  ) {
    final data = aula.data();
    final titulo = data['titulo']?.toString() ?? '';
    final tempoEstimado = data['tempoEstimado']?.toString() ?? '';
    final url = data['url']?.toString() ?? '';

    return Card(
      key: ValueKey(aula.id),
      margin: EdgeInsets.zero,
      color: Colors.transparent,
      elevation: 0,
      child: CustomAppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5,
          children: [
            Column(
              spacing: 5,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(
                  widthFactor: 1.0,
                  child: _buildImagemPreview(url),
                ),
                
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Tempo estimado: $tempoEstimado minutos'),
                const SizedBox(height: 4),
                
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => _abrirDialogoAula(aula: aula),
                  icon: const Icon(Icons.edit),
                  tooltip: 'Editar aula',
                ),
                IconButton(
                  onPressed: () => _excluirAula(aula.id),
                  icon: const Icon(Icons.delete),
                  tooltip: 'Excluir aula',
                ),
                IconButton(
                  onPressed: () => _acessarConteudo(aula.id),
                  icon: const Icon(Icons.remove_red_eye),
                  tooltip: 'Acessar conteudo',
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.drag_handle),
                  ),
                ),
                const SizedBox(width: 16),
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
        title: const Text('Aulas cadastradas'),
        actions: [
          IconButton(
            onPressed: () => _abrirDialogoAula(),
            icon: const Icon(Icons.add),
            tooltip: 'Nova aula',
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
          : _aulas.isEmpty
              ? const Center(child: Text('Nenhuma aula cadastrada.'))
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: ReorderableListView(
                    buildDefaultDragHandles: false,
                    onReorder: _reordenarAulas,
                    children: [
                      for (int i = 0; i < _aulas.length; i++)
                        _buildAulaCard(_aulas[i], i),
                    ],
                  ),
                ),
    );
  }
}
