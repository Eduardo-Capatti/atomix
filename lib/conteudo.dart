import 'package:atomix/parabenizar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:audioplayers/audioplayers.dart';

import 'base64.dart';

class Conteudo extends StatefulWidget {
  final String idAula;
  final String tituloAula;
  final String idModulo;
  final String moduleTitle;
  final int totalXP;

  const Conteudo({
    super.key,
    required this.idAula,
    required this.tituloAula,
    required this.idModulo,
    required this.moduleTitle,
    required this.totalXP
  });

  @override
  State<Conteudo> createState() => ConteudoState();
}

class ConteudoState extends State<Conteudo> {
  final player = AudioPlayer();

  void tocarAudio(bool acerto) async {
    if(acerto){
      await player.play(AssetSource('sounds/acerto.wav'));
    }else{
      await player.play(AssetSource('sounds/erro.mp3'));
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  YoutubePlayerController? _youtubeController;
  final ScrollController _scrollController = ScrollController();
  final Stopwatch stopwatch = Stopwatch();

  int paginaAtual = 1;
  bool isExercise = false;
  bool _isLoading = true;
  Widget? resultado;
  int? respostaSelecionada;
  String tituloAula = '';
  late int totalXP = widget.totalXP;
  int totalPerdeXP = 4;
  int countRespostaErrada = 0;
  int maxRespostaErrada = 3;
  List<Map<String, dynamic>> paginas = [];
  List<Widget> conteudo = [];

  int get paginaTotal => paginas.length;

  @override
  void initState() {
    super.initState();
    tituloAula = widget.tituloAula;
    _carregarConteudos();
  }

  @override
  void didUpdateWidget(covariant Conteudo oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.idAula != widget.idAula) {
      tituloAula = widget.tituloAula;
      _carregarConteudos();
    }
  }

  @override
  void dispose() {
    _youtubeController?.close();
    _scrollController.dispose();
    stopwatch.stop();
    super.dispose();
  }

  Future<void> _carregarConteudos() async {
    setState(() {
      _isLoading = true;
    });

    QuerySnapshot<Map<String, dynamic>> snapshot;

    try {
      snapshot = await _firestore
          .collection('conteudo')
          .where('idAula', isEqualTo: widget.idAula)
          .orderBy('pagina')
          .get();
    } catch (_) {
      snapshot = await _firestore
          .collection('conteudo')
          .where('idAula', isEqualTo: widget.idAula)
          .get();
    }

    final paginasOrdenadas = snapshot.docs
        .map((doc) => Map<String, dynamic>.from(doc.data()))
        .toList()
      ..sort(
        (a, b) => ((a['pagina'] ?? 0) as num)
            .compareTo((b['pagina'] ?? 0) as num),
      );

    if (!mounted) return;

    if (paginasOrdenadas.isEmpty) {
      setState(() {
        paginas = [];
        conteudo = [];
        paginaAtual = 1;
        isExercise = false;
        resultado = null;
        respostaSelecionada = null;
        _isLoading = false;
      });
      stopwatch
        ..stop()
        ..reset();
      return;
    }

    final xp = totalXP;

    setState(() {
      paginas = paginasOrdenadas;
      paginaAtual = 1;
      totalXP = xp;
      totalPerdeXP = xp * 10 ~/ 100;
      countRespostaErrada = 0;
      isExercise = false;
      resultado = null;
      respostaSelecionada = null;
      formarConteudo();
      _isLoading = false;
    });

    stopwatch
      ..stop()
      ..reset()
      ..start();
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: paginaAtual == 1 ? null : voltarPagina,
          disabledColor: Colors.grey,
          icon: const Icon(Icons.arrow_back, size: 30),
        ),
        IconButton(
          onPressed: paginaAtual == paginaTotal ? concluirAula : avancarPagina,
          disabledColor: Colors.grey,
          icon: const Icon(Icons.arrow_forward, size: 30),
        ),
      ],
    );
  }

  void formarConteudo() {
    _youtubeController?.close();
    _youtubeController = null;
    conteudo.clear();
    isExercise = false;

    for (final page in paginas) {
      if (page['pagina'] != paginaAtual) continue;

      final pageContents = List<Map<String, dynamic>>.from(
        (page['conteudos'] as List? ?? []).map(
          (item) => Map<String, dynamic>.from(item as Map),
        ),
      )..sort(
          (a, b) => ((a['ordem'] ?? 0) as num)
              .compareTo((b['ordem'] ?? 0) as num),
        );

      for (final content in pageContents) {
        if (content['tipo'] == 'imagem') {
          conteudo.add(_buildImageBlock(content['conteudo'] as String));
        }

        if (content['tipo'] == 'texto') {
          conteudo.add(_buildTextBlock(content['conteudo'] as String));
        }

        if (content['tipo'] == 'video') {
          conteudo.add(_buildYoutubeBlock(content['conteudo'] as String));
        }

        if (content['tipo'] == 'exercicio') {
          isExercise = true;

          final respostaCorreta =
              (content['resposta'] as num?)?.toInt() ?? 1;
          final List<String> listaConteudo = List<String>.from(
            content['conteudo'] as List? ?? const <String>[],
          );

          conteudo.add(
            _buildExerciseTitle(content['pergunta']?.toString() ?? ''),
          );
          conteudo.add(
            GridView.builder(
              key: ValueKey(respostaSelecionada),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: listaConteudo.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio:
                    content['tipo2'] == 'texto' ? 3.5 : 1.0,
              ),
              itemBuilder: (context, index) {
                final item = listaConteudo[index];

                return _buildExerciseOption(
                  content: content,
                  item: item,
                  index: index,
                  respostaCorreta: respostaCorreta,
                );
              },
            ),
          );
        }
      }
    }
  }

  Widget _buildSectionCard({required Widget child, Color? borderColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor ?? const Color(0xFFE6EEF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTextBlock(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F8EE),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Color(0xFF2E7D5B),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              height: 1.55,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvalidImage() {
    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image),
    );
  }

  Widget _buildImageBlock(String valorImagem) {
    final bytes = converterBase64EmBytes(valorImagem);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.image_outlined, color: Color(0xFF2B6CB0)),
              SizedBox(width: 8),
              Text('Figura'),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: bytes != null
                ? Image.memory(
                    bytes,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildInvalidImage(),
                  )
                : Image.asset(
                    valorImagem,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildInvalidImage(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildYoutubeBlock(String videoUrl) {
    final videoId = YoutubePlayerController.convertUrlToId(videoUrl);

    if (videoId == null) {
      return _buildSectionCard(
        borderColor: const Color(0xFFF0D3D3),
        child: const Text('Nao foi possivel carregar este video do YouTube.'),
      );
    }

    _youtubeController?.close();
    _youtubeController = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: YoutubePlayerParams(
        showFullscreenButton: true,
        playsInline: true,
      ),
    );

    return _buildSectionCard(
      borderColor: const Color(0xFFF3D9B0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.smart_display_rounded, color: Color(0xFFD97706)),
              SizedBox(width: 8),
              Text(
                'Video complementar',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Assista ao video para reforcar o conteudo da aula.',
            style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: YoutubePlayer(
                controller: _youtubeController!,
                aspectRatio: 16 / 9,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseTitle(String pergunta) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.quiz_outlined, color: Color(0xFF6B46C1)),
              SizedBox(width: 8),
              Text(
                'Exercicio',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            pergunta,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.25,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseImageOption(String item) {
    final bytes = converterBase64EmBytes(item);

    if (bytes != null) {
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildInvalidImage(),
      );
    }

    return Image.asset(
      item,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) => _buildInvalidImage(),
    );
  }

  Widget _buildExerciseOption({
    required Map<String, dynamic> content,
    required String item,
    required int index,
    required int respostaCorreta,
  }) {
    final bool isSelected = respostaSelecionada == index;
    final bool isTextOption = content['tipo2'] == 'texto';

    return Card(
      key: ValueKey('$index-$respostaSelecionada'),
      color: Colors.transparent,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isSelected ? const Color(0xFF2F855A) : const Color(0xFFE5E7EB),
          width: 1.2,
        ),
      ),
      child: InkWell(
        onTap: () async {
          setState(() {
            respostaSelecionada = index;
          });

          await Future.delayed(const Duration(milliseconds: 200));

          responderExercicio(respostaCorreta - 1 == index);
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFFEAF7EF), Color(0xFFD9F0E2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(14),
          child: isTextOption
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: _buildExerciseImageOption(item),
                ),
        ),
      ),
    );
  }

  void primeiroConteudo() {
    setState(() => paginaAtual = 1);
  }

  void reiniciarAula() {
    setState(() {
      final xpInicial = totalXP;

      paginaAtual = 1;
      resultado = null;
      isExercise = false;
      respostaSelecionada = null;
      totalXP = xpInicial;
      totalPerdeXP = xpInicial * 10 ~/ 100;
      countRespostaErrada = 0;
      formarConteudo();
      _scrollController.jumpTo(0);
    });
  }

  void voltarPagina() {
    setState(() {
      paginaAtual--;
      isExercise = false;
      resultado = null;
      respostaSelecionada = null;
      formarConteudo();
      _scrollController.jumpTo(0);
    });
  }

  void avancarPagina() {
    setState(() {
      paginaAtual++;
      isExercise = false;
      resultado = null;
      respostaSelecionada = null;
      formarConteudo();
      _scrollController.jumpTo(0);
    });
  }

  void responderExercicio(bool resposta) {
    tocarAudio(resposta);
    setState(() {
      if (resposta) {
        resultado = Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2F855A),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Muito bem! Voce acertou a questao!',
                  style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    width: constraints.maxWidth,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F855A),
                        foregroundColor: Colors.white,
                      ),
                      onPressed:
                          paginaAtual == paginaTotal ? concluirAula : avancarPagina,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Proximo'),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      } else {
        resultado = Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFC53030),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Nao era bem isso...',
                  style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      SizedBox(
                        width: constraints.maxWidth,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC53030),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: reiniciarAula,
                          icon: const Icon(Icons.restart_alt_outlined),
                          label: const Text('Reiniciar aula'),
                        ),
                      ),
                      SizedBox(
                        width: constraints.maxWidth,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC53030),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => setState(() => resultado = null),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar novamente'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );

        if (countRespostaErrada < maxRespostaErrada) {
          totalXP -= totalPerdeXP;
          countRespostaErrada++;
        }
      }
    });
  }

  void concluirAula() {
    stopwatch.stop();

    final minutos =
        (stopwatch.elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final segundos =
        (stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Parabenizar(
          xp: totalXP,
          tempo: '$minutos:$segundos',
          idAula: widget.idAula,
          idModulo: widget.idModulo,
          moduleTitle: widget.moduleTitle
        ),
      ),
    );
  }

  void sairAula() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: Colors.blue,
          title: Row(
            children: [
              InkWell(
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: sairAula,
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  tituloAula,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(width: 10),

              Text(
                paginas.isEmpty ? '0/0' : '$paginaAtual/$paginaTotal',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: resultado != null
            ? AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 180,
                color: Colors.transparent,
                child: resultado,
              )
            : !_isLoading && paginas.isNotEmpty && !isExercise
                ? Container(
                    color: Colors.blue,
                    child: _buildNavigationButtons(),
                  )
                : null,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFF7FBFA),
                Color(0xFFF1F7FF),
                Color(0xFFFFFBF2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: SafeArea(
              child: AbsorbPointer(
                absorbing: resultado != null,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : paginas.isEmpty
                        ? const Center(
                            child: Text(
                              'Nenhum conteudo cadastrado para esta aula.',
                            ),
                          )
                        : SingleChildScrollView(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 18),
                                Column(children: [...conteudo]),
                              ],
                            ),
                          ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
