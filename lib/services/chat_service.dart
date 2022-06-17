import 'package:chat_app/global/enviroment.dart';
import 'package:chat_app/models/mensaje_response.dart';
import 'package:chat_app/models/usuario.dart';
import 'package:chat_app/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatService with ChangeNotifier {
  late Usuario usuarioPara;

  Future<List<Mensaje>> getChat(String usuarioId) async {
    final resp = await http.get(
      Uri.parse(
        '${Environment.apiUrl}/mensajes/$usuarioId',
      ),
      headers: {
        'Content-Type': 'application/json',
        'x-token': await AuthService.getToken() ?? '',
      },
    );

    final mensajeResponse = mensajesResponseFromJson(resp.body);

    return mensajeResponse.mensajes;
  }
}
