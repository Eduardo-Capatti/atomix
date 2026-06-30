import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../controllers/admin_controller.dart';
import '../../utils/image_base64.dart';
import '../widgets/basecard.dart';

class ConteudoAdmin extends StatefulWidget {
  final String idAula;

  const ConteudoAdmin({
    super.key,
    required this.idAula,
  });

  @override
  State<ConteudoAdmin> createState() => _ConteudoAdminState();
}

class _ConteudoAdminState extends State<ConteudoAdmin> {
  final AdminController _controller = AdminController();
  Timer? _erroFormularioTimer;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _paginas = [];
  bool _isLoading = true;
  int _paginaAtualIndex = 0;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _paginasListener;
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
    _iniciarListenerPaginas();
  }

  void _iniciarListenerPaginas() {
    _paginasListener = _controller.watchPages(widget.idAula).listen(
      (_) async {
        if (_ignorarListener) return;
        await _carregarPaginas();
      },
      onError: (error) async {
        if (_ignorarListener) return;
        await _carregarPaginas();
      },
    );
  }

  @override
  void dispose() {
    _erroFormularioTimer?.cancel();
    _paginasListener?.cancel();
    super.dispose();
  }

  bool get _temPaginas => _paginas.isNotEmpty;

  QueryDocumentSnapshot<Map<String, dynamic>>? get _paginaAtualDoc {
    if (!_temPaginas) {
      return null;
    }

    return _paginas[_paginaAtualIndex];
  }

  Map<String, dynamic> get _paginaAtualData {
    return _paginaAtualDoc?.data() ?? <String, dynamic>{};
  }

  List<Map<String, dynamic>> get _conteudosPaginaAtual {
    final conteudos = _paginaAtualData['conteudos'];

    if (conteudos is! List) {
      return [];
    }

    final lista = conteudos
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    lista.sort(
      (a, b) => ((a['ordem'] ?? 0) as num).compareTo((b['ordem'] ?? 0) as num),
    );

    return lista;
  }

  Future<void> _carregarPaginas({int? paginaDesejada}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      var paginas = await _controller.fetchPages(widget.idAula);

      final alterou = await _normalizarPaginas(paginas);

      if (alterou) {
        paginas = await _controller.fetchOrderedPages(widget.idAula);
      }

      if (!mounted) return;

      int novoIndice = 0;

      if (paginas.isNotEmpty) {
        if (paginaDesejada != null) {
          novoIndice = paginas.indexWhere(
            (doc) => (doc.data()['pagina'] ?? 0) == paginaDesejada,
          );
        } else if (_paginaAtualIndex < paginas.length) {
          novoIndice = _paginaAtualIndex;
        } else {
          novoIndice = paginas.length - 1;
        }

        if (novoIndice < 0) {
          novoIndice = 0;
        }
      }

      setState(() {
        _paginas = paginas;
        _paginaAtualIndex = novoIndice;
        _isLoading = false;
      });
    } on FirebaseException {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      _mostrarErro('Falha ao carregar conteúdos.');
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      _mostrarErro('Não foi possível carregar os conteúdos.');
    }
  }

  Future<bool> _normalizarPaginas(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> paginas,
  ) async {
    bool alterou = false;

    for (int i = 0; i < paginas.length; i++) {
      final data = paginas[i].data();
      final conteudos = _normalizarConteudos(
        List<Map<String, dynamic>>.from(
          (data['conteudos'] as List? ?? []).map(
            (item) => Map<String, dynamic>.from(item as Map),
          ),
        ),
      );

      if ((data['pagina'] ?? 0) != i + 1 ||
          !_controller.contentListsAreEqual(data['conteudos'], conteudos)) {
        alterou = true;
        await _controller.setPageData(
          idPagina: paginas[i].id,
          data: {
            'id': paginas[i].id,
            'idAula': widget.idAula,
            'pagina': i + 1,
            'conteudos': conteudos,
          },
        );
      }
    }

    return alterou;
  }

  Future<void> _executarSemListener(Future<void> Function() acao) async {
    _ignorarListener = true;

    try {
      await acao();
    } finally {
      _ignorarListener = false;
    }
  }

  List<Map<String, dynamic>> _normalizarConteudos(List<Map<String, dynamic>> conteudos) {
    return _controller.normalizeContents(conteudos);
  }

  Future<void> _adicionarPagina() async {
    try {
      await _executarSemListener(() async {
        final proximaPagina = _paginas.length + 1;

        await _controller.createPage(
          idAula: widget.idAula,
          pagina: proximaPagina,
        );

        await _carregarPaginas(paginaDesejada: proximaPagina);
      });
    } on FirebaseException {
      _mostrarErro('Falha ao adicionar página.');
    } catch (_) {
      _mostrarErro('Não foi possível adicionar a página.');
    }
  }

  Future<void> _excluirPaginaAtual() async {
    final pagina = _paginaAtualDoc;

    if (pagina == null) {
      return;
    }

    final paginaAtual = (_paginaAtualData['pagina'] as num?)?.toInt() ?? 1;

    try {
      await _executarSemListener(() async {
        await _controller.deletePage(pagina.id);

        await _carregarPaginas(
          paginaDesejada: _paginas.length <= 1
              ? null
              : (paginaAtual > 1 ? paginaAtual - 1 : 1),
        );
      });
    } on FirebaseException {
      _mostrarErro('Falha ao excluir a página.');
    } catch (_) {
      _mostrarErro('Não foi possível excluir a página.');
    }
  }

  Future<void> _moverPagina(int direcao) async {
    if (!_temPaginas) return;

    final novoIndice = _paginaAtualIndex + direcao;

    if (novoIndice < 0 || novoIndice >= _paginas.length) {
      return;
    }

    final paginaAtual = _paginas[_paginaAtualIndex];
    final paginaDestino = _paginas[novoIndice];
    final numeroAtual =
        (paginaAtual.data()['pagina'] as num?)?.toInt() ?? (_paginaAtualIndex + 1);
    final numeroDestino =
        (paginaDestino.data()['pagina'] as num?)?.toInt() ?? (novoIndice + 1);

    try {
      await _executarSemListener(() async {
        await _controller.swapPages(
          idPaginaAtual: paginaAtual.id,
          numeroAtual: numeroAtual,
          idPaginaDestino: paginaDestino.id,
          numeroDestino: numeroDestino,
        );
        await _carregarPaginas(paginaDesejada: numeroDestino);
      });
    } on FirebaseException {
      _mostrarErro('Falha ao mover a página.');
    } catch (_) {
      _mostrarErro('Não foi possível mover a página.');
    }
  }

  void _irParaPagina(int index) {
    if (index < 0 || index >= _paginas.length) {
      return;
    }

    setState(() {
      _paginaAtualIndex = index;
    });
  }

  Future<void> _salvarConteudosPaginaAtual(
    List<Map<String, dynamic>> conteudos, {
    bool recarregarPagina = true,
  }) async {
    final pagina = _paginaAtualDoc;

    if (pagina == null) {
      return;
    }

    try {
      await _executarSemListener(() async {
        await _controller.updatePageContents(
          idPagina: pagina.id,
          conteudos: _normalizarConteudos(conteudos),
        );

        if (recarregarPagina) {
          await _carregarPaginas(
            paginaDesejada:
                (_paginaAtualData['pagina'] as num?)?.toInt() ??
                (_paginaAtualIndex + 1),
          );
        }
      });
    } catch (_) {
      rethrow;
    }
  }

  Future<void> _excluirConteudo(int index) async {
    final conteudos = List<Map<String, dynamic>>.from(_conteudosPaginaAtual);

    if (index < 0 || index >= conteudos.length) {
      return;
    }

    try {
      conteudos.removeAt(index);
      await _salvarConteudosPaginaAtual(conteudos);
    } on FirebaseException {
      _mostrarErro('Falha ao excluir o conteúdo.');
    } catch (_) {
      _mostrarErro('Não foi possível excluir o conteúdo.');
    }
  }

  Future<void> _reordenarConteudos(int oldIndex, int newIndex) async {
    final conteudos = List<Map<String, dynamic>>.from(_conteudosPaginaAtual);

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    try {
      final item = conteudos.removeAt(oldIndex);
      conteudos.insert(newIndex, item);

      await _salvarConteudosPaginaAtual(conteudos);
    } on FirebaseException {
      _mostrarErro('Falha ao reordenar os conteúdos.');
    } catch (_) {
      _mostrarErro('Não foi possível reordenar os conteúdos.');
    }
  }

  Future<void> _abrirDialogoConteudo({
    Map<String, dynamic>? conteudo,
    int? index,
  }) async {
    String tipo = conteudo?['tipo']?.toString() ?? 'texto';
    String tipo2 = conteudo?['tipo2']?.toString() ?? 'texto';

    String imagemBase64 =
        tipo == 'imagem' ? (conteudo?['conteudo']?.toString() ?? '') : '';

    final conteudoController = TextEditingController(
      text: tipo == 'imagem'
          ? imagemBase64
          : conteudo?['conteudo']?.toString() ?? '',
    );

    final perguntaController = TextEditingController(
      text: conteudo?['pergunta']?.toString() ?? '',
    );

    final bool editando = conteudo != null;

    final respostasIniciais = tipo == 'exercicio'
        ? List<String>.from(conteudo?['conteudo'] as List? ?? [])
        : <String>[];

    final respostaControllers = respostasIniciais.isEmpty
        ? <TextEditingController>[
            TextEditingController(),
            TextEditingController(),
          ]
        : respostasIniciais
            .map((item) => TextEditingController(text: item))
            .toList();

    final dicaController = TextEditingController(
      text: conteudo?['dica']?.toString() ?? '',
    );

    final respostasImagem = respostasIniciais.isEmpty
        ? <String>['', '']
        : List<String>.from(respostasIniciais);

    int respostaCorreta =
        (((conteudo?['resposta'] as num?)?.toInt() ?? 1).clamp(
      1,
      respostasIniciais.isEmpty ? 2 : respostasIniciais.length,
    ) as num)
            .toInt();

    String? erroFormulario;
    final telaContext = context;
    final bool paginaTemOutroExercicio = _conteudosPaginaAtual
        .asMap()
        .entries
        .any((entry) => entry.key != index && entry.value['tipo'] == 'exercicio');
    final bool hasExercise = paginaTemOutroExercicio;
    final Map<String, Map<String, dynamic>> rascunhosPorTipo = {
      'texto': {
        'conteudo': tipo == 'texto' ? conteudoController.text : '',
      },
      'video': {
        'conteudo': tipo == 'video' ? conteudoController.text : '',
      },
      'imagem': {
        'conteudo': tipo == 'imagem' ? imagemBase64 : '',
      },
      'exercicio': {
        'pergunta': tipo == 'exercicio' ? perguntaController.text : '',
        'dica': tipo == 'exercicio' ? dicaController.text : '',
        'tipo2': tipo == 'exercicio' ? tipo2 : 'texto',
        'resposta': tipo == 'exercicio' ? respostaCorreta : 1,
        'respostas': tipo == 'exercicio'
            ? respostaControllers.map((controller) => controller.text).toList()
            : <String>['', ''],
        'respostasImagem': tipo == 'exercicio'
            ? List<String>.from(respostasImagem)
            : <String>['', ''],
      },
    };

    void aplicarQuantidadeRespostas(int quantidade) {
      while (respostaControllers.length > quantidade) {
        respostaControllers.removeLast().dispose();
      }

      while (respostaControllers.length < quantidade) {
        respostaControllers.add(TextEditingController());
      }

      while (respostasImagem.length > quantidade) {
        respostasImagem.removeLast();
      }

      while (respostasImagem.length < quantidade) {
        respostasImagem.add('');
      }
    }

    void salvarRascunhoAtual() {
      if (tipo == 'texto' || tipo == 'video') {
        rascunhosPorTipo[tipo] = {
          'conteudo': conteudoController.text,
        };
        return;
      }

      if (tipo == 'imagem') {
        rascunhosPorTipo[tipo] = {
          'conteudo': imagemBase64,
        };
        return;
      }

      if (tipo == 'exercicio') {
        rascunhosPorTipo[tipo] = {
          'pergunta': perguntaController.text,
          'dica': dicaController.text,
          'tipo2': tipo2,
          'resposta': respostaCorreta,
          'respostas': respostaControllers.map((controller) => controller.text).toList(),
          'respostasImagem': List<String>.from(respostasImagem),
        };
      }
    }

    void restaurarCamposDoTipo(String novoTipo) {
      final rascunho = rascunhosPorTipo[novoTipo] ?? <String, dynamic>{};

      conteudoController.clear();
      imagemBase64 = '';
      perguntaController.clear();
      dicaController.clear();
      tipo2 = 'texto';
      respostaCorreta = 1;
      aplicarQuantidadeRespostas(2);

      if (novoTipo == 'texto' || novoTipo == 'video') {
        conteudoController.text = rascunho['conteudo']?.toString() ?? '';
        return;
      }

      if (novoTipo == 'imagem') {
        imagemBase64 = rascunho['conteudo']?.toString() ?? '';
        conteudoController.text = imagemBase64;
        return;
      }

      final respostas = List<String>.from(
        rascunho['respostas'] as List? ?? const <String>['', ''],
      );
      final respostasImg = List<String>.from(
        rascunho['respostasImagem'] as List? ?? const <String>['', ''],
      );
      final quantidade = respostas.isEmpty ? 2 : respostas.length;

      aplicarQuantidadeRespostas(quantidade);
      perguntaController.text = rascunho['pergunta']?.toString() ?? '';
      dicaController.text = rascunho['dica']?.toString() ?? '';
      tipo2 = rascunho['tipo2']?.toString() ?? 'texto';
      respostaCorreta = ((rascunho['resposta'] as num?)?.toInt() ?? 1).clamp(
        1,
        quantidade,
      );

      for (int i = 0; i < quantidade; i++) {
        respostaControllers[i].text = i < respostas.length ? respostas[i] : '';
        respostasImagem[i] = i < respostasImg.length ? respostasImg[i] : '';
      }
    }

  Future<void> selecionarImagemResposta(
    int respostaIndex,
    StateSetter setDialogState,
  ) async {
      final imagem = await selecionarImagemBase64();

      if (imagem == null) return;

      setDialogState(() {
        respostasImagem[respostaIndex] = imagem;
        respostaControllers[respostaIndex].text = imagem;
      });
    }

    final salvou = await showDialog<bool>(
      context: telaContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(editando ? 'Editar conteúdo' : 'Novo conteúdo'),
              content: SizedBox(
                width: 520,
                height: 320,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: tipo,
                        decoration: const InputDecoration(
                          labelText: 'Tipo',
                          border: OutlineInputBorder(),
                          suffixIcon: Tooltip(
                            message: 'Recomenda-se que os exercícios sejam cadastrados ao fim da página, apenas um exercício por página é permitido.',
                            child: const Icon(Icons.info_outline),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(value: 'texto', child: Text('Texto')),
                          DropdownMenuItem(value: 'imagem', child: Text('Imagem')),
                          DropdownMenuItem(value: 'video', child: Text('Vídeo')),
                          DropdownMenuItem(
                            enabled: !paginaTemOutroExercicio || tipo == 'exercicio',
                            value: 'exercicio',
                            child: Text('Exercício', style: TextStyle(color: (hasExercise && !editando) ? Colors.grey : Colors.black)),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          if (value == tipo) return;

                          setDialogState(() {
                            salvarRascunhoAtual();
                            tipo = value;
                            erroFormulario = null;
                            restaurarCamposDoTipo(value);
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      if (tipo == 'texto')
                        TextField(
                          controller: conteudoController,
                          maxLines: 3,
                          maxLength: 300,
                          decoration: const InputDecoration(
                            labelText: 'Conteúdo',
                            border: OutlineInputBorder(),
                          ),
                        ),

                      if (tipo == 'video')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: conteudoController,
                              decoration: const InputDecoration(
                                labelText: 'Link do YouTube',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (_) {
                                setDialogState(() {
                                  erroFormulario = null;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildVideoPreview(conteudoController.text),
                          ],
                        ),

                      if (tipo == 'imagem') ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final imagem = await selecionarImagemBase64();

                              if (imagem == null) return;

                              if (!dialogContext.mounted) return;

                              setDialogState(() {
                                imagemBase64 = imagem;
                                conteudoController.text = imagem;
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
                          emptyLabel: 'Nenhuma imagem selecionada.',
                          invalidLabel: 'A imagem informada é inválida.',
                        ),
                      ],

                      if (tipo == 'exercicio') ...[
                        DropdownButtonFormField<String>(
                          initialValue: tipo2,
                          decoration: const InputDecoration(
                            labelText: 'Tipo das respostas',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'texto', child: Text('Texto')),
                            DropdownMenuItem(value: 'imagem', child: Text('Imagem')),
                          ],
                          onChanged: (value) {
                            if (value == null) return;

                            setDialogState(() {
                              tipo2 = value;
                              erroFormulario = null;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: perguntaController,
                          maxLines: 3,
                          maxLength: 300,
                          decoration: const InputDecoration(
                            labelText: 'Pergunta',
                            border: OutlineInputBorder(),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Respostas',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                setDialogState(() {
                                  respostaControllers
                                      .add(TextEditingController());
                                  respostasImagem.add('');
                                });
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('resposta'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        for (int i = 0; i < respostaControllers.length; i++) ...[
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Radio<int>(
                                      value: i + 1,
                                      groupValue: respostaCorreta,
                                      onChanged: (value) {
                                        if (value == null) return;

                                        setDialogState(() {
                                          respostaCorreta = value;
                                        });
                                      },
                                    ),
                                    Expanded(
                                      child: Text('Resposta ${i + 1}'),
                                    ),
                                    if (respostaControllers.length > 2)
                                      IconButton(
                                        onPressed: () {
                                          setDialogState(() {
                                            final controllerRemovido =
                                                respostaControllers.removeAt(i);

                                            respostasImagem.removeAt(i);

                                            if (respostaCorreta >
                                                respostaControllers.length) {
                                              respostaCorreta =
                                                  respostaControllers.length;
                                            }

                                            if (respostaCorreta < 1) {
                                              respostaCorreta = 1;
                                            }

                                            controllerRemovido.dispose();
                                          });
                                        },
                                        icon: const Icon(Icons.delete),
                                        tooltip: 'Remover resposta',
                                      ),
                                  ],
                                ),   

                                if (tipo2 == 'texto')
                                  TextField(
                                    controller: respostaControllers[i],
                                    maxLength: 300,
                                    decoration: const InputDecoration(
                                      labelText: 'Texto da resposta',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),

                                if (tipo2 == 'imagem') ...[
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => selecionarImagemResposta(
                                        i,
                                        setDialogState,
                                      ),
                                      icon: const Icon(Icons.upload),
                                      label: Text('Selecionar imagem ${i + 1}'),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildImagemPreview(
                                    respostasImagem[i],
                                    emptyLabel: 'Nenhuma imagem selecionada.',
                                    invalidLabel:
                                        'A imagem informada é inválida.',
                                  ),
                                ],

                              ],
                            ),
                          ),
                        ],
                         TextField(
                            controller: dicaController,
                            maxLines: 2,
                            maxLength: 300,
                            decoration: const InputDecoration(
                              labelText: 'Dica',
                              border: OutlineInputBorder(),
                              suffixIcon: Tooltip(
                                message: 'Uma dica/pista para ajudar o aluno caso ele erre a questão.',
                                child: const Icon(Icons.info_outline),
                              ),
                            ),
                          ),
                      ],

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
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                    final conteudos =
                        List<Map<String, dynamic>>.from(_conteudosPaginaAtual);

                    Map<String, dynamic>? novoConteudo;

                    if (tipo == 'texto' || tipo == 'video') {
                      final valor = conteudoController.text.trim();

                      if (valor.isEmpty) {
                        setDialogState(() {
                          erroFormulario =
                              'Preencha o conteúdo antes de salvar.';
                        });
                        return;
                      }

                      if (tipo == 'video' &&
                          YoutubePlayerController.convertUrlToId(valor) == null) {
                        setDialogState(() {
                          erroFormulario =
                              'Informe um link vÃ¡lido do YouTube antes de salvar.';
                        });
                        return;
                      }

                      novoConteudo = {
                        'ordem': index ?? conteudos.length,
                        'tipo': tipo,
                        'conteudo': valor,
                      };
                    }

                    if (tipo == 'imagem') {
                      final valor = imagemBase64.trim();

                      if (valor.isEmpty) {
                        setDialogState(() {
                          erroFormulario =
                              'Selecione uma imagem antes de salvar.';
                        });
                        return;
                      }

                      if (converterBase64EmBytes(valor) == null) {
                        setDialogState(() {
                          erroFormulario = 'A imagem informada é inválida.';
                        });
                        return;
                      }

                      novoConteudo = {
                        'ordem': index ?? conteudos.length,
                        'tipo': 'imagem',
                        'conteudo': valor,
                      };
                    }

                    if (tipo == 'exercicio') {
                      final pergunta = perguntaController.text.trim();
                      final respostas = <String>[];
                      final dica = dicaController.text.trim();

                      for (int i = 0; i < respostaControllers.length; i++) {
                        final valor = respostaControllers[i].text.trim();
                        respostas.add(valor);
                      }

                      if (pergunta.isEmpty) {
                        setDialogState(() {
                          erroFormulario =
                              'Preencha a pergunta do exercício.';
                        });
                        return;
                      }


                      if (respostas.length < 2) {
                        setDialogState(() {
                          erroFormulario =
                              'O exercício precisa de pelo menos 2 respostas.';
                        });
                        return;
                      }

                      if (respostas.any((item) => item.isEmpty)) {
                        setDialogState(() {
                          erroFormulario =
                              'Preencha todas as respostas antes de salvar.';
                        });
                        return;
                      }

                      if (tipo2 == 'imagem') {
                        for (final resposta in respostas) {
                          if (converterBase64EmBytes(resposta) == null) {
                            setDialogState(() {
                              erroFormulario =
                                  'Todas as respostas em imagem precisam ter base64 válido.';
                            });
                            return;
                          }
                        }
                      }

                      novoConteudo = {
                        'ordem': index ?? conteudos.length,
                        'tipo': 'exercicio',
                        'tipo2': tipo2,
                        'pergunta': pergunta,
                        'conteudo': respostas,
                        'resposta': respostaCorreta,
                        'dica': dica
                      };
                    }

                    if (novoConteudo == null) return;

                    if (editando && index != null) {
                      conteudos[index] = novoConteudo;
                    } else {
                      conteudos.add(novoConteudo);
                    }

                    await _salvarConteudosPaginaAtual(
                      conteudos,
                      recarregarPagina: false,
                    );

                      if (!dialogContext.mounted) return;
                      Navigator.of(dialogContext).pop(true);
                    } on FirebaseException catch (ex) {
                      setDialogState(() {
                        erroFormulario = _excedeuLimiteDocumento(ex)
                            ? 'A imagem é muito grande para salvar. Use uma imagem mais leve.'
                            : editando
                                ? 'Falha ao atualizar o conteudo.'
                                : 'Falha ao salvar o conteudo.';
                      });
                      _agendarLimpezaErroFormulario(
                        dialogContext,
                        setDialogState,
                        () => erroFormulario = null,
                      );
                    } catch (ex) {
                      setDialogState(() {
                        erroFormulario =
                            ex.toString().replaceFirst('Exception: ', '');
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

    if (salvou == true) {
      if (!mounted) return;

      await _carregarPaginas(
        paginaDesejada:
            (_paginaAtualData['pagina'] as num?)?.toInt() ??
            (_paginaAtualIndex + 1),
      );
    }

    conteudoController.dispose();
    perguntaController.dispose();

    for (final controller in respostaControllers) {
      controller.dispose();
    }
  }

  Widget _buildImagemPreview(
    String valor, {
    required String emptyLabel,
    required String invalidLabel,
    double tamanho = 180,
    bool quadrado = false,
  }) {
    final texto = valor.trim();

    if (texto.isEmpty) {
      return _buildPlaceholder(emptyLabel);
    }

    final bytes = converterBase64EmBytes(texto);

    if (bytes == null) {
      return _buildPlaceholder(invalidLabel);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: double.infinity,
        child: Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder(
              invalidLabel,
              tamanho: tamanho,
              quadrado: quadrado,
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholder(
    String texto, {
    double tamanho = 180,
    bool quadrado = false,
  }) {
    return SizedBox(
      width: quadrado ? tamanho : double.infinity,
      height: tamanho,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          texto,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildImagemConteudoCard(String valor) {
    return Center(
      child: _buildImagemPreview(
        valor,
        emptyLabel: 'Nenhuma imagem cadastrada.',
        invalidLabel: 'Imagem inválida.',
        tamanho: 250,
        quadrado: true,
      ),
    );
  }

  Widget _buildVideoPreview(String valor) {
    final link = valor.trim();

    if (link.isEmpty) {
      return _buildPlaceholder('Nenhum link de video cadastrado.', tamanho: 220);
    }

    final videoId = YoutubePlayerController.convertUrlToId(link);

    if (videoId == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            link,
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
          const SizedBox(height: 12),
          _buildPlaceholder('Link do YouTube inválido.', tamanho: 220),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          link,
          style: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
        const SizedBox(height: 12),
        _YoutubePreview(videoId: videoId),
      ],
    );
  }

  List<int> _paginasVisiveis() {
    if (!_temPaginas) {
      return [];
    }

    final indices = <int>{_paginaAtualIndex};

    if (_paginaAtualIndex > 0) {
      indices.add(_paginaAtualIndex - 1);
    }

    if (_paginaAtualIndex < _paginas.length - 1) {
      indices.add(_paginaAtualIndex + 1);
    }

    final lista = indices.toList()..sort();
    return lista;
  }

  Widget _buildCabecalhoPaginas() {
    if (!_temPaginas) {
      return const SizedBox.shrink();
    }

    final paginasVisiveis = _paginasVisiveis();

    return CustomAppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final index in paginasVisiveis)
                      InkWell(
                        onTap: () => _irParaPagina(index),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: index == _paginaAtualIndex
                                ? Colors.blue.shade50
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: index == _paginaAtualIndex
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            'Página ${index + 1}',
                            style: TextStyle(
                              fontWeight: index == _paginaAtualIndex
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _paginaAtualIndex == 0 ? null : () => _moverPagina(-1),
                icon: const Icon(Icons.keyboard_arrow_up),
                tooltip: 'Subir página',
              ),
              IconButton(
                onPressed: _paginaAtualIndex == _paginas.length - 1
                    ? null
                    : () => _moverPagina(1),
                icon: const Icon(Icons.keyboard_arrow_down),
                tooltip: 'Descer página',
              ),
              IconButton(
                onPressed: _excluirPaginaAtual,
                icon: const Icon(Icons.delete),
                tooltip: 'Excluir página',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Página atual: ${_paginaAtualIndex + 1}',
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildResumoExercicio(Map<String, dynamic> conteudo) {
    final pergunta = conteudo['pergunta']?.toString() ?? '';
    final tipo2 = conteudo['tipo2']?.toString() ?? 'texto';
    final respostas = List<String>.from(conteudo['conteudo'] as List? ?? []);
    final resposta = (conteudo['resposta'] as num?)?.toInt() ?? 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          pergunta,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text('Tipo das respostas: $tipo2'),
        Text('Quantidade de respostas: ${respostas.length}'),
        Text('Resposta correta: $resposta'),
      ],
    );
  }

  Widget _buildConteudoCard(Map<String, dynamic> conteudo, int index) {
    final tipo = conteudo['tipo']?.toString() ?? '';
    final valor = conteudo['conteudo'];

    return Card(
      key: ValueKey('conteudo-$index-${conteudo['ordem']}'),
      margin: EdgeInsets.zero,
      color: Colors.transparent,
      elevation: 0,
      child: CustomAppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 5,
          children: [
            Text(
              'Ordem ${conteudo['ordem']} • ${tipo.toUpperCase()}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            if (tipo == 'texto') Text(valor?.toString() ?? ''),
            if (tipo == 'video') _buildVideoPreview(valor?.toString() ?? ''),
            if (tipo == 'imagem') _buildImagemConteudoCard(valor?.toString() ?? ''),
            if (tipo == 'exercicio') _buildResumoExercicio(conteudo),
            const SizedBox(width: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => _abrirDialogoConteudo(
                    conteudo: conteudo,
                    index: index,
                  ),
                  icon: const Icon(Icons.edit),
                  tooltip: 'Editar conteúdo',
                ),
                IconButton(
                  onPressed: () => _excluirConteudo(index),
                  icon: const Icon(Icons.delete),
                  tooltip: 'Excluir conteúdo',
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.only(top: 8),
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

  Widget _buildListaConteudos() {
    final conteudos = _conteudosPaginaAtual;

    return Column(
      children: [
        CustomAppCard(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Conteúdos da página ${_paginaAtualIndex + 1}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _abrirDialogoConteudo(),
                icon: const Icon(Icons.add),
                label: const Text('conteúdo'),
              ),
            ],
          ),
        ),
        Expanded(
          child: conteudos.isEmpty
              ? const Center(
                  child: Text('Esta página ainda não possui conteúdos.'),
                )
              : ReorderableListView(
                  buildDefaultDragHandles: false,
                  onReorder: _reordenarConteudos,
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    for (int i = 0; i < conteudos.length; i++)
                      _buildConteudoCard(conteudos[i], i),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    if (!_temPaginas) {
      return const SizedBox.shrink();
    }

    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _paginaAtualIndex == 0
                ? null
                : () => _irParaPagina(_paginaAtualIndex - 1),
            icon: const Icon(Icons.arrow_back),
          ),
          Text(
            'Página ${_paginaAtualIndex + 1} de ${_paginas.length}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          IconButton(
            onPressed: _paginaAtualIndex == _paginas.length - 1
                ? null
                : () => _irParaPagina(_paginaAtualIndex + 1),
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conteúdos da aula'),
        actions: [
          IconButton(
            onPressed: _adicionarPagina,
            icon: const Icon(Icons.note_add),
            tooltip: 'Adicionar página',
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_temPaginas
              ? const Center(
                  child: Text('Nenhuma página cadastrada.\nUse o botão no topo para adicionar.', textAlign: TextAlign.center),
                )
              : Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    children: [
                      _buildCabecalhoPaginas(),
                      Expanded(child: _buildListaConteudos()),
                    ],
                  ),
                ),
    );
  }
}

class _YoutubePreview extends StatefulWidget {
  final String videoId;

  const _YoutubePreview({
    required this.videoId,
  });

  @override
  State<_YoutubePreview> createState() => _YoutubePreviewState();
}

class _YoutubePreviewState extends State<_YoutubePreview> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      return;
    }
    _criarController();
  }

  @override
  void didUpdateWidget(covariant _YoutubePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (kIsWeb) {
      return;
    }

    if (oldWidget.videoId != widget.videoId) {
      _controller?.close();
      _criarController();
    }
  }

  void _criarController() {
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        playsInline: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _YoutubeThumbnailPreview(videoId: widget.videoId);
    }

    if (_controller == null) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: YoutubePlayer(
          controller: _controller!,
          aspectRatio: 16 / 9,
        ),
      ),
    );
  }
}

class _YoutubeThumbnailPreview extends StatelessWidget {
  final String videoId;

  const _YoutubeThumbnailPreview({
    required this.videoId,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const Text(
                    'Nao foi possivel carregar a miniatura do video.',
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
            Container(
              color: Colors.black.withOpacity(0.18),
            ),
            const Center(
              child: Icon(
                Icons.play_circle_fill_rounded,
                color: Colors.white,
                size: 64,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
