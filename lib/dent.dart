import 'dart:developer';
import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const dent());
}

class dent extends StatefulWidget {
  const dent({Key? key}) : super(key: key);

  @override
  State<dent> createState() => _dentState();
}

class _dentState extends State<dent>{

  Future<List<String>> abada(String id) async{
    FirebaseFirestore.instance.collection('emergencias').where(id).get();
}

  Future<List<String>> getFirestoreArray(String id) async {

    List<String> stringList = [];

    FirebaseFirestore.instance
        .collection('emergencias')
        .doc(id)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        var myArray = documentSnapshot.data()!['dentistas'];

        if (myArray is List) {
          for (var item in myArray) {
            stringList.add(item.toString());
          }
          // The stringList now contains the values from the array field
          print(stringList);
        }
      } else {
        print('Document does not exist!');
      }
    }).catchError((error) {
      print('Error retrieving document: $error');
    });
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "dent",
      home: Scaffold(
        backgroundColor: Colors.blueAccent,
        body:Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget> [
            Text(
            "Procurando dentistas disponíveis",
            textAlign: TextAlign.center,
            style:GoogleFonts.montserrat(
              fontSize: 30,
              color: Colors.white,
            )
        ),
        SizedBox(
          height: 400,
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('emergencias').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data!.docs[index];
                    return ListTile(
                      title: Text(
                        ds.get('dentistas'),
                      ),
                    );
                  },
                );
              }
              else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ),
        ],
      ),
      ),
    );
  }
}