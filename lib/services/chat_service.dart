import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getMensagens(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('mensagens')
        .orderBy('timestamp')
        .snapshots();
  }

  Future<void> enviarMensagem(String chatId, String conteudo) async {
    String userId = _auth.currentUser!.uid;

    await _firestore.collection('chats').doc(chatId).collection('mensagens').add({
      'conteudo': conteudo,
      'usuario': userId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<String> criarChat(String outroUsuarioId) async {
    String meuId = _auth.currentUser!.uid;
    QuerySnapshot querySnapshot = await _firestore
        .collection('chats')
        .where('usuarios', arrayContains: meuId)
        .get();

    // Verifica se o chat já existe
    for (var doc in querySnapshot.docs) {
      List usuarios = doc['usuarios'];
      if (usuarios.contains(outroUsuarioId)) {
        return doc.id; // Retorna o id do chat existente
      }
    }

    // Se o chat não existir, cria um novo
    DocumentReference docRef = await _firestore.collection('chats').add({
      'usuarios': [meuId, outroUsuarioId],
      'criadoEm': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  Stream<QuerySnapshot> getChats() {
    String meuId = _auth.currentUser!.uid;

    return _firestore
        .collection('chats')
        .where('usuarios', arrayContains: meuId)
        .snapshots();
  }
}
