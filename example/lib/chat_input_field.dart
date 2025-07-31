import 'package:flutter/material.dart';
import 'dart:io'; // Required for File
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

// --- Data Model ---
class ChatMessageInputData {
  final String text;
  final File? imageFile;
  final File? audioFile;

  ChatMessageInputData({required this.text, this.imageFile, this.audioFile});

  bool get isEmpty =>
      text.trim().isEmpty && imageFile == null && audioFile == null;
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
    final File? audioFile = messageData['audioFile'] as File?;
    final bool isUser = messageData['isUser'] as bool;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
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
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    if (audioFile != null)
                      Row(
                        children: [
                          const Icon(Icons.audiotrack, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            "Audio message",
                            style: const TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                    if ((imageFile != null || audioFile != null) &&
                        text.isNotEmpty)
                      const SizedBox(height: 8.0),
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
  File? _recordedAudioFile;

  // For recording
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;

  void _handleSubmit() {
    final text = _textController.text.trim();
    final inputData = ChatMessageInputData(
      text: text,
      imageFile: _selectedImageFile,
      audioFile: _recordedAudioFile,
    );

    if (inputData.isNotEmpty) {
      widget.handleSubmitted(inputData);
      _textController.clear();
      setState(() {
        _selectedImageFile = null;
        _recordedAudioFile = null;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
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
          SnackBar(content: Text('Error picking image: ${e.toString()}')),
        );
      }
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleRecording() async {
    try {
      if (_isRecording) {
        // Stop recording
        final path = await _audioRecorder.stop();
        setState(() {
          _isRecording = false;
          if (path != null) {
            _recordedAudioFile = File(path);
          }
        });
      } else {
        // Start recording
        if (await _audioRecorder.hasPermission()) {
          const encoder = AudioEncoder.wav;
          final dir = await getTemporaryDirectory();
          final path =
              '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.wav';

          const config = RecordConfig(
            encoder: encoder,
            numChannels: 1,
            sampleRate: 16000,
          );

          await _audioRecorder.start(
            config,
            path: path,
          );
          setState(() {
            _isRecording = true;
          });
        } else {
          debugPrint("Microphone permission denied.");
        }
      }
    } catch (e) {
      debugPrint("Recording error: $e");
      setState(() => _isRecording = false);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _audioRecorder.dispose();
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
            // Preview for selected image or audio
            if (_selectedImageFile != null || _recordedAudioFile != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    if (_selectedImageFile != null)
                      Expanded(
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
                              child: _buildCloseButton(),
                            ),
                          ],
                        ),
                      ),
                    if (_recordedAudioFile != null)
                      Expanded(
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.audiotrack),
                                SizedBox(width: 8),
                                Text("Audio recorded"),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _recordedAudioFile = null;
                                });
                              },
                              child: _buildCloseButton(),
                            ),
                          ],
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
                  IconButton(
                    icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                    color: _isRecording ? Colors.red : null,
                    onPressed: _toggleRecording,
                    tooltip: _isRecording ? "Stop recording" : "Record audio",
                  ),
                  Flexible(
                    child: TextField(
                      controller: _textController,
                      onSubmitted: (_) => _handleSubmit(),
                      decoration: const InputDecoration.collapsed(
                        hintText: 'Send a message...',
                      ),
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.send,
                      onChanged: (text) {
                        setState(() {});
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: (_textController.text.trim().isNotEmpty ||
                            _selectedImageFile != null ||
                            _recordedAudioFile != null)
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

  Widget _buildCloseButton() {
    return Container(
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
    );
  }
}
