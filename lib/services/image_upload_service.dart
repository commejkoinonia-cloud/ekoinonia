import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/imgbb_config.dart';

/// Envoie une photo à ImgBB (service externe gratuit) et retourne le lien
/// public (ex: https://ibb.co/xxxxx) à enregistrer dans le champ `imageUrl`
/// du document Firestore concerné. On n'utilise jamais Firebase Storage
/// (voir la charte technique du projet : ça évite le forfait payant Blaze).
class ImageUploadService {
  Future<String> televerserImage(File fichierImage) async {
    final octets = await fichierImage.readAsBytes();
    final imageEnBase64 = base64Encode(octets);

    final reponse = await http.post(
      Uri.parse('https://api.imgbb.com/1/upload?key=$imgbbApiKey'),
      body: {'image': imageEnBase64},
    );

    if (reponse.statusCode != 200) {
      throw Exception("Échec de l'envoi de l'image (code ${reponse.statusCode}).");
    }

    final json = jsonDecode(reponse.body);
    final lien = json['data']?['url'];
    if (lien == null) {
      throw Exception("ImgBB n'a pas renvoyé de lien valide.");
    }
    return lien as String;
  }
}