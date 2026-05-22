import 'dart:convert';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

final ImagePicker _imagePicker = ImagePicker();

Future<String?> selecionarImagemBase64() async {
  final arquivo = await _imagePicker.pickImage(source: ImageSource.gallery);

  if (arquivo == null) {
    return null;
  }

  final bytes = await arquivo.readAsBytes();
  return base64Encode(bytes);
}

Uint8List? converterBase64EmBytes(String valor) {
  final texto = valor.trim();

  if (texto.isEmpty) {
    return null;
  }

  try {
    return base64Decode(texto);
  } catch (_) {
    return null;
  }
}
