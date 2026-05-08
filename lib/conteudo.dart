import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';


class Conteudo extends StatefulWidget{
  @override
  State<Conteudo> createState() => ConteudoState();
}

class ConteudoState extends State<Conteudo>{

  late VideoPlayerController _videoController;
  late ChewieController _chewieController;

  int paginaAtual = 1;

  bool isExercise = false;


  Container? resultado;

  int? respostaSelecionada;



  var arrayTeste = [
    {
      "pagina": 1,
      "conteudos": [
        {
          "tipo": "texto",
          "conteudo": "A matéria é tudo aquilo que possui massa e ocupa lugar no espaço. Ela é formada por partículas extremamente pequenas chamadas átomos."
        },
        {
          "tipo": "imagem",
          "conteudo": "assets/images/estrutura-do-atomo.png"
        },
        {
          "tipo": "texto",
          "conteudo": "Os átomos são compostos por prótons, nêutrons e elétrons. Os prótons possuem carga positiva, os elétrons negativa e os nêutrons são neutros."
        }
      ]
    },
    {
      "pagina": 2,
      "conteudos": [
        {
          "tipo": "texto",
          "conteudo": "Os elementos químicos são definidos pelo número de prótons no núcleo do átomo, conhecido como número atômico."
        },
        {
          "tipo": "imagem",
          "conteudo": "assets/images/estrutura-do-atomo.png"
        },
        {
          "tipo": "exercicio",
          "tipo2": "texto",
          "conteudo": [
            "Número de elétrons",
            "Número de prótons",
            "Número de nêutrons",
            "Massa do átomo"
          ],
          "pergunta": "O que define o número atômico de um elemento?",
          "resposta": 2
        }
      ]
    },
    {
      "pagina": 3,
      "conteudos": [
        {
          "tipo": "texto",
          "conteudo": "As ligações químicas ocorrem quando átomos compartilham ou transferem elétrons para alcançar maior estabilidade."
        },
        {
          "tipo": "texto",
          "conteudo": "Existem três tipos principais de ligações: iônica, covalente e metálica."
        },
        {
          "tipo": "imagem",
          "conteudo": "assets/images/estrutura-do-atomo.png"
        }
      ]
    },
    {
      "pagina": 4,
      "conteudos": [
        {
          "tipo": "texto",
          "conteudo": "A ligação iônica ocorre entre metais e ametais, envolvendo a transferência de elétrons."
        },
        {
          "tipo": "texto",
          "conteudo": "Já a ligação covalente acontece entre ametais, com o compartilhamento de elétrons."
        },
        {
          "tipo": "exercicio",
          "tipo2": "imagem",
          "conteudo": [
            "assets/images/estrutura-do-atomo.png",
            "assets/images/estrutura-do-atomo.png",
            "assets/images/estrutura-do-atomo.png",
            "assets/images/estrutura-do-atomo.png"
          ],
          "pergunta": "O que caracteriza uma ligação covalente?",
          "resposta": 2
        }
      ]
    },
    {
      "pagina": 5,
      "conteudos": [
        {
          "tipo": "imagem",
          "conteudo": "assets/images/estrutura-do-atomo.png"
        },
        {
          "tipo": "texto",
          "conteudo": "A tabela periódica organiza os elementos químicos de acordo com suas propriedades e número atômico."
        },
        {
          "tipo": "texto",
          "conteudo": "Elementos de uma mesma família possuem características semelhantes, como número de elétrons na camada de valência."
        }
      ]
    },
    {
      "pagina": 6,
      "conteudos": [
        {
          "tipo": "texto",
          "conteudo": "A tabela periódica organiza os elementos químicos de acordo com suas propriedades e número atômico."
        },
        {
          "tipo": "video",
          "conteudo": "assets/videos/videoExample.mp4"
        }
      ]
    }
  ];

//   var arrayTeste = [
//   {
//     "pagina": 1,
//     "conteudos": [
//       {
//         "tipo": "texto",
//         "conteudo": "A água é o recurso natural mais importante para a sobrevivência no planeta."
//       }
//     ]
//   },
//   {
//     "pagina": 2,
//     "conteudos": [
//       {
//         "tipo": "imagem",
//         "conteudo": "assets/images/estrutura-do-atomo.png"
//       }
//     ]
//   },
//   {
//     "pagina": 3,
//     "conteudos": [
//       {
//         "tipo": "texto",
//         "conteudo": "Ela pode ser encontrada em três estados físicos principais."
//       }
//     ]
//   },
//   {
//     "pagina": 4,
//     "conteudos": [
//       {
//         "tipo": "texto",
//         "conteudo": "O estado sólido, presente nas geleiras e nos polos."
//       }
//     ]
//   },
//   {
//     "pagina": 5,
//     "conteudos": [
//       {
//         "tipo": "texto",
//         "conteudo": "O estado líquido, presente nos rios, oceanos e aquíferos."
//       }
//     ]
//   },
//   {
//     "pagina": 6,
//     "conteudos": [
//       {
//         "tipo": "texto",
//         "conteudo": "O estado gasoso, visível no vapor que forma as nuvens."
//       }
//     ]
//   },
//   {
//     "pagina": 7,
//     "conteudos": [
//       {
//         "tipo": "video",
//         "conteudo": "assets/videos/videoExample.mp4"
//       }
//     ]
//   },
//   {
//     "pagina": 8,
//     "conteudos": [
//       {
//         "tipo": "texto",
//         "conteudo": "O ciclo da água garante a renovação constante desse recurso."
//       }
//     ]
//   },
//   {
//     "pagina": 9,
//     "conteudos": [
//       {
//         "tipo": "imagem",
//         "conteudo": "assets/images/estrutura-do-atomo.png"
//       },
//       {
//         "tipo": "texto",
//         "conteudo": "A evaporação é o primeiro passo."
//       }
//     ]
//   },
//   {
//     "pagina": 10,
//     "conteudos": [
//       {
//         "tipo": "texto",
//         "conteudo": "Seguido pela condensação nas altas camadas atmosféricas."
//       }
//     ]
//   },
//   {
//     "pagina": 11,
//     "conteudos": [
//       {
//         "tipo": "texto",
//         "conteudo": "E finalizando com a precipitação (chuva)."
//       }
//     ]
//   },
//   {
//     "pagina": 12,
//     "conteudos": [
//       {
//         "tipo": "imagem",
//         "conteudo": "assets/images/estrutura-do-atomo.png"
//       },
//       {
//         "tipo": "texto",
//         "conteudo": "Existem diversos corpos d'água no mundo."
//       },
//       {
//         "tipo": "texto",
//         "conteudo": "Os oceanos cobrem a maior parte da Terra."
//       },
//       {
//         "tipo": "texto",
//         "conteudo": "Os rios transportam água doce para o mar."
//       },
//       {
//         "tipo": "video",
//         "conteudo": "assets/videos/videoExample.mp4"
//       },
//       {
//         "tipo": "imagem",
//         "conteudo": "assets/images/estrutura-do-atomo.png"
//       },
//       {
//         "tipo": "texto",
//         "conteudo": "Os lagos são formações de água retida no continente."
//       },
//       {
//         "tipo": "texto",
//         "conteudo": "A preservação dos lençóis freáticos é vital."
//       },
//       {
//         "tipo": "imagem",
//         "conteudo": "assets/images/estrutura-do-atomo.png"
//       },
//       {
//         "tipo": "exercicio",
//         "tipo2": "texto",
//         "conteudo": [
//           "Oxigênio",
//           "Oceanos",
//           "Rios",
//           "Nuvens"
//         ],
//         "pergunta": "Qual destes cobre a maior parte do nosso planeta?",
//         "resposta": 2
//       }
//     ]
//   },
//   {
//     "pagina": 13,
//     "conteudos": [
//       {
//         "tipo": "texto",
//         "conteudo": "Infelizmente, a poluição hídrica é um grande problema global."
//       }
//     ]
//   },
//   {
//     "pagina": 14,
//     "conteudos": [
//       {
//         "tipo": "texto",
//         "conteudo": "O descarte incorreto de lixo prejudica a vida marinha."
//       }
//     ]
//   },
//   {
//     "pagina": 15,
//     "conteudos": [
//       {
//         "tipo": "imagem",
//         "conteudo": "assets/images/estrutura-do-atomo.png"
//       }
//     ]
//   },
//   {
//     "pagina": 16,
//     "conteudos": [
//       {
//         "tipo": "texto",
//         "conteudo": "O tratamento de esgoto é necessário para reverter esse cenário."
//       }
//     ]
//   },
//   {
//     "pagina": 17,
//     "conteudos": [
//       {
//         "tipo": "texto",
//         "conteudo": "Além disso, a agricultura consome a maior parte da água doce disponível."
//       }
//     ]
//   },
//   {
//     "pagina": 18,
//     "conteudos": [
//       {
//         "tipo": "video",
//         "conteudo": "assets/videos/videoExample.mp4"
//       }
//     ]
//   },
//   {
//     "pagina": 19,
//     "conteudos": [
//       {
//         "tipo": "texto",
//         "conteudo": "Sistemas de irrigação modernos ajudam a evitar o desperdício."
//       }
//     ]
//   },
//   {
//     "pagina": 20,
//     "conteudos": [
//       {
//         "tipo": "texto",
//         "conteudo": "Em casa, pequenas atitudes fazem a diferença."
//       }
//     ]
//   },
//   {
//     "pagina": 21,
//     "conteudos": [
//       {
//         "tipo": "texto",
//         "conteudo": "Como fechar a torneira ao escovar os dentes."
//       }
//     ]
//   },
//   {
//     "pagina": 22,
//     "conteudos": [
//       {
//         "tipo": "imagem",
//         "conteudo": "assets/images/estrutura-do-atomo.png"
//       }
//     ]
//   },
//   {
//     "pagina": 23,
//     "conteudos": [
//       {
//         "tipo": "texto",
//         "conteudo": "E reduzir o tempo no banho."
//       }
//     ]
//   },
//   {
//     "pagina": 24,
//     "conteudos": [
//       {
//         "tipo": "texto",
//         "conteudo": "Garantindo assim água potável para as futuras gerações."
//       }
//     ]
//   },
//   {
//     "pagina": 25,
//     "conteudos": [
//       {
//         "tipo": "exercicio",
//         "tipo2": "texto",
//         "conteudo": [
//           "Aumentar o tempo de banho",
//           "Lavar a calçada com mangueira",
//           "Fechar a torneira ao escovar os dentes",
//           "Descartar óleo na pia"
//         ],
//         "pergunta": "Qual atitude ajuda a economizar água em casa?",
//         "resposta": 3
//       }
//     ]
//   }
// ];

  int get paginaTotal => arrayTeste.length;

  List<Widget> conteudo = [];

  late Row? setas = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: paginaAtual == 1 ? null : voltarPagina,
          disabledColor: Colors.grey,
          icon: Icon(Icons.arrow_back, size: 30)
        ), 
        IconButton(
          onPressed: paginaAtual == paginaTotal ? concluirAula : avancarPagina,
          disabledColor: Colors.grey,
          icon: Icon(Icons.arrow_forward, size: 30)
        )
      ],
    );

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  void initState(){
    formarConteudo();
  }

  void formarConteudo(){
    setState((){
      conteudo.clear();
      
      arrayTeste.forEach((page) {
        print(page['pagina']);
        if(page["pagina"] == paginaAtual){
          print("entrou no if");
          (page["conteudos"] as List).forEach((content){
            print(content);
            if (content["tipo"] == "imagem") {
              conteudo.add(
                Image.asset(
                  content["conteudo"] as String,
                  width: 600,
                ),
              );
            }

            if (content["tipo"] == "texto") {
              conteudo.add(
                Text(content["conteudo"] as String),
              );
            }

            if(content["tipo"] == "video"){
              _videoController = VideoPlayerController.networkUrl(Uri.parse(content["conteudo"]));
              _chewieController = _chewieController = ChewieController(
                videoPlayerController: _videoController,
                autoPlay: false,
                looping: false,
              );
              conteudo.add(FutureBuilder(
                future: _videoController.initialize(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return AspectRatio(
                      aspectRatio: _videoController.value.aspectRatio,
                      child: Chewie(controller: _chewieController),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ));
            }

            if (content["tipo"] == "exercicio"){
              isExercise = true;

              setas = null;

              var respostaCorreta = content["resposta"];

              List<String> listaConteudo = content["conteudo"] as List<String>;

              conteudo.add(Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(content["pergunta"], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
              ));

              conteudo.add(GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: listaConteudo.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, 
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: content["tipo2"] == "texto" ? 4.5 : 2.5, // ajusta altura/largura
                  ),
                  itemBuilder: (context, index) {
                    final item = listaConteudo[index];
                    final isSelected = respostaSelecionada == index;
                    return Card(
                      color:  isSelected ? respostaCorreta - 1 == index ? Colors.green[400] : Colors.red[400] : Colors.white,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: (){
                          setState(() {
                            respostaSelecionada = index;
                          });
                          responderExercicio(respostaCorreta - 1 == index);
                        },
                        child: content["tipo2"] == "texto" ? 
                          ListTile(
                            title: Text(item) 
                          )
                        :
                          Image.asset(
                            item,
                            width: 100,
                          )
                        
                        
                      ),
                    );
                  },
                )
              );
            }
          });
        }
      });
    });
  }

  void primeiroConteudo(){
    setState(()=>paginaAtual = 1);
  }

  void reiniciarAula(){
    setState((){
      paginaAtual = 1; 
      resultado = null; 
      isExercise = false; 
      setas = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: paginaAtual == 1 ? null : voltarPagina,
            disabledColor: Colors.grey,
            icon: Icon(Icons.arrow_back, size: 30)
          ), 
          IconButton(
            onPressed: paginaAtual == paginaTotal ? concluirAula : avancarPagina,
            disabledColor: Colors.grey,
            icon: Icon(Icons.arrow_forward, size: 30)
          )
        ],
      );
      formarConteudo();
    });
  }


  void voltarPagina(){
    setState(() { 
      paginaAtual--;
      isExercise = false;
      resultado = null;
      setas = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: paginaAtual == 1 ? null : voltarPagina,
            disabledColor: Colors.grey,
            icon: Icon(Icons.arrow_back, size: 30)
          ), 
          IconButton(
            onPressed: paginaAtual == paginaTotal ? concluirAula : avancarPagina,
            disabledColor: Colors.grey,
            icon: Icon(Icons.arrow_forward, size: 30)
          )
        ],
      );
      formarConteudo();
    });
  }

  void avancarPagina(){
    setState(() {        
      paginaAtual++;
      isExercise = false;
      resultado = null;
      setas = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: paginaAtual == 1 ? null : voltarPagina,
            disabledColor: Colors.grey,
            icon: Icon(Icons.arrow_back, size: 30)
          ), 
          IconButton(
            onPressed: paginaAtual == paginaTotal ? concluirAula : avancarPagina,
            disabledColor: Colors.grey,
            icon: Icon(Icons.arrow_forward, size: 30)
          )
        ],
      );
      formarConteudo();
    });
  }

  void responderExercicio(bool resposta){
    setState((){
      if(resposta){
        resultado = Container(
          color: Colors.green[400],
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Muito bem! Você acertou a questão!", style: TextStyle(
                color: Color.fromRGBO(255, 255, 255, 1),
              ),),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: paginaAtual == paginaTotal ? concluirAula : avancarPagina,
                icon: Icon(Icons.arrow_forward, color: Color.fromRGBO(255, 255, 255, 1)),
                label: Text("Próximo", style: TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 1),
                ),),
              ),
            ],
          ),
        );
      }else{
        resultado = Container(
            color: Colors.red[400],
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Não era bem isso...", style: TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 1),
                ),),
                Wrap(
                  spacing: 10,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: reiniciarAula,
                      icon: Icon(Icons.restart_alt_outlined, color: Color.fromRGBO(255, 255, 255, 1)),
                      label: Text("Reiniciar aula", style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: ()=>{setState(() => resultado = null)},
                      icon: Icon(Icons.refresh, color: Color.fromRGBO(255, 255, 255, 1)),
                      label: Text("Tentar novamente", style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),),
                    ),]
                )
                
              ],
            ),
          );
      }
    });
  }

  void concluirAula(){
    //Levar para tela de parabenização e colocar aula como status concluída
    print("concluiu");
  }



  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          bottomNavigationBar: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: 80,
            child: resultado
          ),
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          body: Center(
            child: SafeArea(
              
            child: AbsorbPointer(
              absorbing: resultado != null,
              child: SingleChildScrollView(
                child: Container(
                  width: 1000,
                  child:
                      Column(
                        spacing: 30,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [Text("$paginaAtual/$paginaTotal")],
                        ),                    
                        
                        SingleChildScrollView(
                          child: Column(
                            spacing: 20,
                            children: [...conteudo]
                          )
                        ),
                
                        if(setas != null) setas!,
                        
                      ],),  
                  
                ),
              ),
            ),
            
          )
          )
      )
    );
  }
}