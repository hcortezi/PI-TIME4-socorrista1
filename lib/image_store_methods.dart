import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socorrista1/post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ImageStoreMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance; // Instância do Storage para armazenamento da foto do socorrista.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Instância do Firestore para interação com o Firestore.
  final FirebaseMessaging messaging = FirebaseMessaging.instance; // Instância do Messaging para envio e recebimento de mensagens.
  final FirebaseAuth auth = FirebaseAuth.instance; // Instância do Auth para autenticação do socorrista.


  Future<String> imageToStorage(Uint8List file) async {
    // Login anônimo do socorrista
    UserCredential userCredential = await auth.signInAnonymously();
    User? user = userCredential.user;
    String uid = user!.uid; // Obtém UID do socorrista

    // Referência de onde será armazenada a foto no Storage, baseada no UID do socorrista com extensão ('jpeg').
    Reference ref = _storage.ref().child('imagens').child('$uid.jpeg');

    // Upload da foto no Storage
    UploadTask uploadTask = ref.putData(file); // Inicia a tarefa de Upload da foto

    TaskSnapshot snapshot = await uploadTask; // Aguarda conclusão da tarefa e obtém snapshot do resultado

    // URL da foto
    String downloadUrl = await snapshot.ref.getDownloadURL(); // Obtém URL da foto com base na ref do Storage
    return downloadUrl;
  }

  Future<String> uploadPost(
      String dados, String nome, String telefone, Uint8List file) async {
    await auth.signOut();
    String res = 'Ocorreu um erro'; // Variável de resposta.
    try {
      UserCredential userCredential = await auth.signInAnonymously();
      User? user = userCredential.user;
      String uid = user!.uid;
      String? fcmtoken = await messaging.getToken();
      if (fcmtoken != null) {
        String token = fcmtoken;
        // Upload da foto para o Storage e seu URL
        String photoURL = await imageToStorage(file);

        // Criação do Post com informações do socorrista
        Post post = Post(
          dados: dados,
          nome: nome,
          telefone: telefone,
          postID: uid,
          dataPublicada: DateTime.now(),
          postURL: photoURL,
          token: token,
          status: false,
        );

        // Armazena o objeto Post na coleção 'emergencias' no Database
        _firestore.collection('emergencias').doc().set(
          post.toJson(),
        );

        res = 'sucesso'; // Se sucesso, atualiza res para 'sucesso'
      }
    } catch (err) {
      res = err.toString(); // Se erro, atualiza res com descrição do erro
    }
    return res; // Retorna resposta
  }
}
