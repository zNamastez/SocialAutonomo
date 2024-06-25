import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart'; // Certifique-se de que o caminho está correto

class TelaDeFeed extends StatelessWidget {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  void _toggleLike(DocumentSnapshot postagem) async {
    if (currentUser == null) return;

    final postRef = FirebaseFirestore.instance.collection('postagens').doc(postagem.id);
    final postLikes = postagem['likes'] ?? [];
    final currentUserId = currentUser!.uid;

    if (postLikes.contains(currentUserId)) {
      postRef.update({
        'likes': FieldValue.arrayRemove([currentUserId]),
      });
    } else {
      postRef.update({
        'likes': FieldValue.arrayUnion([currentUserId]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Social Autonomo',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.send, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('postagens')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar postagens.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Nenhuma postagem encontrada.'));
          }

          final postagens = snapshot.data!.docs;

          return ListView.builder(
            itemCount: postagens.length,
            itemBuilder: (context, index) {
              final postagem = postagens[index];
              final descricao = postagem['descricao'];
              final imagemUrl = postagem['imagemUrl'];
              final usuarioId = postagem['usuario'];
              final likes = List<String>.from(postagem['likes'] ?? []);
              final isLiked = currentUser != null && likes.contains(currentUser!.uid);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(usuarioId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (userSnapshot.hasError) {
                    return Center(child: Text('Erro ao carregar usuário.'));
                  }

                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return Center(child: Text('Usuário não encontrado.'));
                  }

                  final usuario = userSnapshot.data!['nome'];
                  final usuarioImagemUrl = userSnapshot.data!['imagemUrl'];

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: usuarioImagemUrl != null
                                ? NetworkImage(usuarioImagemUrl)
                                : AssetImage('assets/placeholder.png'),
                          ),
                          title: Text(
                            usuario,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: Icon(Icons.more_vert),
                        ),
                        if (imagemUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                              bottom: Radius.circular(16),
                            ),
                            child: Image.network(
                              imagemUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 400,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isLiked ? Icons.favorite : Icons.favorite_border,
                                      color: isLiked ? Colors.red : null,
                                    ),
                                    onPressed: () => _toggleLike(postagem),
                                  ),
                                  SizedBox(width: 16),
                                  IconButton(
                                    icon: Icon(Icons.comment),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TelaDeChat(
                                            usuarioId: usuarioId,
                                            usuarioNome: usuario,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(width: 16),
                                  Icon(Icons.send),
                                  Spacer(),
                                  Icon(Icons.bookmark_border),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                '${likes.length} curtidas',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text(
                                descricao,
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
