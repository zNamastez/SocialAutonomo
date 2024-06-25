import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';

class TelaDeChat extends StatefulWidget {
  final String usuarioId;
  final String usuarioNome;

  TelaDeChat({required this.usuarioId, required this.usuarioNome});

  @override
  _TelaDeChatState createState() => _TelaDeChatState();
}

class _TelaDeChatState extends State<TelaDeChat> {
  final TextEditingController _controllerMensagem = TextEditingController();
  late String _chatId;

  @override
  void initState() {
    super.initState();
    _iniciarChat();
  }

  void _iniciarChat() async {
    final chatService = Provider.of<ChatService>(context, listen: false);
    _chatId = await chatService.criarChat(widget.usuarioId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.usuarioNome),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: chatService.getMensagens(_chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                List<DocumentSnapshot> docs = snapshot.data!.docs;
                List<Widget> mensagens = docs.map((doc) {
                  return ListTile(
                    title: Text(doc['conteudo']),
                    subtitle: Text(doc['usuario']),
                  );
                }).toList();

                return ListView(
                  children: mensagens,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controllerMensagem,
                    decoration: InputDecoration(
                      hintText: 'Digite uma mensagem...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    if (_controllerMensagem.text.isNotEmpty) {
                      await chatService.enviarMensagem(_chatId, _controllerMensagem.text);
                      _controllerMensagem.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
