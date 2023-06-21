import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:socorrista1/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Classific extends StatefulWidget {
  const Classific({Key? key}) : super(key: key);

  @override
  State<Classific> createState() => _ClassificState();
}

final TextEditingController q1Controller = TextEditingController();
final TextEditingController q2Controller = TextEditingController();
final TextEditingController q3Controller = TextEditingController();
final TextEditingController q4Controller = TextEditingController();

class _ClassificState extends State<Classific> {
  // Função para enviar a avaliação para o Firestore
  Future<void> sendFirestore() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    String? uidS = user?.uid;

    // Acessando Firestore, coleção 'emergencias'
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference collection = firestore.collection('emergencias');

    // Verificando documento onde UID igual do usuário e status 'finalizado'
    final QuerySnapshot snapshot = await collection
        .where('postID', isEqualTo: uidS)
        .where('status', isEqualTo: 'finalizado')
        .get();

    if (snapshot.docs.isNotEmpty) {
      final DocumentSnapshot document = snapshot.docs.first;
      final String documentID = document.id;

      // Pegando respostas do input
      final String answer1 = q1Controller.text;
      final String answer2 = q2Controller.text;
      final String answer3 = q3Controller.text;
      final String answer4 = q4Controller.text;

      // Criação do Mapa com dados de avaliação
      final Map<String, dynamic> avaliacaoData = {
        'avaliacao': {
          'Nota do dentista': answer1,
          'O que achou do atendimento geral': answer2,
          'Nota do aplicativo': answer3,
          'Comentário sobre o aplicativo': answer4,
        },
      };

      // Atualizando o documento no Firestore com os dados da avaliação
      await collection.doc(documentID).update(avaliacaoData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classificar Atendimento'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Responda as seguintes questões:',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              const Text(
                'De uma nota de 0 a 5 estrelas pelo atendimento do profissional que lhe atendeu:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: q1Controller,
                decoration: const InputDecoration(
                  hintText: 'Nota de 0 a 5',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[0-5]$')),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Comente o que achou do atendimento em geral:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: q2Controller,
                decoration: const InputDecoration(
                  hintText: '',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Dê uma nota para o aplicativo SOSDental:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: q3Controller,
                decoration: const InputDecoration(
                  hintText: 'Nota de 0 a 5',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[0-5]$')),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Comente o que você achou do aplicativo:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: q4Controller,
                decoration: const InputDecoration(
                  hintText: '',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  sendFirestore(); // Enviar os dados da avaliação
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MyApp()));
                },
                child: const Text('Enviar'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyApp()),
                  );
                },
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      )
    );
  }
}
