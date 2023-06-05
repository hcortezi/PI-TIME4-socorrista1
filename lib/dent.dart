import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

class dent extends StatefulWidget {
  const dent({Key? key}) : super(key: key);

  @override
  State<dent> createState() => _dentState();
}

class _dentState extends State<dent>{

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "dent",
      home: Scaffold(
        backgroundColor: Colors.blueAccent,
        body:
            Text(
            "Procurando dentistas disponíveis",
            textAlign: TextAlign.center,
            style:GoogleFonts.montserrat(
              fontSize: 30,
              color: Colors.white,
            )
    ),
      ),
    );
  }
}