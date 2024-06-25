import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TelaDeCriacaoDePostagem extends StatefulWidget {
  @override
  _TelaDeCriacaoDePostagemState createState() => _TelaDeCriacaoDePostagemState();
}

class _TelaDeCriacaoDePostagemState extends State<TelaDeCriacaoDePostagem> {
  final TextEditingController _controladorDescricao = TextEditingController();
  File? _imagemSelecionada;
  final ImagePicker _picker = ImagePicker();

  Future<void> _escolherImagem() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagemSelecionada = File(pickedFile.path);
      });
    }
  }

  Future<void> _criarPostagem() async {
    if (_imagemSelecionada != null && _controladorDescricao.text.isNotEmpty) {
      try {
        // Upload da imagem para o Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('post_images')
            .child('${DateTime.now().toIso8601String()}.jpg');
        final uploadTask = storageRef.putFile(_imagemSelecionada!);
        final snapshot = await uploadTask;
        final imagemUrl = await snapshot.ref.getDownloadURL();

        // Criação da postagem no Firestore
        final usuario = FirebaseAuth.instance.currentUser;
        final usuarioId = usuario?.uid ?? 'Anônimo';
        final usuarioNome = usuario?.displayName ?? 'Usuário';

        await FirebaseFirestore.instance.collection('postagens').add({
          'descricao': _controladorDescricao.text,
          'imagemUrl': imagemUrl,
          'likes': [],
          'timestamp': FieldValue.serverTimestamp(),
          'usuario': usuarioId,
        });

      } catch (e) {
        print('Erro ao criar postagem: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Criar Postagem'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _controladorDescricao,
                decoration: InputDecoration(labelText: 'Descrição'),
              ),
              SizedBox(height: 10),
              _imagemSelecionada == null
                  ? Text('Nenhuma imagem selecionada')
                  : Image.file(_imagemSelecionada!),
              ElevatedButton(
                onPressed: _escolherImagem,
                child: Text('Escolher Imagem'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _criarPostagem,
                child: Text('Postar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
