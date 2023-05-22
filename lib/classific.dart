import 'package:flutter/material.dart';

class classific extends StatelessWidget {
  const classific({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "main",
      home: Scaffold(
          appBar: AppBar(title: const Text('Classificar Atendimento'),
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