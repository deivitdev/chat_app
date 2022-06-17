import 'dart:io';

import 'package:chat_app/models/mensaje_response.dart';
import 'package:chat_app/services/auth_services.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/services/socket_service.dart';
import 'package:chat_app/widgets/chat_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  late ChatService chatService;
  late SocketService socketService;
  late AuthService authService;

  final List<ChatMessage> _messages = [];

  bool _isWriting = false;

  @override
  void initState() {
    super.initState();
    chatService = Provider.of<ChatService>(context, listen: false);
    socketService = Provider.of<SocketService>(context, listen: false);
    authService = Provider.of<AuthService>(context, listen: false);

    socketService.socket.on('mensaje-personal', _escucharMensaje);

    _cargarHistorial(this.chatService.usuarioPara.uid);
  }

  void _cargarHistorial(String usuarioId) async {
    List<Mensaje> chat = await chatService.getChat(usuarioId);

    final history = chat.map(
      (e) => ChatMessage(
        text: e.mensaje,
        uid: e.de,
        animationController: AnimationController(vsync: this, duration: Duration(milliseconds: 0))..forward(),
      ),
    );
    _messages.insertAll(0, history);
    setState(() {});
  }

  void _escucharMensaje(dynamic payload) {
    ChatMessage message = ChatMessage(
      text: payload['mensaje'],
      uid: payload['de'],
      animationController: AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300),
      ),
    );

    _messages.insert(0, message);
    setState(() {});
    message.animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Column(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blueAccent,
              maxRadius: 14,
              child: Text(
                chatService.usuarioPara.nombre.substring(0, 2),
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            SizedBox(height: 3),
            Text(
              chatService.usuarioPara.nombre,
              style: TextStyle(color: Colors.black87, fontSize: 12),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _messages.length,
              itemBuilder: (_, int i) => _messages[i],
              reverse: true,
            ),
          ),
          const Divider(
            height: 1,
          ),
          Container(
            color: Colors.white,
            child: _inputChat(),
          )
        ],
      ),
    );
  }

  Widget _inputChat() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmit,
                onChanged: (text) {
                  if (text.trim().isNotEmpty) {
                    _isWriting = true;
                  } else {
                    _isWriting = false;
                  }
                  setState(() {});
                },
                decoration: const InputDecoration.collapsed(hintText: 'Enviar mensaje'),
                focusNode: _focusNode,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Platform.isIOS
                  ? CupertinoButton(
                      onPressed: _isWriting ? () => _handleSubmit(_textController.text.trim()) : null,
                      child: const Text('Enviar'),
                    )
                  : Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: IconTheme(
                        data: const IconThemeData(
                          color: Colors.blue,
                        ),
                        child: IconButton(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          icon: const Icon(
                            Icons.send,
                          ),
                          onPressed: _isWriting ? () => _handleSubmit(_textController.text.trim()) : null,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  _handleSubmit(String text) {
    if (text.isEmpty) return;

    _textController.clear();
    _focusNode.requestFocus();

    final newMessage = ChatMessage(
      text: text,
      uid: authService.usuario!.uid,
      animationController: AnimationController(vsync: this, duration: const Duration(milliseconds: 400)),
    );

    _messages.insert(0, newMessage);
    newMessage.animationController.forward();

    _isWriting = false;

    setState(() {});

    socketService.emit('mensaje-personal', {
      'de': authService.usuario!.uid,
      'para': chatService.usuarioPara.uid,
      'mensaje': text,
    });

    void dispose() {
      //TODO: off del socket

      for (ChatMessage message in _messages) {
        message.animationController.dispose();
      }

      socketService.socket.off('mensaje-personal');
      super.dispose();
    }
  }
}
