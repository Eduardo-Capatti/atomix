import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'aula.dart';
import 'session.dart';

List<String> imagensParabenizar = [
  'assets/images/cientista.png',
  'assets/images/explosaoFundo.png',
  'assets/images/first.png',
  'assets/images/parabens.png',
];

class Parabenizar extends StatefulWidget {
  final int xp;
  final String tempo;
  final String idAula;
  final String idModulo;
  final String moduleTitle;

  const Parabenizar({
    super.key,
    required this.xp,
    required this.tempo,
    required this.idAula,
    required this.idModulo,
    required this.moduleTitle,
  });

  @override
  State<Parabenizar> createState() => ParabenizarState();
}

class ParabenizarState extends State<Parabenizar>
    with SingleTickerProviderStateMixin {
  final player = AudioPlayer();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final int randomInt = Random().nextInt(imagensParabenizar.length);

  late final AnimationController _infoAnimationController;
  late final Animation<double> _tempoAnimation;
  late final Animation<double> _xpAnimation;
  late final Animation<double> _botaoAnimation;

  void tocarAudio() async {
    await player.play(AssetSource('sounds/aulaCompleta.wav'));
  }

  void concluir() async {
    await _firestore
        .collection('usuarios')
        .doc(await getIdUsuario())
        .update({
          'xp': FieldValue.increment(widget.xp),
        });

    final novoDoc = _firestore.collection('usuarioAula').doc();

    await novoDoc.set({
      'id': novoDoc.id,
      'idAula': widget.idAula,
      'idModulo': widget.idModulo,
      'idUsuario': await getIdUsuario(),
      'xp': widget.xp,
    });

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => LessonsScreen(
          idModulo: widget.idModulo,
          moduleTitle: widget.moduleTitle,
        ),
      ),
      (route) => route.isFirst,
    );
  }

  @override
  void initState() {
    super.initState();
    tocarAudio();

    _infoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _tempoAnimation = CurvedAnimation(
      parent: _infoAnimationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
    );
    _xpAnimation = CurvedAnimation(
      parent: _infoAnimationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
    );
    _botaoAnimation = CurvedAnimation(
      parent: _infoAnimationController,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOutBack),
    );
    _infoAnimationController.forward(from: 0);
  }

  @override
  void dispose() {
    _infoAnimationController.dispose();
    player.dispose();
    super.dispose();
  }

  Widget _buildAnimatedInfoCard({
    required Animation<double> animation,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, animatedChild) {
        final value = animation.value;

        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 18),
            child: Transform.scale(
              scale: 0.92 + (value * 0.08),
              child: animatedChild,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Colors.blue[50]),
      home: Scaffold(
        body: Center(
          child: Column(
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 400,
                child: Image.asset(imagensParabenizar[randomInt]),
              ),
              const Text(
                'Você completou a lição!',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAnimatedInfoCard(
                    animation: _tempoAnimation,
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(
                          color: Colors.blue,
                          width: 5,
                        ),
                      ),
                      child: Container(
                        width: 130,
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          spacing: 10,
                          children: [
                            const Icon(Icons.access_time, color: Colors.blue),
                            Text(
                              widget.tempo,
                              style: const TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildAnimatedInfoCard(
                    animation: _xpAnimation,
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(
                          color: Color.fromRGBO(251, 192, 45, 1),
                          width: 5,
                        ),
                      ),
                      child: Container(
                        width: 130,
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          spacing: 10,
                          children: [
                            const Icon(
                              Icons.bolt,
                              color: Color.fromRGBO(251, 192, 45, 1),
                            ),
                            Text(
                              '+${widget.xp} XP',
                              style: TextStyle(color: Colors.yellow[700]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              _buildAnimatedInfoCard(
                animation: _botaoAnimation,
                child: FractionallySizedBox(
                  widthFactor: 0.6,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: concluir,
                    icon: const Icon(
                      Icons.check_circle,
                      color: Color.fromRGBO(255, 255, 255, 1),
                    ),
                    label: const Text(
                      'CONCLUIR',
                      style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
