import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Dent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore ListView Example',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Firestore ListView Example'),
        ),
        body: DentWidget(),
      ),
    );
  }
}

class DentWidget extends StatefulWidget {
  @override
  _DentWidgetState createState() => _DentWidgetState();
}

class _DentWidgetState extends State<DentWidget> {
  Stream<List<String>>? fetchDataStream;

  @override
  void initState() {
    super.initState();
    fetchDataStream = fetchDentistasFromFirebase();
  }

  Stream<List<String>> fetchDentistasFromFirebase() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user == null) {
      return Stream.error('User not signed in');
    }

    String uid = user.uid;

    return FirebaseFirestore.instance
        .collection('emergencias')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('dentistas')) {
        List<dynamic> dentistasArray = data['dentistas'];
        return dentistasArray.map((item) => item.toString()).toList();
      }
      return [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: fetchDataStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (snapshot.hasData) {
          List<String> nomes = snapshot.data!;
          if (nomes.isEmpty) {
            return Center(
              child: Text('No Data'),
            );
          } else {
            return ListView.builder(
              itemCount: nomes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text("Dentista: ${nomes[index]}"),
                );
              },
            );
          }
        } else {
          return Center(
            child: Text('No Data'),
          );
        }
      },
    );
  }
}

void main() {
  runApp(Dent());
}