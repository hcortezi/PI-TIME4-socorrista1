import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:socorrista1/utilitario.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:socorrista1/image_store_methods.dart';
import 'dent.dart';

final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
GlobalKey<ScaffoldMessengerState>();


  //SnackBar com duração de 2 segundos
void showSnackBar(String content) {
  final snackBar = SnackBar(
    content: Text(content),
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 2),
  );
  _scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
}

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
  Uint8List? _file; // Variável para armazenar a imagem selecionada
  final TextEditingController _dadosController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();

  bool _isLoading = false; // Indica se o envio da foto está sendo executado ou não

  Future<String> postImage() async {
    setState(() {
      _isLoading = true; // Define o estado para carregando
    });

    try {
      String res = await ImageStoreMethods().uploadPost(
        _dadosController.text,
        _nomeController.text,
        _telefoneController.text,
        _file!,
      );

      if (res == 'sucesso') {
        setState(() {
          _isLoading = false; // Define o estado como não carregando
        });
        clearImage(); // Limpa a imagem selecionada
        clearText(); // Limpa os campos de texto
      } else {
        setState(() {
          _isLoading = false; // Define o estado como não carregando
        });
      }
      return res;
    } catch (err) {
      showSnackBar(err.toString()); // Mostra uma mensagem de erro em caso de falha
      return '';
    }
  }

  void clearImage() {
    setState(() {
      _file = null; // Limpa a imagem selecionada
    });
  }

  // Limpa as caixas de texto
  void clearText() {
    _dadosController.clear();
    _nomeController.clear();
    _telefoneController.clear();
  }

  _imageSelect() async {
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
                  ImageSource.camera, // Source do image picker como câmera
                );
                setState(() {
                  _file = file; // Define a imagem selecionada
                });
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }



@override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "main",
      home: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Página emergência'),
            centerTitle: true,
          ),
          body: _file == null
              // Se _file (foto) == null, então...
              ? Column(
                  children: [
                    const SizedBox(
                      width: double.infinity,
                      height: 20,
                    ),
                    const Text(
                      'Adicione os dados solicitados:',
                      style:
                          TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.photo),
                      onPressed: _imageSelect,
                      iconSize: 220,
                    ),
                    const Text(
                      'Foto da boca do paciente',
                      style: TextStyle(fontSize: 22),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Voltar'),
                        ),
                      ),
                    ),
                  ],
                )
              // Se _file(foto) != null, então...
              : SingleChildScrollView(
                  child: Builder(
                    builder: (BuildContext context) {
                      return Center(
                        child: Column(
                          children: [
                            _isLoading
                                // Se _isLoading true...
                                ? const LinearProgressIndicator()
                                // Se _isLoading false...
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
                                      hintText: 'Descrever problema',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                const Divider(),
                                SizedBox(
                                  child: TextField(
                                    controller: _nomeController,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[a-zA-Z ]'))
                                    ],
                                    decoration: const InputDecoration(
                                      hintText: 'Nome:',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                const Divider(),
                                SizedBox(
                                  child: TextField(
                                    controller: _telefoneController,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9]'))
                                    ],
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      hintText: 'Telefone:',
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
                              onPressed: () async {
                                if ((_nomeController.text.isNotEmpty) &&
                                    (_telefoneController.text.isNotEmpty) &&
                                    (_dadosController.text.isNotEmpty)) {
                                  await postImage().whenComplete(() {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const Dent(),
                                      ),
                                    );
                                  });
                                } else {
                                  showSnackBar("Insira as informações");
                                }
                              },
                              child: const Text('Solicitar socorro'),
                            ),
                            const Divider(),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Voltar'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }
}
