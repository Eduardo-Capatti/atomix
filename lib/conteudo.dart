import 'package:atomix/parabenizar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class Conteudo extends StatefulWidget {
  @override
  State<Conteudo> createState() => ConteudoState();
}

class ConteudoState extends State<Conteudo>{

  // Controller do vídeo do YouTube da página atual.
  YoutubePlayerController? _youtubeController;

  final ScrollController _scrollController = ScrollController();

  int paginaAtual = 1;

  bool isExercise = false;

  Widget? resultado;

  int? respostaSelecionada;

  String tituloAula = "Título da aula";

  var arrayTeste = [
    {
      "pagina": 1,
      "totalXP": 40,
      "conteudos": [
        {
          "tipo": "texto",
          "conteudo": "A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos. A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. \n\n\n Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos.A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos."
        },
        {
          "tipo": "imagem",
          "conteudo": "assets/images/estrutura-do-atomo.png"
        },
        {"tipo": "imagem", "conteudo": "assets/images/estrutura-do-atomo.png"},
        {
          "tipo": "texto",
          "conteudo":
              "Os átomos são compostos por prótons, nêutrons e elétrons. Os prótons possuem carga positiva, os elétrons negativa e os nêutrons são neutros.",
        },
      ],
    },
    {
      "pagina": 2,
      "conteudos": [
        {
          "tipo": "texto",
          "conteudo":
              "Os elementos químicos são definidos pelo número de prótons no núcleo do átomo, conhecido como número atômico.",
        },
        {"tipo": "imagem", "conteudo": "assets/images/estrutura-do-atomo.png"},
        {
          "tipo": "exercicio",
          "tipo2": "texto",
          "conteudo": [
            "Número de elétrons",
            "Número de prótons",
            "Número de nêutrons",
            "Massa do átomo",
          ],
          "pergunta": "O que define o número atômico de um elemento?",
          "resposta": 2,
        },
      ],
    },
    {
      "pagina": 3,
      "conteudos": [
        {
          "tipo": "texto",
          "conteudo":
              "As ligações químicas ocorrem quando átomos compartilham ou transferem elétrons para alcançar maior estabilidade.",
        },
        {
          "tipo": "texto",
          "conteudo":
              "Existem três tipos principais de ligações: iônica, covalente e metálica.",
        },
        {"tipo": "imagem", "conteudo": "assets/images/estrutura-do-atomo.png"},
      ],
    },
    {
      "pagina": 4,
      "conteudos": [
        {
          "tipo": "texto",
          "conteudo":
              "A ligação iônica ocorre entre metais e ametais, envolvendo a transferência de elétrons.",
        },
        {
          "tipo": "texto",
          "conteudo":
              "Já a ligação covalente acontece entre ametais, com o compartilhamento de elétrons.",
        },
        {
          "tipo": "exercicio",
          "tipo2": "imagem",
          "conteudo": [
            "assets/images/estrutura-do-atomo.png",
            "assets/images/estrutura-do-atomo.png",
            "assets/images/estrutura-do-atomo.png",
            "assets/images/estrutura-do-atomo.png",
          ],
          "pergunta": "O que caracteriza uma ligação covalente?",
          "resposta": 1
        }
      ]
    },
    {
      "pagina": 5,
      "conteudos": [
        {"tipo": "imagem", "conteudo": "assets/images/estrutura-do-atomo.png"},
        {
          "tipo": "texto",
          "conteudo":
              "A tabela periódica organiza os elementos químicos de acordo com suas propriedades e número atômico.",
        },
        {
          "tipo": "texto",
          "conteudo":
              "Elementos de uma mesma família possuem características semelhantes, como número de elétrons na camada de valência.",
        },
      ],
    },
    {
      "pagina": 6,
      "conteudos": [
        {
          "tipo": "texto",
          "conteudo":
              "A tabela periódica organiza os elementos químicos de acordo com suas propriedades e número atômico.",
        },
        {
          "tipo": "video",
          "conteudo": "https://www.youtube.com/watch?v=A6GOf1RqiwQ"
        }
      ]
    }
  ];

  late int totalXP = arrayTeste[0]["totalXP"] as int;

  late int totalPerdeXP = totalXP * 10 ~/ 100;

  int countRespostaErrada = 0;

  int maxRespostaErrada = 3;
  
  int get paginaTotal => arrayTeste.length;

  List<Widget> conteudo = [];

  final Stopwatch stopwatch = Stopwatch();
  
  @override
  void initState() {
    super.initState();
    formarConteudo();
    stopwatch.start();
  }

  @override
  void dispose() {
    _youtubeController?.close();
    _scrollController.dispose();
    super.dispose();
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
        )
      ],
    );
  }

  void formarConteudo(){
    // Recarrega só o conteúdo da página selecionada.
    _youtubeController?.close();
    _youtubeController = null;
    conteudo.clear();

    for (final page in arrayTeste) {
      if (page["pagina"] != paginaAtual) continue;

      final pageContents = page["conteudos"] as List;
      for (final content in pageContents) {
        if (content["tipo"] == "imagem") {
          conteudo.add(_buildImageBlock(content["conteudo"] as String));
        }

        if (content["tipo"] == "texto") {
          conteudo.add(_buildTextBlock(content["conteudo"] as String));
        }

        if (content["tipo"] == "video") {
          conteudo.add(_buildYoutubeBlock(content["conteudo"] as String));
        }

        if (content["tipo"] == "exercicio") {
          isExercise = true;

          final respostaCorreta = content["resposta"] as int;
          final List<String> listaConteudo = content["conteudo"] as List<String>;

          conteudo.add(
            _buildExerciseTitle(content["pergunta"] as String),
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
                childAspectRatio: content["tipo2"] == "texto" ? 3.5 : 1.0,
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
    // Base visual para texto, imagem, vídeo e exercício.
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
      margin: EdgeInsets.symmetric(vertical: 20), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE7F8EE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.menu_book_rounded, color: Color(0xFF2E7D5B)),
            ),
            ]),
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
      ));
  }

  Widget _buildImageBlock(String assetPath) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.image_outlined, color: Color(0xFF2B6CB0)),
              SizedBox(width: 8), 
              Text("Figura")
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              assetPath,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYoutubeBlock(String videoUrl) {
    // Transforma a URL em ID e monta o player do YouTube.
    final videoId = YoutubePlayerController.convertUrlToId(videoUrl);

    if (videoId == null) {
      return _buildSectionCard(
        borderColor: const Color(0xFFF0D3D3),
        child: const Text('Não foi possível carregar este vídeo do YouTube.'),
      );
    }

    _youtubeController?.close();
    _youtubeController = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
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
                'Vídeo complementar',
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
            'Assista ao vídeo para reforçar o conteúdo da aula.',
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
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.quiz_outlined, color: Color(0xFF6B46C1)),
              SizedBox(width: 8),
              Text(
                'Exercício',
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

  Widget _buildExerciseOption({
    required Map<String, dynamic> content,
    required String item,
    required int index,
    required int respostaCorreta,
  }) {
    // Desenha uma alternativa do exercício.
    final bool isSelected = respostaSelecionada == index;
    final bool isTextOption = content["tipo2"] == "texto";

    return Card(
      key: ValueKey("$index-$respostaSelecionada"),
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
                  child: Image.asset(
                    item,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
        ),
      ),
    );
  }

  void primeiroConteudo() {
    setState(() => paginaAtual = 1);
  }

  void reiniciarAula(){
    setState((){ 
      paginaAtual = 1; 
      resultado = null; 
      isExercise = false; 
      respostaSelecionada = null;
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

  void responderExercicio(bool resposta){
    setState((){ 
      if(resposta){
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
                  "Muito bem! Você acertou a questão!",
                  style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              LayoutBuilder(
                builder: (context, constraints){
                  return SizedBox(
                      width: constraints.maxWidth,
                      child:ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F855A),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: paginaAtual == paginaTotal ? concluirAula : avancarPagina,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text("Próximo"),
                    )
                  );
                }
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
                    "Não era bem isso...",
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
                          label: const Text("Reiniciar aula"),
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
                          label: const Text("Tentar novamente"),
                        ),
                      )
                    ],
                  );
                },
              )  
              ],
            ),
          );

          if(countRespostaErrada < maxRespostaErrada){
            totalXP -= totalPerdeXP;
            countRespostaErrada++;
          }
      }
    });
  }

  void concluirAula() {
    //Levar para tela de parabenização e colocar aula como status concluída
    stopwatch.stop();

    final minutos = (stopwatch.elapsed.inMinutes % 60)
    .toString()
    .padLeft(2, '0');

    final segundos = (stopwatch.elapsed.inSeconds % 60)
        .toString()
        .padLeft(2, '0');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Parabenizar(
          xp: totalXP,
          tempo: "$minutos:$segundos",
        ),
      ),
    );
  }

  void sairAula(){
    Navigator.pushNamed(context, "/modulos");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
            toolbarHeight: 80,
            backgroundColor: Colors.blue, 
            title: Container(
              child: Row(
                spacing: 10, 
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:[
                  Wrap(
                    spacing: 10,
                    children:[
                      InkWell(
                        hoverColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap:  sairAula,
                        child: Icon(Icons.close, color: Colors.red[900])
                      ),
                      Text(tituloAula, style: TextStyle(color: Colors.white)),
                    ]
                  ),
                  Container(  
                    child: Text(
                      '$paginaAtual/$paginaTotal',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ]
              )
            ),
        ),
        bottomNavigationBar: 
          resultado != null ? 
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: resultado == null ? 0 : 180,
              color: Colors.transparent,
              child: resultado,
          ) : !isExercise ? Container(color: Colors.blue, child:_buildNavigationButtons()) : null,
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
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 18),
                        Column(
                          children: [...conteudo],
                        ),
                      ],
                    ),
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
