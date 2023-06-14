

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socorrista1/LocationData.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'firebaseMessagingService.dart';


class Dent extends StatelessWidget {
  const Dent({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore ListView Example',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Firestore ListView Example'),
        ),
        body: const DentWidget(),
      ),
    );
  }
}

class DentWidget extends StatefulWidget {
  const DentWidget({super.key});

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

  Future<String> getNomeFromUID(String uid) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: uid)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.get('nome');
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: fetchDentistasFromFirebase(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<String> dentistasList = snapshot.data!;
          return ListView.builder(
            itemCount: dentistasList.length,
            itemBuilder: (context, index) {
              String uid = dentistasList[index];
              return FutureBuilder<String>(
                future: getNomeFromUID(uid),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    String nome = snapshot.data!;
                    return ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.teal), onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DentistDetailsScreen(uid: uid),
                        ),
                      );
                    }, child:Text("Dentista: $nome"));
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              );
            },
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}

class DentistDetailsScreen extends StatelessWidget {
  final String uid;

  const DentistDetailsScreen({Key? key, required this.uid});

  Future<String> getNomeFromUID(String uid) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: uid)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.get('nome');
    } else {
      return '';
    }
  }

  void definirEmergencia(String uidD) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    String? uidE = user?.uid.toString();
    FirebaseFirestore.instance
        .collection('emergencias')
        .doc(uidE)
        .update({'status': true})
        .then((value) {
      FirebaseFirestore.instance
          .collection('emergencias')
          .doc(uidE)
          .update({'dentistas': uidD}).then((value) {
        print('Emergencia atualizada com sucesso');
      }).catchError((error) {
        print('Erro ao definir dentista');
      });
    }).catchError((error) {
      print('Erro no update de status: $error');
    });
  }

  Future<String> getCurriculoFromUID(String uid) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: uid)
        .get();

    String id = snapshot.docs.first.id.toString();
    DocumentSnapshot doc =
    await FirebaseFirestore.instance.collection("users").doc(id).get();
    return doc.get("curriculo").toString();
  }

  Future<String> retrievePhotoUrl(String uid) async {
    final FirebaseStorage storage = FirebaseStorage.instance;

    try {
      Reference ref = storage.ref('dentistas').child('$uid.jpeg');
      String url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error retrieving photo URL: $e');
      throw Exception('Error retrieving photo URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Dentista'),
      ),
      body: FutureBuilder<String>(
        future: getNomeFromUID(uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            String nome = snapshot.data!;
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  "Nome do dentista: $nome",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 30,
                    color: Colors.black,
                  ),
                ),
                FutureBuilder<String>(
                  future: getCurriculoFromUID(uid),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      String curriculo = snapshot.data!;
                      return Text(
                        "Mini currículo: $curriculo",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 30,
                          color: Colors.black,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
                FutureBuilder<String>(
                  future: retrievePhotoUrl(uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      String photoUrl = snapshot.data ?? 'N/A';
                      return CachedNetworkImage(
                        imageUrl: photoUrl,
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                        width: 200,
                        height: 200,
                      );
                    } else {
                      return const Text('No photo found');
                    }
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    definirEmergencia(uid);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmergenciaAceita(uid: uid),
                      ),
                    );
                  },
                  child: const Text("ESCOLHER PROFISSIONAL"),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

class EmergenciaAceita extends StatelessWidget {
  final String uid;

  const EmergenciaAceita({Key? key, required this.uid});



  Future<String> getEnderecoFromUID(String uid) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: uid)
        .get();

    String id = snapshot.docs.first.id.toString();
    DocumentSnapshot doc =
    await FirebaseFirestore.instance.collection("users").doc(id).get();
    return doc.get("telefone").toString();
  }

  Future<String> getTelefoneFromUID(String uid) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: uid)
        .get();

    String id = snapshot.docs.first.id.toString();
    DocumentSnapshot doc =
    await FirebaseFirestore.instance.collection("users").doc(id).get();
    return doc.get("endereco").toString();
  }

  Future<String> getNomeFromUID(String uid) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: uid)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.get('nome');
    } else {
      return '';
    }
  }


  Future requestLocationPermission() async {
    final PermissionStatus permissionStatus = await Permission.location.request();

    return permissionStatus == PermissionStatus.granted;
  }


  Future<LocationData> getLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Handle permission denied case
        throw Exception('Location permission denied');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      // Handle location retrieval error
      print('Error retrieving location: $e');
      throw Exception('Error retrieving location: $e');
    }
  }

  void sendLocationToKotlin() async {
    try {
      LocationData location = await getLocation();

      final FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? fcmToken = await messaging.getToken();

      // Construct a data payload with the location coordinates
      Map<String, String> data = {
        'latitude': location.latitude.toString(),
        'longitude': location.longitude.toString(),
      };

      // Send the FCM message with the data payload
      messaging.sendMessage(
        to: fcmToken,
        data: data,
      );

      print('Location sent to Kotlin app');
    } catch (e) {
      // Handle error retrieving location or sending FCM
      print('Error: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atendimento'),
      ),
      body:

      FutureBuilder<String>(
        future: getNomeFromUID(uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            String nome = snapshot.data!;
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  "Nome do dentista: $nome",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 30,
                    color: Colors.black,
                  ),
                ),
                FutureBuilder<String>(
                  future: getEnderecoFromUID(uid),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      String endereco = snapshot.data!;
                      return Container(
                        padding: const EdgeInsets.all(60),
                        color: Colors.white,
                        alignment: Alignment.topCenter,
                        child:
                        Text("Telefone: $endereco",
                          textAlign: TextAlign.center, style: GoogleFonts.montserrat(
                            fontSize: 30,
                            color: Colors.black,
                          ),),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
                FutureBuilder<String>(
                  future: getTelefoneFromUID(uid),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      String endereco = snapshot.data!;
                      return Container(
                        padding: const EdgeInsets.all(60),
                        color: Colors.white,
                        alignment: Alignment.topCenter,
                        child:
                        Text("Endereço: $endereco",
                          textAlign: TextAlign.center, style: GoogleFonts.montserrat(
                            fontSize: 30,
                            color: Colors.black,
                          ),),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error  : ${snapshot.error}');
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
                ElevatedButton(
                  onPressed: () => sendLocationToKotlin(),
                  child: const Text("Enviar Localização", textAlign: TextAlign.center,),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }

}


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessagingService firebaseMessagingService = FirebaseMessagingService();
  await firebaseMessagingService.initializeFirebaseMessaging();
  firebaseMessagingService.configureFirebaseMessaging();
  runApp(const Dent());
}