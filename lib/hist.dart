import 'package:flutter/material.dart';

class hist extends StatelessWidget {
  const hist({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "main",
      home: Scaffold(
          appBar: AppBar(title: const Text('Histórico de Atendimentos'),
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