import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'emergencia.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MaterialApp(
    title: "main",
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          // Título
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
                // Envia para a página de emergência
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
        ],
      ),
    );
  }
}
