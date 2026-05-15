import 'package:flutter/material.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  @override
  Widget build(BuildContext context) {
    // Lista de Usuários
    final List<Map<String, dynamic>> usuarios = [
      {'nome': 'Carlos', 'xp': 2000},
      {'nome': 'José', 'xp': 1800},
      {'nome': 'Lucas', 'xp': 1000},
      {'nome': 'Ana', 'xp': 850},
      {'nome': 'Pedro', 'xp': 500},
      {'nome': 'José', 'xp': 10},
      {'nome': 'Lucas', 'xp': 10},
      {'nome': 'Ana', 'xp': 5},
      {'nome': 'Pedro', 'xp': 5},
    ];

    return Scaffold(
      backgroundColor: Colors.blue[50], 
      
      appBar: AppBar(
        title: const Text(
          'Ranking',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent, // Deixando invisível como no cadastro
        elevation: 0,
        foregroundColor: Colors.blue[900],
        centerTitle: true,
      ),

      // 2. ListView.builder constrói a lista baseada na quantidade de itens
      body: ListView.builder(
        padding: const EdgeInsets.all(16), // Espaço nas bordas da tela
        itemCount: usuarios.length, // Quantidade de pessoas na lista
        itemBuilder: (context, index) {
          
          // Pegando os dados do usuário atual na volta do loop
          final usuario = usuarios[index];
          final posicao = index + 1; // O index começa em 0, então somamos 1 para a posição
          
          // Lógica de cores para os 3 primeiros colocados
          Color corPosicao = Colors.blueGrey; // Cor padrão
          if (posicao == 1) corPosicao = Colors.amber; // Ouro
          if (posicao == 2) corPosicao = Colors.grey[400]!; // Prata
          if (posicao == 3) corPosicao = const Color(0xFFCD7F32); // Bronze

          // 3. Card e ListTile montam o visual de cada linha
          return Card(
            elevation: posicao <= 3 ? 4 : 1, // Sombra maior para os top 3
            margin: const EdgeInsets.only(bottom: 12), // Espaço entre os cards
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15), // Deixa as bordas arredondadas
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              
              // Lado Esquerdo: A bolinha com a posição
              leading: CircleAvatar(
                backgroundColor: corPosicao,
                child: Text(
                  "$posicaoº",
                  style: const TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              // Meio: O nome do usuário
              title: Text(
                usuario['nome'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: posicao <= 3 ? FontWeight.bold : FontWeight.normal,
                  color: Colors.blue[900],
                ),
              ),
              
              // Lado Direito: A pontuação
              trailing: Text(
                "${usuario['xp']} XP",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}