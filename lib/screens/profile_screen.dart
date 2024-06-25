import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class TelaDePerfil extends StatefulWidget {
  @override
  _TelaDePerfilState createState() => _TelaDePerfilState();
}

class _TelaDePerfilState extends State<TelaDePerfil> {
  final TextEditingController _nomeController = TextEditingController();
  File? _imagemSelecionada;
  String? _imagemUrl;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  Future<void> _carregarDadosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final usuarioDoc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
    if (usuarioDoc.exists) {
      setState(() {
        _nomeController.text = usuarioDoc['nome'];
        _imagemUrl = usuarioDoc['imagemUrl'];
      });
    }
  }

  Future<void> _escolherImagem() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagemSelecionada = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImagem(File imagem) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('perfil_images')
          .child('${DateTime.now().toIso8601String()}.jpg');
      await storageRef.putFile(imagem);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Erro ao fazer upload da imagem: $e');
      return null;
    }
  }

  Future<void> _atualizarPerfil() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String? imagemUrl = _imagemUrl;
    if (_imagemSelecionada != null) {
      imagemUrl = await _uploadImagem(_imagemSelecionada!);
    }

    await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).update({
      'nome': _nomeController.text,
      'imagemUrl': imagemUrl,
    });

    setState(() {
      _imagemUrl = imagemUrl;
      _imagemSelecionada = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _escolherImagem,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _imagemSelecionada != null
                      ? FileImage(_imagemSelecionada!)
                      : _imagemUrl != null
                          ? NetworkImage(_imagemUrl!)
                          : null,
                  child: _imagemSelecionada == null && _imagemUrl == null
                      ? Icon(Icons.camera_alt, size: 50, color: Colors.grey[800])
                      : null,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _atualizarPerfil,
                child: Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
