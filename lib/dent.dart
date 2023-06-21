import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socorrista1/classific.dart';
import 'package:socorrista1/location_data.dart.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Classe que representa a tela de listagem dos dentistas disponíveis
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

// Classe que representa o widget que exibe a lista de dentistas disponíveis
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
    fetchDataStream = fetchDentistasFromFirebase(); // Inicia o stream para buscar dados dos dentistas
  }

  // Método para buscar a lista de dentistas disponíveis no Firestore
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

  // Método para buscar o nome de um dentista a partir do seu ID (UID)
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

// Classe que representa os detalhes do dentista
class DentistDetailsScreen extends StatelessWidget {
  final String uid;

  const DentistDetailsScreen({Key? key, required this.uid}) : super(key: key); //Recebe o uid do dentista

  // Método para buscar o nome de um dentista pelo seu UID
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

  // Método para atualizar o status de uma emergência e atribuir um dentista a ela
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
        document.reference
            .update({'status': true, 'dentistas': uidD}).then((value) {
          print('Emergencia atualizada com sucesso');
        }).catchError((error) {
          print('Erro ao definir dentista: $error');
        });
      }
    }).catchError((error) {
      print('Erro na consulta de emergencias: $error');
    });
  }

  // Método para obter o currículo de um dentista pelo seu UID
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

  // Método para obter a URL da foto de um dentista pelo seu UID
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
      body: FutureBuilder<String>(
        future: getNomeFromUID(uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            String nome = snapshot.data!;
            return Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      // Exibe o nome do dentista
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
                        // Exibe o currículo do dentista
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
                        String photoUrl = snapshot.data ?? 'N/A'; // Se snapshot.data != null, atribui valor ao photoURL, se null, atribui 'N/A'
                        // Exibe a foto do dentista
                        return CachedNetworkImage(
                          imageUrl: photoUrl,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
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
                      // Atribui o dentista à emergência
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
                ]));
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

  const EmergenciaAceita({Key? key, required this.uid}) : super(key: key); // Recebe UID do dentista

  @override
  EmergenciaAceitaState createState() => EmergenciaAceitaState();
}

class EmergenciaAceitaState extends State<EmergenciaAceita> {
  late GoogleMapController mapController; // Controla o widget GoogleMap (permite interações com o mapa)
  LatLng? currentLocation; // Variável para armazenar Latidude e Longitude, inicialmente null
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{}; // Variável do tipo map, para adicionar marcadores no GoogleMap
  bool showMap = false; // Variável para indicar se o mapa aparece ou não, inicialmente false

  @override
  void initState() {
    super.initState();
    initializeCurrentLocation();
  }


  Future<void> initializeCurrentLocation() async {
    final LatLng loc = await gMaps(); // Obtem coordenadas da localização atual
    setState(() {
      currentLocation = loc; // Atribui as coordenadas à variável currentLocation
    });
  }

  void checkAndNavigate() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;
    UserCredential userCredential = await auth.signInAnonymously();
    User? user = userCredential.user;
    String uidS = user!.uid;

    // Repete a busca no Firestore se a emergência foi finalizada a cada 5 segundos
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      final QuerySnapshot snapshot = await firestore
          .collection('emergencias')
          .where('postID', isEqualTo: uidS)
          .where('status', isEqualTo: 'finalizado')
          .get();

      if (snapshot.docs.isNotEmpty) {
        timer.cancel(); // Cancela o timer caso seja finalizada
        navigateToClassific(); // Envia para tela de Classificar Atendimento
      }
    });
  }

  // Método que envia para tela de Classificar Atendimento
  void navigateToClassific() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const Classific()),
    );
  }

  // Obtém endereço do dentista, através de seu UID
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

  // Obtém telefone do dentista, através de seu UID
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

  // Obtém nome do dentista, através de seu UID
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

  // Obtém localização do socorrista como LocationData (usado para enviar ao Firestore)
  Future<LocationData?> getLocation() async {
    try {
      // Solicita permissão de localização ao usuário
      final LocationPermission permission =
          await Geolocator.requestPermission();

      // Verifica se a permissão foi negada
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de Localização negada');
      }

      // Obtém a posição atual do socorrista
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Retorna objeto LocationData com as coordenadas de latitude e longitude fornecidas
      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      print('Erro ao puxar localização: $e');
      return null;
    }
  }

  // Obtem localização do socorrista como LatLng (usa no no GoogleMap)
  Future<LatLng> gMaps() async {
    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return LatLng(position.latitude, position.longitude);
  }

  // Método que envia a localização ao Firestore
  void sendLocationToFirestore() async {
    // Obtém a localização atual
    final LocationData? location = await getLocation();

    if (location != null) {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;
      final String? uidS = user?.uid;

      // Extrai lat e long da localização
      final double latitude = location.latitude;
      final double longitude = location.longitude;

      // Cria objeto GeoPoint com as coordenadas
      final GeoPoint coord = GeoPoint(latitude, longitude);

      FirebaseFirestore.instance
          .collection('emergencias')
          .where('postID', isEqualTo: uidS)
          .get()
          .then((querySnapshot) {
        for (final document in querySnapshot.docs) {
          // Atualiza o campo 'coordenadas' do documento com as novas coordenadas
          document.reference.update({'coordenadas': coord}).then((value) {
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

  Future<Marker> fetchLocationFromFirestore() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final String? uidS = user?.uid;

    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('emergencias')
        .where('postID', isEqualTo: uidS)
        .get();

    final String id = snapshot.docs.first.id.toString();
    final DocumentSnapshot doc =
    await FirebaseFirestore.instance.collection("emergencias").doc(id).get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      final locationArray = data['LocalDentista'] as List<dynamic>;

      final latitude = locationArray[0] as double;
      final longitude = locationArray[1] as double;
      print(locationArray);
      final dentMarker = Marker(
        markerId: const MarkerId('dent'),
        position: LatLng(latitude,longitude),
        icon: BitmapDescriptor.defaultMarker,
      );
      markers[const MarkerId('dent')] = dentMarker;

      return dentMarker;
    }
    return Marker(markerId: MarkerId('nada'));
  }


  void _onMapCreated(GoogleMapController controller) async {
    // Armazena o controlador do Google Map
    mapController = controller;

    // Verifica se a localização atual está disponível
    if (currentLocation != null) {
      // Cria um marcador para a localização atual
      final marker = Marker(
        markerId: const MarkerId('Você'),
        position: currentLocation!, // Posição do marcador (localização atual)
        icon: BitmapDescriptor.defaultMarker,
      );
      // final Marker dentMarker = await fetchLocationFromFirestore();

      // Atualiza o estado do widget com o marcador
      setState(() {
        markers[const MarkerId('você')] = marker;
        // markers[const MarkerId('dent')] = dentMarker;

      });
    }
  }

  Widget buildMapWidget() {
    return SizedBox(
      height: 250,
      child: currentLocation != null
          ? GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: currentLocation!,
                zoom: 14.0,
              ),
        markers: markers.values.toSet(),
            )
          : const CircularProgressIndicator(),
    );
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
                    onPressed: () async {
                      sendLocationToFirestore();
                      checkAndNavigate();
                      final LatLng loc = await gMaps();
                      setState(() {
                        currentLocation = loc;
                        showMap = true;
                      });
                    },
                    child: const Text(
                      "Enviar Localização",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  showMap ? buildMapWidget() : Container(),
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const Dent());
}
