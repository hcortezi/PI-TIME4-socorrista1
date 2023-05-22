import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:socorrista1/utilitario.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:socorrista1/ImageStoreMethods.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const Emergencia());
}

class Emergencia extends StatefulWidget {
  const Emergencia({Key? key}) : super(key: key);

  @override
  State<Emergencia> createState() => _EmergenciaState();
}

class _EmergenciaState extends State<Emergencia> {

  Uint8List? _file;
  final TextEditingController _dadosController = TextEditingController();

  bool _isLoading = false;
  void postImage() async{
    setState(() {
      _isLoading = true;
    });
    try {
      String res = await ImageStoreMethods().uploadPost(
        _dadosController.text,
        _file!
      );
      if (res == 'sucesso'){
        setState(() {
          _isLoading = false;
        });
        showSnackBar('Postado', context);
        clearImage();
      } else{
        setState(() {
          _isLoading = false;
        });
        showSnackBar(res, context);
      }
    } catch (err){
      showSnackBar(err.toString(), context);
    }
  }

  void clearImage(){
    setState(() {
      _file = null;
    });
  }

  _imageSelect(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Selecionar imagem'),
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Tirar foto'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(
                    ImageSource.camera,
                  );
                  setState(() {
                    _file = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Escolher da foto da galeria'),
                onPressed: () async{
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(
                    ImageSource.gallery,
                  );
                  setState(() {
                    _file = file;
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Cancelar'),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "main",
        home: Scaffold(
          appBar: AppBar(title: const Text('Página emergência'),
            centerTitle: true,
          ),
          body:
          _file == null ?
          Column(

            children: [
              const SizedBox(
                width: double.infinity,
                height: 20,
              ),
              const Text(
                'Adicione os dados solicitados:',
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.photo),
                onPressed: () => _imageSelect(context),
                iconSize: 250,
              ),
              const Text(
                'Adicione a foto do paciente',
                style: TextStyle(fontSize: 20),
              ),
              ElevatedButton(
                onPressed: (){
                  Navigator.pop(context);
                  },
                child: const Text('Voltar'),
              ),
            ],
          )
              :
              SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      _isLoading
                      ? const LinearProgressIndicator()
                      : const Padding(
                        padding: EdgeInsets.only(
                          top: 0,
                        ),
                      ),
                      const Divider(),
                      SizedBox(
                        height: 300,
                        width: 300,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: MemoryImage(_file!),
                              fit: BoxFit.fill,
                              alignment: FractionalOffset.topCenter,
                            ),
                          ),
                        ),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width*0.35,
                            child: TextField(
                              controller: _dadosController,
                              decoration: const InputDecoration(
                                hintText:'Descrevar problema',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          ElevatedButton(onPressed: postImage, child: const Text('Postar'))
                        ],
                      )
                    ],
                  )
                ),
              ),
        ),
    );
  }
}