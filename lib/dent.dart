

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
import 'package:google_maps_flutter/google_maps_flutter.dart';



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
        .where('postID', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      List<String> dentistasList = [];
      if (snapshot.size > 0) {
        Map<String, dynamic>? data = snapshot.docs.first.data();
        if (data != null && data.containsKey('dentistas')) {
          List<dynamic> dentistasArray = data['dentistas'];
          dentistasList = dentistasArray.map((item) => item.toString()).toList();
        }
      }
      return dentistasList;
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
    String? uidE = user?.uid;

    FirebaseFirestore.instance
        .collection('emergencias')
        .where('postID', isEqualTo: uidE)
        .get()
        .then((querySnapshot) {
      for (var document in querySnapshot.docs) {
        document.reference.update({'status': true, 'dentistas': uidD})
            .then((value) {
          print('Emergencia atualizada com sucesso');
        }).catchError((error) {
          print('Erro ao definir dentista: $error');
        });
      }
    }).catchError((error) {
      print('Erro na consulta de emergencias: $error');
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
                  future: getCurriculoFromUID(uid),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      String curriculo = snapshot.data!;
                      return Text(
                        curriculo,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 30,
                          color: Colors.black,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return const Text('Sem currículo');
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
                      return const Text('Dentista sem foto');
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
                      return const Text('Dentista sem foto');
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

  const EmergenciaAceita({Key? key, required this.uid}) : super(key:key);



  Future<String?> getEnderecoFromUID(String uid) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: uid)
        .get();

    String id = snapshot.docs.first.id.toString();
    DocumentSnapshot doc =
    await FirebaseFirestore.instance.collection("users").doc(id).get();
    return doc.get("endereco").toString();
  }

  Future<String?> getTelefoneFromUID(String uid) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: uid)
        .get();

    String id = snapshot.docs.first.id.toString();
    DocumentSnapshot doc =
    await FirebaseFirestore.instance.collection("users").doc(id).get();
    return doc.get("telefone").toString();
  }

  Future<String?> getNomeFromUID(String uid) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: uid)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.get('nome') as String?;
    } else {
      return null;
    }
  }


  Future<bool> requestLocationPermission() async {
    final PermissionStatus permissionStatus = await Permission.location.request();

    return permissionStatus == PermissionStatus.granted;
  }


  Future<LocationData?> getLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
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
      print('Error retrieving location: $e');
      return null;
    }
  }

  void sendLocationToKotlin() async {
    LocationData? location = await getLocation();

    if (location != null) {
      final FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;
      final uidS = user?.uid;

      final latitude = location.latitude;
      final longitude = location.longitude;

      GeoPoint dados = GeoPoint(latitude, longitude);

      FirebaseFirestore.instance
          .collection('emergencias')
          .where('postID', isEqualTo: uidS)
          .get()
          .then((querySnapshot) {
        for (var document in querySnapshot.docs) {
          document.reference.update({'cordenadas': dados}).then((value) {
            print("Inserido no firestore");
          }).catchError((error) {
            print("Error updating document: $error");
          });
        }
      }).catchError((error) {
        print("Error getting documents: $error");
      });
    }
  }


  Future<void> initializeFirebaseMessaging() async {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      announcement: true,
      criticalAlert: true,
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
  }

  void configureFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message: ${message.notification?.body}');
      // Handle the received message here
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Opened app from background message: ${message.notification?.body}');
      // Handle the opened app from background message here
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atendimento'),
      ),
      body: FutureBuilder<String?>(
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
                FutureBuilder<String?>(
                  future: getEnderecoFromUID(uid),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      String endereco = snapshot.data!;
                      return Text(
                          "Endereço: $endereco",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
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
                FutureBuilder<String?>(
                  future: getTelefoneFromUID(uid),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      String telefone = snapshot.data!;
                      return Text(
                          "Telefone: $telefone",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
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
                ElevatedButton(
                  onPressed: () => sendLocationToKotlin(),
                  child: const Text(
                    "Enviar Localização",
                    textAlign: TextAlign.center,
                  ),
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
  runApp(const Dent());
}