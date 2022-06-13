import 'dart:io';

import 'package:chat_app/widgets/chat_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  final List<ChatMessage> _messages = [];

  bool _isWriting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Column(
          children: const [
            CircleAvatar(
              backgroundColor: Colors.blueAccent,
              maxRadius: 14,
              child: Text(
                'Da',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            SizedBox(height: 3),
            Text(
              'David',
              style: TextStyle(color: Colors.black87, fontSize: 12),
            )
          ],
        ),
      ),
      body: Container(
        child: Column(
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
              child: _InputChat(),
            )
          ],
        ),
      ),
    );
  }

  Widget _InputChat() {
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
                  if (text.trim().length > 0) {
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
                      child: const Text('Enviar'),
                      onPressed: _isWriting ? () => _handleSubmit(_textController.text.trim()) : null,
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

    _focusNode.requestFocus();
    _textController.clear();

    final newMessage = ChatMessage(
      text: text,
      uid: '123',
      animationController: AnimationController(vsync: this, duration: Duration(milliseconds: 400)),
    );

    _messages.insert(0, newMessage);
    newMessage.animationController.forward();

    _isWriting = false;

    setState(() {});
    void dispose() {
      //TODO: off del socket

      for (ChatMessage message in _messages) {
        message.animationController.dispose();
      }

      super.dispose();
    }
  }
}
