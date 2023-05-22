import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Emergencia.dart';
import 'chat.dart';
import 'classific.dart';
import 'consults.dart';
import 'firebase_options.dart';
import 'hist.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MaterialApp(
    title: "main",
    home: MyApp(),
  ));
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bem vindo ao SOS Dental!'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget> [
          Container(
            padding: const EdgeInsets.all(30),
            alignment: Alignment.topCenter,
            child:
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(80),
                  backgroundColor: Colors.red
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
                  color: Colors.yellow
              ),
              label: const Text('Solicitar Emergência'),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                height: 90,
                width: 150,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const chat()),
                    );
                  },
                  icon: const Icon(
                    Icons.message,
                  ),
                  label: const Text('Chat'),
                ),
              ),
              SizedBox(
                height: 90,
                width: 150,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const consults()),
                    );
                  },
                  icon: const Icon(
                    Icons.location_on,
                  ),
                  label: const Text('Consultórios próximos'),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                height: 90,
                width: 150,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const classific()),
                    );
                  },
                  icon: const Icon(
                    Icons.star_rate,
                  ),
                  label: const Text('Classificar atendimento'),
                ),
              ),
              SizedBox(
                height: 90,
                width: 150,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const hist()),
                    );
                  },
                  icon: const Icon(
                    Icons.menu_book,
                  ),
                  label: const Text('Histórico de atendimento'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}