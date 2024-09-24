import 'package:ai_based/const/cons.dart';
import 'package:ai_based/widgets/chat.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.title,
    required this.toggleTheme,
    required this.isDarkTheme,
  });

  final String title;
  final Function toggleTheme;
  final bool isDarkTheme;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        title: Center(child: Text(widget.title)),
        actions: [
          IconButton(
            icon: Icon(
                widget.isDarkTheme ? Icons.brightness_7 : Icons.brightness_2),
            onPressed: () {
              widget.toggleTheme();
            },
          ),
        ],
      ),
      body: const ChatWidget(apiKey: GEMINI_API_KEY),
    );
  }
}
