import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../controllers/admin_controller.dart';
import '../../controllers/session_controller.dart';
import '../../utils/image_base64.dart';
import '../widgets/basecard.dart';
import 'conteudo_admin_view.dart';

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

  final AdminController _controller = AdminController();
  Timer? _erroFormularioTimer;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _aulas = [];
  bool _isLoading = true;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _aulaListener;

  bool _ignorarListener = false;

  void _mostrarErro(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  bool _excedeuLimiteDocumento(FirebaseException exception) {
    final mensagem = exception.message?.toLowerCase() ?? '';

    return mensagem.contains('1048487 bytes') ||
        mensagem.contains('maximum allowed size') ||
        (mensagem.contains('document') && mensagem.contains('bytes'));
  }

  void _agendarLimpezaErroFormulario(
    BuildContext dialogContext,
    StateSetter setDialogState,
    void Function() limparErro,
  ) {
    _erroFormularioTimer?.cancel();
    _erroFormularioTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted || !dialogContext.mounted) return;

      setDialogState(limparErro);
    });
  }

  @override
  void initState() {
    super.initState();
    _iniciarListenerAula();
  }

  void _iniciarListenerAula() {
    _aulaListener = _controller.watchLessons(widget.idModulo).listen(
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
    _erroFormularioTimer?.cancel();
    _aulaListener?.cancel();
    super.dispose();
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
    } on FirebaseException {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      _mostrarErro('Falha ao carregar aulas.');
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      _mostrarErro('Não foi possível carregar as aulas.');
    }
  }

  Future<void> _salvarNovaOrdem() async {
    await _controller.saveLessonOrder(_aulas);
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
    } on FirebaseException {
      await _carregarAulas();
      _mostrarErro('Falha ao atualizar a ordem das aulas.');
    } catch (_) {
      await _carregarAulas();
      _mostrarErro('Não foi possível reordenar as aulas.');
    } finally {
      _ignorarListener = false;
    }
  }

  Future<void> _atualizarQuantidadeAulasModulo(int delta) async {
    quantidade += delta;

    await _controller.updateModuleLessonCount(widget.idModulo, delta);
  }

  void _excluirAula(String idAula) async {
    try {
      await _controller.deleteLesson(idAula);
      await _atualizarQuantidadeAulasModulo(-1);
    } on FirebaseException {
      _mostrarErro('Falha ao excluir a aula.');
    } catch (_) {
      _mostrarErro('Não foi possível excluir a aula.');
    }
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
    String invalidLabel = 'Imagem inválida.',
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
    try {
      final salvou = await showDialog<bool>(
        context: telaContext,
        builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(editando ? 'Editar aula' : 'Nova aula'),
              content: SizedBox(
                width: 520,
                height: 320,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),
                      TextField(
                        controller: tituloController,
                        maxLength: 50,
                        decoration: const InputDecoration(
                          labelText: 'Titulo',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: tempoEstimadoController,
                        maxLength: 2,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          TextInputFormatter.withFunction(
                              (oldValue, newValue) {
                                if (newValue.text.isEmpty) {
                                  return newValue;
                                }

                                final valor = int.tryParse(newValue.text);

                                if (valor != null && valor <= 40) {
                                  return newValue;
                                }

                                return oldValue;
                              },
                            )
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Tempo estimado (em minutos)',
                          border: OutlineInputBorder(),
                          suffixIcon: Tooltip(
                            message: 'Informe o tempo esperado para o aluno concluir a aula em minutos.\nValor Máximo: 40 minutos',
                            child: const Icon(Icons.info_outline),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),         
                      TextField(
                          controller: totalXPController,
                          maxLength: 3,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            TextInputFormatter.withFunction(
                              (oldValue, newValue) {
                                if (newValue.text.isEmpty) {
                                  return newValue;
                                }

                                final valor = int.tryParse(newValue.text);

                                if (valor != null && valor <= 100) {
                                  return newValue;
                                }

                                return oldValue;
                              },
                            )
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Total XP',
                            border: OutlineInputBorder(),
                            suffixIcon: Tooltip(
                              message: 'Informe a quantidade de pontos que o aluno receberá ao finalizar a aula.\nExemplo: 10, o aluno recebe 10 pontos se não errar nenhum exercício.\nValor Máximo: 100 pontos',
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

                            if (imagem == null || !dialogContext.mounted) {
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
                        invalidLabel: 'A imagem informada é invalida.',
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
                  onPressed: () {
                    _erroFormularioTimer?.cancel();
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final titulo = tituloController.text.trim();
                      final tempoEstimado = tempoEstimadoController.text.trim();
                      final url = imagemBase64.trim();
                      final totalXPTexto = totalXPController.text.trim();
                      final totalXP = int.tryParse(totalXPTexto);

                      if (titulo.isEmpty) {
                        throw Exception('Preencha o título antes de salvar.');
                      }

                      if (totalXPTexto.isEmpty || totalXP == null || totalXP < 0) {
                        throw Exception('Informe um Total XP numérico válido.');
                      }

                      if (url.isEmpty) {
                        throw Exception('Selecione uma imagem antes de salvar.');
                      }
                      if (url.isNotEmpty && converterBase64EmBytes(url) == null) {
                        throw Exception('A imagem informada é invalida.');
                      }

                      if (editando) {
                        await _controller.updateLesson(
                          idAula: aula.id,
                          titulo: titulo,
                          tempoEstimado: tempoEstimado,
                          totalXP: totalXP,
                          url: url,
                        );
                      } else {
                        _ignorarListener = true;
                        atualizaQuantidadeModulo = true;
                        await _controller.createLesson(
                          idModulo: widget.idModulo,
                          titulo: titulo,
                          tempoEstimado: tempoEstimado,
                          totalXP: totalXP,
                          url: url,
                          ordem: _aulas.length,
                        );
                      }

                      _erroFormularioTimer?.cancel();
                      if (!dialogContext.mounted) return;
                      Navigator.of(dialogContext).pop(true);
                    } on FirebaseException catch (ex) {
                      if (!dialogContext.mounted) return;
                      setDialogState(() {
                        erroFormulario = _excedeuLimiteDocumento(ex)
                            ? 'A imagem é muito grande para salvar. Use uma imagem mais leve.'
                            : editando
                                ? 'Falha ao atualizar a aula.'
                                : 'Falha ao salvar a aula.';
                      });
                      _agendarLimpezaErroFormulario(
                        dialogContext,
                        setDialogState,
                        () => erroFormulario = null,
                      );
                    } catch (ex) {
                      if (!dialogContext.mounted) return;
                      setDialogState(() {
                        erroFormulario = ex.toString().replaceFirst('Exception: ', '');
                      });
                      _agendarLimpezaErroFormulario(
                        dialogContext,
                        setDialogState,
                        () => erroFormulario = null,
                      );
                    }
                    
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
    } finally {
      _erroFormularioTimer?.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 200));
      tituloController.dispose();
      totalXPController.dispose();
      tempoEstimadoController.dispose();
    }
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
