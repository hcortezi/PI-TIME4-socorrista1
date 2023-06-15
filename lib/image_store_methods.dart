import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socorrista1/post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ImageStoreMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<String> imageToStorage(Uint8List file) async {

    UserCredential userCredential = await auth.signInAnonymously();
    User? user = userCredential.user;
    String uid = user!.uid;
    Reference ref =
    _storage.ref().child('imagens').child('$uid.jpeg');
    UploadTask uploadTask = ref.putData(
        file
    );
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> uploadPost(String dados, String nome, String telefone, Uint8List file) async{
    await auth.signOut();
    String res = 'Ocorreu um erro';
    try {
      UserCredential userCredential = await auth.signInAnonymously();
      User? user = userCredential.user;
      String uid = user!.uid;
      String? fcmtoken = await messaging.getToken();
      if (fcmtoken != null) {
        String token = fcmtoken;
        String photoURL =
        await imageToStorage(file);
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
        _firestore.collection('emergencias').doc().set(post.toJson(),);
        res = 'sucesso';
      }
    } catch (err){
      res = err.toString();
    }
    return res;
  }
}
