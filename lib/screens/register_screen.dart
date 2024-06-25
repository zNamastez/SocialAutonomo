import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class TelaDeCadastro extends StatefulWidget {
  @override
  _EstadoTelaDeCadastro createState() => _EstadoTelaDeCadastro();
}

class _EstadoTelaDeCadastro extends State<TelaDeCadastro> {
  final TextEditingController _controladorEmail = TextEditingController();
  final TextEditingController _controladorSenha = TextEditingController();
  final TextEditingController _controladorConfirmaSenha = TextEditingController();
  final TextEditingController _controladorNome = TextEditingController();

  final FirebaseAuth _autenticacao = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _mensagemErro = '';
  File? _imagemSelecionada;

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

  void _cadastrar() async {
    if (_controladorSenha.text != _controladorConfirmaSenha.text) {
      setState(() {
        _mensagemErro = 'As senhas não coincidem.';
      });
      return;
    }

    try {
      UserCredential credenciaisUsuario = await _autenticacao.createUserWithEmailAndPassword(
        email: _controladorEmail.text,
        password: _controladorSenha.text,
      );

      String? imagemUrl;
      if (_imagemSelecionada != null) {
        imagemUrl = await _uploadImagem(_imagemSelecionada!);
      }

      await _firestore.collection('usuarios').doc(credenciaisUsuario.user!.uid).set({
        'nome': _controladorNome.text,
        'email': _controladorEmail.text,
        'imagemUrl': imagemUrl,
      });

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'email-already-in-use':
            _mensagemErro = 'O email já está em uso.';
            break;
          case 'invalid-email':
            _mensagemErro = 'Email inválido.';
            break;
          case 'weak-password':
            _mensagemErro = 'A senha é muito fraca.';
            break;
          default:
            _mensagemErro = 'Falha no cadastro. Por favor, tente novamente.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.orangeAccent, Colors.white],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 50),
              Text(
                'Cadastro',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Crie sua conta',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 50),
              GestureDetector(
                onTap: _escolherImagem,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _imagemSelecionada != null ? FileImage(_imagemSelecionada!) : null,
                  child: _imagemSelecionada == null
                      ? Icon(Icons.camera_alt, size: 50, color: Colors.grey[800])
                      : null,
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10.0,
                      spreadRadius: 5.0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _controladorNome,
                      decoration: InputDecoration(
                        labelText: 'Nome',
                      ),
                    ),
                    TextField(
                      controller: _controladorEmail,
                      decoration: InputDecoration(
                        labelText: 'Email',
                      ),
                    ),
                    TextField(
                      controller: _controladorSenha,
                      decoration: InputDecoration(labelText: 'Senha'),
                      obscureText: true,
                    ),
                    TextField(
                      controller: _controladorConfirmaSenha,
                      decoration: InputDecoration(labelText: 'Confirme a senha'),
                      obscureText: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _cadastrar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                ),
                child: Text('Cadastrar'),
              ),
              if (_mensagemErro.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    _mensagemErro,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Já tem uma conta?',
                    style: TextStyle(color: Colors.black54),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Faça login aqui',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
