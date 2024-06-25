import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'feed_screen.dart';
import 'register_screen.dart';

class TelaDeLogin extends StatefulWidget {
  @override
  _EstadoTelaDeLogin createState() => _EstadoTelaDeLogin();
}

class _EstadoTelaDeLogin extends State<TelaDeLogin> {
  final TextEditingController _controladorEmail = TextEditingController();
  final TextEditingController _controladorSenha = TextEditingController();
  final FirebaseAuth _autenticacao = FirebaseAuth.instance;
  String _mensagemErro = '';

  void _logar() async {
    try {
      UserCredential credenciaisUsuario = await _autenticacao.signInWithEmailAndPassword(
        email: _controladorEmail.text,
        password: _controladorSenha.text,
      );
      Navigator.pushReplacementNamed(context, '/main');
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'invalid-email':
            _mensagemErro = 'Email inválido.';
            break;
          case 'user-not-found':
            _mensagemErro = 'Usuário não encontrado.';
            break;
          case 'wrong-password':
            _mensagemErro = 'Senha incorreta.';
            break;
          default:
            _mensagemErro = 'Falha no login. Por favor, tente novamente.';
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
                'Login',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 50),
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
                  ],
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  // Lógica de "Esqueceu a senha"
                },
                child: Text('Esqueceu a senha?'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _logar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                ),
                child: Text('Login'),
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
                children: <Widget>[
                  const Text('Não tem uma conta?'),
                  TextButton(
                    child: const Text(
                      ' Cadastre-se aqui',
                      style: TextStyle(fontSize: 18, color: Colors.orangeAccent),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TelaDeCadastro()),
                      );
                    },
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
