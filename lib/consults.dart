import 'package:flutter/material.dart';

class consults extends StatelessWidget {
  const consults({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "main",
      home: Scaffold(
          appBar: AppBar(title: const Text('Consultórios próximos'),
          centerTitle: true,
          ),
        body: Column(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child:ElevatedButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: const Text('Voltar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}