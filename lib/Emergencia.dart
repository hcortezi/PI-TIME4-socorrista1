import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:socorrista1/utilitario.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:socorrista1/ImageStoreMethods.dart';
import 'dent.dart';


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
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();

  bool _isLoading = false;
  Future<String> postImage() async{
    String res = "";
    setState(() {
      _isLoading = true;
    });
    try {
      String res = await ImageStoreMethods().uploadPost(
        _dadosController.text,
        _nomeController.text,
        _telefoneController.text,
        _file!
      );
      if (res == 'sucesso'){
        setState(() {
          _isLoading = false;
        });
        showSnackBar('Postado', dent as BuildContext);
        clearImage();
        clearText();
      } else{
        setState(() {
          _isLoading = false;
        });
        showSnackBar(res, Emergencia as BuildContext);
      }
    } catch (err){
      showSnackBar(err.toString(), Emergencia as BuildContext);
    }
    return res;
  }

  void clearImage(){
    setState(() {
      _file = null;
    });
  }

  void clearText() {
    _dadosController.clear();
    _nomeController.clear();
    _telefoneController.clear();
  }

  _imageSelect(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Selecionar opção'),
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
                iconSize: 220,
              ),
              const Text(
                'Foto do paciente',
                style: TextStyle(fontSize: 22),
              ),
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
                        height: 200,
                        width: 200,
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
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(

                            child: TextField(
                              controller: _dadosController,
                              decoration: const InputDecoration(
                                hintText:'Descrever problema',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const Divider(),
                          SizedBox(
                            child: TextField(
                              controller: _nomeController,
                              decoration: const InputDecoration(
                                hintText:'Nome:',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const Divider(),
                          SizedBox(

                            child: TextField(
                              controller: _telefoneController,
                              decoration: const InputDecoration(
                                hintText:'Telefone:',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size(200, 70),
                                backgroundColor: Colors.red,
                            ),
                            onPressed:() async{
                              if((_nomeController.text.isNotEmpty)&&(_telefoneController.text.isNotEmpty)&&(_dadosController.text.isNotEmpty)){
                                await postImage().whenComplete(()=>Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const dent()),
                                ));
                              }
                              else{
                                showSnackBar("Insira as informações", context);
                              }
                            },
                          child: const Text('Solicitar socorro'),
                        ),
                            // onPressed: postImage, child: const Text('Solicitar socorro')),
                      const Divider(),
                      ElevatedButton(
                        onPressed: (){
                          Navigator.of(context).pop();
                        },
                        child: const Text('Voltar'),
                      ),
                    ],
                  )
                ),
              ),
        ),
    );
  }
}