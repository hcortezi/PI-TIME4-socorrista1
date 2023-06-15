import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'emergencia.dart';
import 'classific.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  runApp(MaterialApp(
    title: "main",
    home: MyApp(navigatorKey: navigatorKey),
  ));
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({Key? key, required this.navigatorKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(
            "Bem vindo ao SOS Dental",
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 30,
              color: Colors.white,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(60),
            alignment: Alignment.topCenter,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(80),
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Emergencia()),
                );
              },
              icon: const Icon(
                Icons.warning,
                size: 24.0,
                color: Colors.yellow,
              ),
              label: const Text('Solicitar Emergência'),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(60),
            alignment: Alignment.center,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Classific()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(80),
                backgroundColor: Colors.blueGrey,
              ),
              icon: const Icon(
                Icons.star_rate,
                color: Colors.yellow,
              ),
              label: const Text('Classificar atendimento'),
            ),
          ),
        ],
      ),
    );
  }
}

