import 'package:flutter/material.dart';

class Emergencia extends StatelessWidget {
  const Emergencia({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "main",
      home: Scaffold(
        appBar: AppBar(title: const Text('Página emergência'),
        centerTitle: true,
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: const Text('Voltar'),
          ),
        )
      ),
    );
  }
}