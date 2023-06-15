

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socorrista1/classific.dart';
import 'package:socorrista1/location_data.dart.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Dent extends StatelessWidget {
  const Dent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista dos Dentistas',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Lista dos Dentistas'),
          centerTitle: true,
        ),
        body: const Column(
          children: [
            LinearProgressIndicator(),
            SizedBox(height: 10),
            Text(
              'Estamos procurando profissionais para te auxiliar...',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Expanded(child: DentWidget()),
          ],
        ),
      ),
    );
  }
}

class DentWidget extends StatefulWidget {
  const DentWidget({Key? key}) : super(key: key);

  @override
  DentWidgetState createState() => DentWidgetState();
}

class DentWidgetState extends State<DentWidget> {
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
      return Stream.error('Usuário não logado');
    }

    String uid = user.uid;

    return FirebaseFirestore.instance
        .collection('emergencias')
        .where('status', isEqualTo: false)
        .where('postID', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      List<String> dentistasList = [];
      if (snapshot.size > 0) {
        Map<String, dynamic>? data = snapshot.docs.first.data();
        if (data.containsKey('dentistas')) {
          List<dynamic> dentistasArray = data['dentistas'];
          dentistasList =
              dentistasArray.map((item) => item.toString()).toList();
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
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DentistDetailsScreen(uid: uid),
                          ),
                        );
                      },
                      child: Text(
                        nome,
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    );
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

  const DentistDetailsScreen({Key? key, required this.uid}) : super(key: key);

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
    String? uidS = user?.uid;

    FirebaseFirestore.instance
        .collection('emergencias')
        .where('postID', isEqualTo: uidS)
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
      print('Erro puxando photo URL: $e');
      throw Exception('Erro puxando photo URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Dentista'),
        centerTitle: true,
      ),
      body:
      FutureBuilder<String>(
        future: getNomeFromUID(uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            String nome = snapshot.data!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    nome,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
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
                            fontSize: 17,
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
                          width: 150,
                          height: 150,
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
                ]
              )
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

class EmergenciaAceita extends StatefulWidget {
  final String uid;

  const EmergenciaAceita({Key? key, required this.uid}) : super(key: key);

  @override
  _EmergenciaAceitaState createState() => _EmergenciaAceitaState();
}

class _EmergenciaAceitaState extends State<EmergenciaAceita> {


  void checkAndNavigate() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;
    UserCredential userCredential = await auth.signInAnonymously();
    User? user = userCredential.user;
    String uidS = user!.uid;

    Timer.periodic(const Duration(seconds: 5), (timer) async {
      final QuerySnapshot snapshot = await firestore
          .collection('emergencias')
          .where('postID', isEqualTo: uidS)
          .where('status', isEqualTo: 'finalizado')
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Document matching the criteria is found
        timer.cancel(); // Stop the periodic timer
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Classific()),
        );
      }
    });
  }


  Future<String?> getEnderecoFromUID(String uid) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: uid)
        .get();

    final String id = snapshot.docs.first.id.toString();
    final DocumentSnapshot doc =
    await FirebaseFirestore.instance.collection("users").doc(id).get();
    return doc.get("endereco").toString();
  }

  Future<String?> getTelefoneFromUID(String uid) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: uid)
        .get();

    final String id = snapshot.docs.first.id.toString();
    final DocumentSnapshot doc =
    await FirebaseFirestore.instance.collection("users").doc(id).get();
    return doc.get("telefone").toString();
  }

  Future<String?> getNomeFromUID(String uid) async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: uid)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.get('nome') as String?;
    } else {
      return null;
    }
  }


  Future<LocationData?> getLocation() async {
    try {
      final LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de Localização negada');
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      print('Erro ao puxar localização: $e');
      return null;
    }
  }

  void sendLocationToFirestore() async {
    final LocationData? location = await getLocation();

    if (location != null) {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;
      final String? uidS = user?.uid;

      final double latitude = location.latitude;
      final double longitude = location.longitude;

      final GeoPoint dados = GeoPoint(latitude, longitude);

      FirebaseFirestore.instance
          .collection('emergencias')
          .where('postID', isEqualTo: uidS)
          .get()
          .then((querySnapshot) {
        for (final document in querySnapshot.docs) {
          document.reference.update({'coordenadas': dados}).then((value) {
            print("Inserido no Firestore");
          }).catchError((error) {
            print("Erro ao atualizar documento: $error");
          });
        }
      }).catchError((error) {
        print("Erro ao pegar documento: $error");
      });
    }
  }

  Future<void> initializeFirebaseMessaging() async {
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    final NotificationSettings settings = await firebaseMessaging.requestPermission(
      announcement: true,
      criticalAlert: true,
      alert: true,
      badge: true,
      sound: true,
    );
    print('Usuário deu permissão: ${settings.authorizationStatus}');
    final String? token = await firebaseMessaging.getToken();
    print('Token: $token');
  }

  void configureFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensagem recebida: ${message.notification?.body}');
      // Handle the received message here
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App aperto da background msg: ${message.notification?.body}');
      // Handle the opened app from background message here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atendimento'),
        centerTitle: true,
      ),
      body: FutureBuilder<String?>(
        future: getNomeFromUID(widget.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final String nome = snapshot.data!;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    nome,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                  FutureBuilder<String?>(
                    future: getEnderecoFromUID(widget.uid),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final String endereco = snapshot.data!;
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
                    future: getTelefoneFromUID(widget.uid),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final String telefone = snapshot.data!;
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
                    onPressed: () {
                      sendLocationToFirestore();
                      checkAndNavigate();
                    },
                    child: const Text(
                      "Enviar Localização",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
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