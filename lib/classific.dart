import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:socorrista1/main.dart';

class Classific extends StatelessWidget {
  const Classific({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classificar Atendimento'),
        centerTitle: true,
      ),
      body: Padding(
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
              decoration: const InputDecoration(
                hintText: '',
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
              decoration: const InputDecoration(
                hintText: '',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Dê uma nota para o TeethKids aplicativo:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: '',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Comente o que você achou do aplicativo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              decoration: const InputDecoration(
                hintText: '',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Handle form submission
              },
              child: const Text('Submit'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyApp()),
                );
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
