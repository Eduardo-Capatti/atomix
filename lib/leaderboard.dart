import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>{

  Future<List<Map<String, dynamic>>> rankingUsers() async{
      QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('usuarios')
      .limit(50)
      .get();

      return snapshot.docs.map((doc) => doc.data() as Map<String,dynamic>)
      .toList();
  }  

  @override
  Widget build(BuildContext context) {
    // Lista de Usuários
    final Future<List<Map<String, dynamic>>> usuarios = rankingUsers();

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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: usuarios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum usuário encontrado'));
          }

          final listaUsuarios = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listaUsuarios.length,
            itemBuilder: (context, index) {
              final usuario = listaUsuarios[index];
              final posicao = index + 1;

              Color corPosicao = Colors.blueGrey;
              if (posicao == 1) corPosicao = Colors.amber;
              if (posicao == 2) corPosicao = Colors.grey[400]!;
              if (posicao == 3) corPosicao = const Color(0xFFCD7F32);

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: corPosicao,
                    child: Text("$posicaoº"),
                  ),
                  title: Text(usuario['nomeUsuario'].toString()),
                  trailing: Text("${usuario['xp']} XP"),
                ),
              );
            },
          );
        },
      )
    );
  }
}