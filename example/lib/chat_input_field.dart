import 'package:flutter/material.dart';
import 'dart:io'; // Required for File
import 'package:image_picker/image_picker.dart'; // Import image_picker

// --- Data Model ---
class ChatMessageInputData {
  final String text;
  final File? imageFile;

  ChatMessageInputData({required this.text, this.imageFile});

  bool get isEmpty => text.trim().isEmpty && imageFile == null;
  bool get isNotEmpty => !isEmpty;
}

// --- Main Application ---
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
        ).copyWith(
          secondary: Colors.green, // Used for icons in ChatInputField
        ),
        cardColor: Colors.white, // Used for ChatInputField background
      ),
      home: const ChatScreen(),
    );
  }
}

// --- Chat Screen Widget ---
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> _messages = []; // Stores message data

  void _handleSubmittedMessage(ChatMessageInputData inputData) {
    // In a real app, you'd upload the imageFile if present,
    // then send the text and/or image URL to your backend.
    setState(() {
      final Map<String, dynamic> message = {
        'text': inputData.text,
        'imageFile': inputData.imageFile,
        'timestamp': DateTime.now(),
        'isUser':
            true, // Assuming messages from this input are from the current user
      };
      _messages.insert(
          0, message); // Add to the beginning for reverse list display
    });

    // For demonstration:
    if (inputData.imageFile != null) {
      print("Image to send: ${inputData.imageFile!.path}");
    }
    if (inputData.text.isNotEmpty) {
      print("Text to send: ${inputData.text}");
    }
  }

  Widget _buildMessageItem(Map<String, dynamic> messageData) {
    final String text = messageData['text'] as String;
    final File? imageFile = messageData['imageFile'] as File?;
    final bool isUser = messageData['isUser'] as bool;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            // Ensures message bubble doesn't overflow
            child: Card(
              color: isUser ? Colors.blue[100] : Colors.grey[200],
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageFile != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(
                          imageFile,
                          width: 150, // Adjust as needed
                          height: 150, // Adjust as needed
                          fit: BoxFit.cover,
                        ),
                      ),
                    if (imageFile != null && text.isNotEmpty)
                      const SizedBox(
                          height: 8.0), // Spacer if both image and text
                    if (text.isNotEmpty)
                      Text(
                        text,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Chat'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              reverse: true, // To show latest messages at the bottom
              itemCount: _messages.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildMessageItem(_messages[index]);
              },
            ),
          ),
          ChatInputField(handleSubmitted: _handleSubmittedMessage),
        ],
      ),
    );
  }
}

// --- Chat Input Field Widget ---
class ChatInputField extends StatefulWidget {
  final ValueChanged<ChatMessageInputData> handleSubmitted;

  const ChatInputField({super.key, required this.handleSubmitted});

  @override
  ChatInputFieldState createState() => ChatInputFieldState();
}

class ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImageFile;

  void _handleSubmit() {
    final text = _textController.text.trim();
    final inputData = ChatMessageInputData(
      text: text,
      imageFile: _selectedImageFile,
    );

    if (inputData.isNotEmpty) {
      widget.handleSubmitted(inputData);
      _textController.clear();
      setState(() {
        _selectedImageFile = null;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Optional: compress image
        maxWidth: 1024, // Optional: resize image
        maxHeight: 1024, // Optional: resize image
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error picking image: ${e.toString().split(':').last.trim()}')),
        );
      }
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext sheetContext) {
        // Use a different context name
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(sheetContext).pop(); // Use sheetContext
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(sheetContext).pop(); // Use sheetContext
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(25.0),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 2),
              blurRadius: 3,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Preview for selected image
            if (_selectedImageFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(
                        _selectedImageFile!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImageFile = null;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4.0),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Main input row
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    onPressed: () => _showImageSourceActionSheet(context),
                    tooltip: "Attach image",
                  ),
                  Flexible(
                    child: TextField(
                      controller: _textController,
                      onSubmitted: (_) => _handleSubmit(),
                      decoration: const InputDecoration.collapsed(
                        hintText: 'Send a message...',
                      ),
                      minLines: 1,
                      maxLines: 5, // Allow multi-line input
                      textInputAction: TextInputAction.send,
                      onChanged: (text) {
                        // You can call setState here if you want the send button
                        // to update its enabled state reactively.
                        setState(() {});
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    // Disable button if both text and image are empty
                    onPressed: (_textController.text.trim().isNotEmpty ||
                            _selectedImageFile != null)
                        ? _handleSubmit
                        : null,
                    tooltip: "Send",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
