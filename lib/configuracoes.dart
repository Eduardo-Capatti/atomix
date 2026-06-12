import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'avatar_assets.dart';
import 'session.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int? _avatarIdSelecionado;

  Future<DocumentSnapshot<Map<String, dynamic>>> _carregarUsuario() async {
    final idUsuario = await getIdUsuario();
    return _firestore.collection('usuarios').doc(idUsuario).get();
  }

  Future<void> _trocarSenha() async {
    final email = _auth.currentUser?.email;

    if (email == null || email.isEmpty) {
      _mostrarMensagem('Não foi possível localizar o e-mail do usuário.');
      return;
    }

    await _auth.sendPasswordResetEmail(email: email);
    _mostrarMensagem('Enviamos um link para redefinir a senha no seu e-mail.');
  }

  Future<void> _salvarAvatar(int avatarId) async {
    final idUsuario = await getIdUsuario();

    await _firestore.collection('usuarios').doc(idUsuario).update({
      'avatar_id': avatarId,
    });

    if (!mounted) return;

    setState(() {
      _avatarIdSelecionado = avatarId;
    });
  }

  Future<void> _excluirConta() async {
    final usuario = _auth.currentUser;
    final idUsuario = await getIdUsuario();

    if (usuario == null) {
      _mostrarMensagem('Usuário não encontrado.');
      return;
    }

    try {
      await _firestore.collection('usuarios').doc(idUsuario).delete();
      await usuario.delete();
      if (!mounted) return;

      finalizarSession(context);
    } on FirebaseAuthException catch (error) {
      if (error.code == 'requires-recent-login') {
        _mostrarMensagem('Entre novamente antes de excluir a conta.');
        return;
      }

      _mostrarMensagem('Não foi possível excluir a conta agora.');
    }
  }

  void _confirmarExclusao() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir conta'),
          content: const Text(
            'Essa ação remove seus dados de usuário e não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _excluirConta();
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuarioAuth = _auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0066CC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Atomix',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Configurações do Usuário',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: _carregarUsuario(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final dados = snapshot.data?.data() ?? {};
                  final nome = dados['nomeUsuario']?.toString().trim();
                  final email = usuarioAuth?.email ?? '';
                  final xp = (dados['xp'] as num?)?.toInt() ?? 0;
                  final avatarId =
                      _avatarIdSelecionado ??
                      normalizarAvatarId(dados['avatar_id']);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ClipOval(
                              child: Image.asset(
                                avatarAssets[avatarId],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nome?.isNotEmpty == true
                                        ? nome!
                                        : 'Usuário',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    email,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Imagem de perfil',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 78,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: avatarAssets.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final selecionado = avatarId == index;

                              return InkWell(
                                borderRadius: BorderRadius.circular(38),
                                onTap: () => _salvarAvatar(index),
                                child: Container(
                                  width: 74,
                                  height: 74,
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: selecionado
                                          ? const Color(0xFF0066CC)
                                          : const Color(0xFFE5E7EB),
                                      width: selecionado ? 3 : 1,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      avatarAssets[index],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: const Color(0xFF2F855A),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '$xp XP',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2F855A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Total de XP',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF4B5563),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Ações da Conta',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(
                                  Icons.settings_outlined,
                                  color: Color(0xFF111827),
                                ),
                                title: const Text(
                                  'Trocar Senha',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                onTap: _trocarSenha,
                              ),
                              Divider(height: 1, color: Colors.grey[300]),
                              ListTile(
                                leading: const Icon(
                                  Icons.delete_outline,
                                  color: Color(0xFFDC2626),
                                ),
                                title: const Text(
                                  'Excluir Conta',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                onTap: _confirmarExclusao,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF4444),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () => finalizarSession(context),
                            child: const Text(
                              'Sair',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
