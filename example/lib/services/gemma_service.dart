import 'dart:typed_data';

import 'package:flutter_gemma/core/chat.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

class GemmaLocalService {
  final InferenceChat _chat;

  GemmaLocalService(this._chat);

  Future<void> addQueryChunk(Message message) => _chat.addQueryChunk(message);

  Stream<String> processMessageAsync(Message message) async* {
    if (message.imageFile != null) {
      // Make sure the file exists before trying to read
      if (await message.imageFile!.exists()) {
        try {
          final Uint8List bitMapBytes = await message.imageFile!.readAsBytes();
          await _chat.addImgToCtx(bitMapBytes);
        } catch (e) {
          // Optionally, yield an error message or handle differently
          yield "Error: Could not process the image. ";
        }
      } else {
        yield "Error: Image file not found. ";
      }
    }
    await _chat.addQueryChunk(message);
    yield* _chat.generateChatResponseAsync();
  }
}
