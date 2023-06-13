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
  late Future<List<String>> fetchDataFuture;

  Future<List<String>> fetchDentistasFromFirebase() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    UserCredential userCredential = await auth.signInAnonymously();
    User? user = userCredential.user;
    String uid = user!.uid;
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('emergencias')
        .doc(uid)
        .get();
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
    List<String> dentistas = [];
    if (data != null && data.containsKey('dentistas')) {
      List<dynamic> dentistasArray = data['dentistas'];
      dentistas.addAll(dentistasArray.map((item) => item.toString()));
    }
    return dentistas;
  }

  Future<List<String>> fetchNamesFromFirebase(List<String> dentistas) async {
    if (dentistas.isEmpty) {
      return [];
    }

    List<String> names = [];

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', whereIn: dentistas)
          .get();

      for (var doc in snapshot.docs) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('nome')) {
          String name = data['nome'];
          names.add(name);
        }
      }
    } catch (error) {
      print('Error fetching names: $error');
    }

    return names;
  }

  @override
  void initState() {
    super.initState();
    fetchDataFuture = fetchDentistasFromFirebase()
        .then((dentistas) => fetchNamesFromFirebase(dentistas))
        .catchError((error) {
      print('Error fetching data: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: fetchDataFuture,
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
          return ListView.builder(
            itemCount: nomes.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text("Dentista: ${nomes[index]}"),
              );
            },
          );
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
  WidgetsFlutterBinding.ensureInitialized();
  runApp(Dent());
}
