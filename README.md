# Flutter ChatBot Widget

A highly customizable and feature-rich ChatBot widget for Flutter applications with support for multiple themes, typing indicators, Lottie animations, and flexible API integration.

## Features

- 🎨 **6 Built-in Themes**: Modern, Minimal, Colorful, Dark, Glassmorphism, Neon
- 💬 **Multiple Bubble Styles**: Rounded, Sharp, Balloon, Minimal, Gradient, Neon
- ⌨️ **Typing Indicators**: Lottie animations or default animated dots
- 🔧 **Highly Customizable**: Colors, fonts, layouts, and more
- 🌐 **Flexible API Integration**: Support for any REST API
- 📱 **Responsive Design**: Works on all screen sizes
- ♿ **Accessibility**: Built-in accessibility features
- 🔄 **Auto-scroll**: Automatic scrolling to new messages
- 💾 **Message History**: Load initial conversation history
- ⚡ **Performance Optimized**: Efficient rendering and animations

## Installation

Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  devs_chat_bot: ^latest_version
```

## Quick Start

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'chat_bot_screen.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatBotScreen(
        apiConfig: ChatBotApiConfig(
          initialGetUrl: 'https://api.example.com/chat/history',
          sendMessageUrl: 'https://api.example.com/chat/send',
          responseParser: (response) => ChatMessage.fromJson(response),
          initialMessagesParser: (response) => 
            (response['messages'] as List)
              .map((msg) => ChatMessage.fromJson(msg))
              .toList(),
        ),
        errorConfig: ErrorMessagesConfig(),
      ),
    );
  }
}
```

## API Configuration

### ChatBotApiConfig

Configure how the widget communicates with your backend API.

```dart
ChatBotApiConfig(
  // Required: URL to fetch initial messages/conversation history
  initialGetUrl: 'https://api.example.com/chat/history',
  
  // Required: URL to send new messages
  sendMessageUrl: 'https://api.example.com/chat/send',
  
  // Optional: Custom headers for all requests
  headers: {
    'Authorization': 'Bearer your-token',
    'Content-Type': 'application/json',
  },
  
  // Optional: Body for initial GET request (if needed)
  initialGetBody: {
    'user_id': 'user123',
    'conversation_id': 'conv456',
  },
  
  // Optional: Custom message body builder
  sendMessageBodyBuilder: (message) => jsonEncode({
    'message': message,
    'user_id': 'user123',
    'timestamp': DateTime.now().toIso8601String(),
  }),
  
  // Required: Parse bot response into ChatMessage
  responseParser: (response) {
    return ChatMessage(
      id: response['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: response['message'] ?? response['content'],
      type: MessageType.bot,
      timestamp: DateTime.now(),
    );
  },
  
  // Required: Parse initial messages from API response
  initialMessagesParser: (response) {
    final messages = response['messages'] as List? ?? [];
    return messages.map((msg) => ChatMessage.fromJson(msg)).toList();
  },
)
```

### Expected API Response Formats

#### Initial Messages Response
```json
{
  "messages": [
    {
      "id": "msg1",
      "content": "Hello! How can I help you?",
      "type": "bot",
      "timestamp": 1640995200000
    },
    {
      "id": "msg2", 
      "content": "I need help with my order",
      "type": "user",
      "timestamp": 1640995260000
    }
  ]
}
```

#### Send Message Response
```json
{
  "id": "msg3",
  "message": "I'd be happy to help with your order. What's your order number?",
  "content": "I'd be happy to help with your order. What's your order number?",
  "timestamp": 1640995320000
}
```

## UI Customization

### Themes

Choose from 6 pre-built themes:

```dart
ChatBotUIConfig(
  theme: ChatBotTheme.modern,     // Default blue theme
  theme: ChatBotTheme.minimal,    // Clean grayscale
  theme: ChatBotTheme.colorful,   // Vibrant colors
  theme: ChatBotTheme.dark,       // Dark mode
  theme: ChatBotTheme.glassmorphism, // Translucent glass effect
  theme: ChatBotTheme.neon,       // Cyberpunk neon style
)
```

### Bubble Styles

Customize message bubble appearance:

```dart
ChatBotUIConfig(
  bubbleStyle: BubbleStyle.rounded,  // Default rounded corners
  bubbleStyle: BubbleStyle.sharp,    // Sharp corners
  bubbleStyle: BubbleStyle.balloon,  // Chat balloon with tail
  bubbleStyle: BubbleStyle.minimal,  // Simple style
  bubbleStyle: BubbleStyle.gradient, // Gradient background
  bubbleStyle: BubbleStyle.neon,     // Neon glow effect
)
```

### Complete UI Configuration

```dart
ChatBotUIConfig(
  theme: ChatBotTheme.modern,
  bubbleStyle: BubbleStyle.rounded,
  
  // Custom colors
  primaryColor: Colors.blue,
  secondaryColor: Colors.grey,
  userBubbleColor: Colors.blue,
  botBubbleColor: Colors.grey.shade200,
  backgroundColor: Colors.white,
  
  // Typography
  userTextStyle: TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  ),
  botTextStyle: TextStyle(
    color: Colors.black87,
    fontSize: 16,
  ),
  
  // Layout
  messagePadding: EdgeInsets.all(12),
  borderRadius: 20.0,
  bubbleElevation: 2.0,
  
  // Features
  showTimestamp: true,
  showAvatar: true,
  userAvatar: CircleAvatar(child: Icon(Icons.person)),
  botAvatar: CircleAvatar(child: Icon(Icons.smart_toy)),
  
  // Typing indicator configuration
  typingIndicatorConfig: TypingIndicatorConfig(
    modernLottieAsset: 'assets/lottie/typing_modern.json',
    minimalLottieAsset: 'assets/lottie/typing_minimal.json',
    colorfulLottieAsset: 'assets/lottie/typing_colorful.json',
    darkLottieAsset: 'assets/lottie/typing_dark.json',
    glassmorphismLottieAsset: 'assets/lottie/typing_glass.json',
    neonLottieAsset: 'assets/lottie/typing_neon.json',
    width: 60,
    height: 40,
    showDefaultDots: true, // Fallback to animated dots if no Lottie
  ),
)
```

## Typing Indicators

### Lottie Animations

Add Lottie files to your `assets` folder and configure them:

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/lottie/
```

```dart
TypingIndicatorConfig(
  // Theme-specific Lottie animations
  modernLottieAsset: 'assets/lottie/typing_modern.json',
  darkLottieAsset: 'assets/lottie/typing_dark.json',
  neonLottieAsset: 'assets/lottie/typing_neon.json',
  
  // Animation settings
  width: 60,
  height: 40,
  animationDuration: Duration(milliseconds: 1500),
  
  // Fallback to default dots if no Lottie provided
  showDefaultDots: true,
)
```

### Custom Typing Widget

```dart
TypingIndicatorConfig(
  customTypingWidget: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.more_horiz, color: Colors.grey),
      SizedBox(width: 8),
      Text('Bot is typing...', style: TextStyle(color: Colors.grey)),
    ],
  ),
)
```

## App Bar Customization

```dart
ChatBotAppBarConfig(
  title: 'Customer Support',
  backgroundColor: Colors.blue,
  foregroundColor: Colors.white,
  centerTitle: true,
  elevation: 4.0,
  actions: [
    IconButton(
      icon: Icon(Icons.info),
      onPressed: () => showInfoDialog(),
    ),
  ],
)
```

## Input Field Customization

```dart
ChatInputConfig(
  hintText: 'Ask me anything...',
  backgroundColor: Colors.grey.shade100,
  borderColor: Colors.transparent,
  focusedBorderColor: Colors.blue,
  borderRadius: 25.0,
  maxLines: 3,
  
  // Custom send button
  sendIcon: Icon(Icons.arrow_upward, color: Colors.white),
  sendButtonColor: Colors.blue,
  
  // Additional icons
  prefixIcon: Icon(Icons.attach_file),
  suffixIcon: Icon(Icons.mic),
)
```

## Error Handling

```dart
ErrorMessagesConfig(
  unknownError: 'Oops! Something went wrong.',
  networkError: 'Check your internet connection.',
  timeoutError: 'Request timed out. Please try again.',
  statusCodeMessages: {
    401: 'Authentication failed.',
    403: 'Access denied.',
    404: 'Service not found.',
    429: 'Too many requests. Please slow down.',
    500: 'Server error. Please try again later.',
  },
)
```

## Event Callbacks

```dart
ChatBotScreen(
  // ... other configurations
  
  onMessageSent: (message) {
    print('User sent: ${message.content}');
    // Track user interactions
  },
  
  onMessageReceived: (message) {
    print('Bot replied: ${message.content}');
    // Process bot responses
  },
  
  onError: (error) {
    print('Chat error: $error');
    // Log errors or show notifications
  },
  
  onClose: () {
    print('Chat closed');
    // Save conversation state
  },
)
```

## Complete Example

```dart
import 'package:flutter/material.dart';

class ChatExampleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChatBotScreen(
      // API Configuration
      apiConfig: ChatBotApiConfig(
        initialGetUrl: 'https://api.mybot.com/conversations/123/messages',
        sendMessageUrl: 'https://api.mybot.com/conversations/123/send',
        headers: {
          'Authorization': 'Bearer your-api-token',
          'Content-Type': 'application/json',
        },
        sendMessageBodyBuilder: (message) => jsonEncode({
          'message': message,
          'user_id': 'user123',
          'conversation_id': '123',
        }),
        responseParser: (response) => ChatMessage(
          id: response['id'],
          content: response['message'],
          type: MessageType.bot,
          timestamp: DateTime.fromMillisecondsSinceEpoch(response['timestamp']),
        ),
        initialMessagesParser: (response) => (response['messages'] as List)
            .map((msg) => ChatMessage.fromJson(msg))
            .toList(),
      ),
      
      // Error Configuration
      errorConfig: ErrorMessagesConfig(
        unknownError: 'Sorry, I encountered an error. Please try again.',
        networkError: 'No internet connection. Please check and retry.',
        statusCodeMessages: {
          429: 'Slow down! You\'re sending messages too quickly.',
          500: 'Our servers are having trouble. Please try again later.',
        },
      ),
      
      // UI Configuration
      uiConfig: ChatBotUIConfig(
        theme: ChatBotTheme.modern,
        bubbleStyle: BubbleStyle.rounded,
        primaryColor: Color(0xFF6366F1),
        showTimestamp: true,
        showAvatar: true,
        typingIndicatorConfig: TypingIndicatorConfig(
          modernLottieAsset: 'assets/lottie/typing_dots.json',
          width: 50,
          height: 30,
        ),
      ),
      
      // App Bar
      appBarConfig: ChatBotAppBarConfig(
        title: 'AI Assistant',
        backgroundColor: Color(0xFF6366F1),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // Refresh conversation
            },
          ),
        ],
      ),
      
      // Input Field
      inputConfig: ChatInputConfig(
        hintText: 'Type your message here...',
        borderRadius: 25.0,
        maxLines: 4,
      ),
      
      // Event Callbacks
      onMessageSent: (message) {
        // Analytics tracking
        print('Message sent: ${message.content}');
      },
      
      onMessageReceived: (message) {
        // Process bot response
        print('Bot response: ${message.content}');
      },
      
      onError: (error) {
        // Error logging
        print('Chat error: $error');
      },
      
      // Additional Settings
      requestTimeout: Duration(seconds: 30),
      autoScroll: true,
      showLoadingIndicator: true,
    );
  }
}
```

## Lottie Animation Guidelines

### Recommended Lottie Specifications

- **Duration**: 1-3 seconds
- **Size**: Under 50KB for optimal performance
- **Dimensions**: 60x40 pixels (configurable)
- **Loop**: Yes
- **Colors**: Match your theme colors

### Sample Lottie Assets Structure

```
assets/
  lottie/
    typing_modern.json      # Blue/purple modern dots
    typing_minimal.json     # Gray simple dots
    typing_colorful.json    # Rainbow animated dots
    typing_dark.json        # White dots for dark theme
    typing_glass.json       # Translucent dots
    typing_neon.json        # Glowing neon dots
```

## Performance Tips

1. **Message Limits**: Implement pagination for long conversations
2. **Image Optimization**: Compress Lottie animations
3. **Memory Management**: Clear old messages when list gets too long
4. **Network**: Implement request debouncing for rapid typing
5. **Animations**: Use `dispose()` to clean up animation controllers

## Troubleshooting

### Common Issues

**1. Lottie animations not showing**
- Verify asset paths in `pubspec.yaml`
- Check Lottie file format and size
- Ensure Lottie package is properly installed

**2. API calls failing**
- Check network permissions in `android/app/src/main/AndroidManifest.xml`
- Verify API endpoints and authentication
- Test API responses with provided parsers

**3. UI not updating**
- Ensure `setState()` is called after data changes
- Check if widget is properly mounted before updates
- Verify message list modifications

**4. Scroll issues**
- Check `autoScroll` setting
- Verify `ScrollController` configuration
- Ensure proper list rebuild after new messages

### Debug Mode

Enable debug prints by wrapping API calls:

```dart
// In your API configuration
responseParser: (response) {
  print('API Response: $response'); // Debug line
  return ChatMessage.fromJson(response);
},
```

## Contributing

Found a bug or want to contribute? Please:

1. Check existing issues
2. Create detailed bug reports
3. Submit pull requests with tests
4. Follow the existing code style

## License

This project is licensed under the MIT License - see the LICENSE file for details.