import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:my_service_app/screens/login_screen.dart'; 
import 'screens/main_screen.dart';
import 'screens/create_post_screen.dart';
import 'screens/chat_screen.dart'; // Importando a tela de chat
import 'package:provider/provider.dart';
import 'services/chat_service.dart'; // Importando o serviço de chat

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        Provider<ChatService>(create: (_) => ChatService()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Autonomo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: TelaDeLogin(),
      routes: {
        '/main': (context) => MainScreen(),
        '/createPost': (context) => TelaDeCriacaoDePostagem(),
        '/chat': (context) => TelaDeChat(usuarioId: '', usuarioNome: ''), // Definindo rota para a tela de chat
      },
    );
  }
}
