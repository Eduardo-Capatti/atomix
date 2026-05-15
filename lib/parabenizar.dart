import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';

List<String> imagem = [
  "assets/images/camaleaoPensativo.jpeg",
  "assets/images/camaleaoPensativoVermelho.jpeg",
];

class Parabenizar extends StatefulWidget {
  final int xp;
  final String tempo;

  const Parabenizar({
    super.key,
    required this.xp,
    required this.tempo
  });

  @override
  State<Parabenizar> createState() => ParabenizarState();
}

class ParabenizarState extends State<Parabenizar> {
  
  int randomInt = Random().nextInt(2);

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Container(
            child: Column(
              spacing: 20,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 400, child: Image.asset(imagem[randomInt])),
                Text(
                  "Você completou a lição!",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 24,
                    fontWeight: FontWeight(900),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      elevation: 5, // Sombra do card
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: Colors.blue,
                          width: 5,
                        ), // Cantos arredondados
                      ),
                      child: Container(
                        width: 130,
                        padding: EdgeInsets.all(20),
                        child: Row(
                          spacing: 10,
                          children: [
                            Icon(Icons.access_time, color: Colors.blue),
                            Text(widget.tempo, style: TextStyle(color: Colors.blue)),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      elevation: 5, // Sombra do card
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: Color.fromRGBO(251, 192, 45, 1),
                          width: 5,
                        ), // Cantos arredondados
                      ),
                      child: Container(
                        width: 130,
                        padding: EdgeInsets.all(20),
                        child: Row(
                          spacing: 10,
                          children: [
                            Icon(
                              Icons.bolt,
                              color: const Color.fromRGBO(251, 192, 45, 1),
                            ),
                            Text(
                              "+${widget.xp} XP",
                              style: TextStyle(color: Colors.yellow[700]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                FractionallySizedBox(
                  widthFactor: 0.6,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () => {},
                    icon: Icon(
                      Icons.check_circle,
                      color: Color.fromRGBO(255, 255, 255, 1),
                    ),
                    label: Text(
                      "CONCLUIR",
                      style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}