import 'dart:io'; // Required for 'File' type in the Message class

import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart'; // As in the original provided snippet
import 'package:flutter_markdown/flutter_markdown.dart';

// The Message class definition (as provided in the problem description)
// This should be accessible in the same scope or imported.
// For completeness, it's good to have it here or ensure it's defined elsewhere.
/*
class Message {
  const Message({required this.text, this.isUser = false, this.imageFile});

  final String text;
  final bool isUser;
  final File? imageFile;
}
*/

class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget({super.key, required this.message});

  // Assuming 'Message' class is defined as in the problem description,
  // including 'text', 'isUser', and 'imageFile' fields.
  final Message message;

  @override
  Widget build(BuildContext context) {
    // Determine text color based on theme brightness for better readability on the bubble.
    // The original bubble color (0x80757575) is a semi-transparent grey.
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white // Light text for dark theme
        : Colors.black87; // Dark text for light theme

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align avatar and bubble to their top
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          // Bot's avatar on the left
          if (!message.isUser) ...[
            _buildAvatar(),
            const SizedBox(width: 10),
          ],

          // Message bubble
          Expanded(
            child: Container(
              constraints: BoxConstraints(
                // Max width for the chat bubble
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: const Color(0x80757575), // Original bubble color
                borderRadius:
                    BorderRadius.circular(8.0), // Original border radius
              ),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Column takes minimum vertical space
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Content aligns to the left
                children: <Widget>[
                  // Display image if it exists
                  if (message.imageFile != null)
                    Container(
                      margin: EdgeInsets.only(
                        // Add space below image if text follows
                        bottom: message.text.isNotEmpty ? 8.0 : 0.0,
                      ),
                      constraints: const BoxConstraints(
                        maxHeight: 250, // Max height for image preview
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            6.0), // Rounded corners for the image
                        child: Image.file(
                          message.imageFile!,
                          width: double
                              .infinity, // Image takes full available width
                          fit: BoxFit.cover, // Cover the area, may crop
                          errorBuilder: (context, error, stackTrace) {
                            // Placeholder for image load errors
                            return Container(
                              height:
                                  150, // Example height for error placeholder
                              color: Colors.grey[200],
                              child: Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey[400],
                                  size: 40,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  // Display text if it's not empty
                  if (message.text.isNotEmpty)
                    MarkdownBody(
                      data: message.text,
                      selectable: true, // Allow text selection
                      styleSheet: MarkdownStyleSheet(
                        // Apply text color for better readability
                        p: TextStyle(color: textColor),
                        // You can customize other markdown elements (headings, code, etc.) here
                      ),
                    )
                  // Display loading indicator if there's no text AND no image
                  // (e.g., bot is preparing its response)
                  else if (message.imageFile == null)
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          ),

          // User's avatar on the right
          if (message.isUser) ...[
            const SizedBox(width: 10),
            _buildAvatar(),
          ],
        ],
      ),
    );
  }

  // Original _buildAvatar method
  Widget _buildAvatar() {
    return message.isUser
        ? const Icon(Icons.person)
        : _circled('assets/gemma.png');
  }

  // Original _circled method for Gemma's avatar
  Widget _circled(String image) => CircleAvatar(
      backgroundColor: Colors.transparent, foregroundImage: AssetImage(image));
}
