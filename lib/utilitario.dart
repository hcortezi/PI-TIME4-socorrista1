import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

// Função para selecionar imagem da câmera
Future<Uint8List>pickImage(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker(); // Cria instância do ImagePicker para selecionar imagem
  XFile? file = await imagePicker.pickImage(source: source); // Atribuição do imagePicker, XFile pode ser arquivo de imagem ou null

  if (file != null) {
    // Retorna o conteúdo da imagem como bytes
    return await file.readAsBytes();
  }
  throw Exception('Nenhuma imagem selecionada');
}
