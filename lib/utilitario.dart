import 'package:image_picker/image_picker.dart';

// Função para selecionar imagem da câmera
pickImage(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: source);

  if (file != null) {
    // Retorna o conteúdo da imagem como bytes
    return await file.readAsBytes();
  }
}
