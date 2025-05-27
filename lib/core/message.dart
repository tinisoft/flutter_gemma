import 'dart:io';

class Message {
  const Message({required this.text, this.isUser = false, this.imageFile});

  final String text;
  final bool isUser;
  final File? imageFile;
}
