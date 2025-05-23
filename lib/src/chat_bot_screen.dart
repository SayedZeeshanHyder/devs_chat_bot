import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

/// Represents a single chat message in the conversation
/// Contains all necessary information about a message including content, type, and metadata
class ChatMessage {
  /// Unique identifier for the message
  final String id;

  /// The actual text content of the message
  final String content;

  /// Type of message (user, bot, system, or typing indicator)
  final MessageType type;

  /// When the message was created
  final DateTime timestamp;

  /// Current delivery status of the message
  final MessageStatus status;

  /// Additional data that can be attached to the message
  final Map<String, dynamic>? metadata;

  /// Creates a new ChatMessage instance
  /// [id] and [content] are required, other parameters have defaults
  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.status = MessageStatus.sent, // Default to sent status
    this.metadata,
  });

  /// Factory constructor to create ChatMessage from JSON response
  /// Handles different API response formats by checking multiple possible field names
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      // Use provided id or generate one from current timestamp
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),

      // Check multiple possible field names for message content
      content: json['content'] ?? json['message'] ?? '',

      // Determine message type based on sender information
      type: json['type'] == 'bot' || json['sender'] == 'bot'
          ? MessageType.bot
          : MessageType.user,

      // Parse timestamp or use current time as fallback
      timestamp: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'])
          : DateTime.now(),

      status: MessageStatus.sent, // Always set to sent for received messages
      metadata: json['metadata'], // Pass through any additional metadata
    );
  }
}

/// Enum defining the different types of messages in the chat
enum MessageType {
  user, // Message from the user
  bot, // Response from the chatbot
  system, // System/error messages
  typing // Typing indicator placeholder
}

/// Enum defining the possible states of message delivery
enum MessageStatus {
  sending, // Message is currently being sent
  sent, // Message has been sent successfully
  delivered, // Message has been delivered (if supported by API)
  failed // Message failed to send
}

/// Configuration class for API endpoints and request handling
/// Defines how to communicate with the chatbot API
class ChatBotApiConfig {
  /// URL to fetch initial conversation history or welcome messages
  final String initialGetUrl;

  /// URL to send new messages to the chatbot
  final String sendMessageUrl;

  /// HTTP headers to include with all requests (authentication, content-type, etc.)
  final Map<String, String>? headers;

  /// Request body for the initial GET request (if needed)
  final Map<String, dynamic>? initialGetBody;

  /// Function to build the request body when sending a message
  /// Takes the user's message and returns the formatted request body
  final String Function(String message)? sendMessageBodyBuilder;

  /// Function to parse the API response and extract the bot's reply
  final ChatMessage Function(Map<String, dynamic> response) responseParser;

  /// Function to parse initial messages from the welcome/history API call
  final List<ChatMessage> Function(Map<String, dynamic> response)
      initialMessagesParser;

  /// Creates a new API configuration
  /// [responseParser] and [initialMessagesParser] are required for handling API responses
  ChatBotApiConfig({
    required this.initialGetUrl,
    required this.sendMessageUrl,
    this.headers,
    this.initialGetBody,
    this.sendMessageBodyBuilder,
    required this.responseParser,
    required this.initialMessagesParser,
  });
}

/// Configuration for error messages displayed to users
/// Allows customization of error messages for different scenarios
class ErrorMessagesConfig {
  /// Default error message when the specific error is unknown
  final String unknownError;

  /// Map of HTTP status codes to specific error messages
  final Map<int, String>? statusCodeMessages;

  /// Error message for network connectivity issues
  final String networkError;

  /// Error message for request timeouts
  final String timeoutError;

  /// Creates error message configuration with sensible defaults
  ErrorMessagesConfig({
    this.unknownError = 'Something went wrong. Please try again.',
    this.statusCodeMessages,
    this.networkError = 'Network error. Please check your connection.',
    this.timeoutError = 'Request timeout. Please try again.',
  });

  /// Returns appropriate error message based on HTTP status code
  /// Falls back to generic messages if specific code isn't mapped
  String getErrorMessage(int? statusCode) {
    // If no status code, assume network error
    if (statusCode == null) return networkError;

    // Return specific message for status code or fall back to unknown error
    return statusCodeMessages?[statusCode] ?? unknownError;
  }
}

/// Enum defining available visual themes for the chat interface
enum ChatBotTheme {
  modern, // Clean, contemporary design
  minimal, // Simple, clean interface
  colorful, // Vibrant colors
  dark, // Dark mode theme
  glassmorphism, // Translucent, glass-like effects
  neon // Bright, neon-style theme
}

/// Enum defining different styles for message bubbles
enum BubbleStyle {
  rounded, // Fully rounded corners
  sharp, // Sharp, square corners
  balloon, // Speech balloon style with pointer
  minimal, // Simple, clean bubbles
  gradient, // Gradient-colored bubbles
  neon // Neon-style with glowing effects
}

/// Configuration for the typing indicator animation
/// Supports custom Lottie animations for different themes
class TypingIndicatorConfig {
  /// Lottie animation asset paths for each theme
  final String? modernLottieAsset;
  final String? minimalLottieAsset;
  final String? colorfulLottieAsset;
  final String? darkLottieAsset;
  final String? glassmorphismLottieAsset;
  final String? neonLottieAsset;

  /// Custom widget to use instead of default typing indicator
  final Widget? customTypingWidget;

  /// Duration of the typing animation cycle
  final Duration animationDuration;

  /// Dimensions of the typing indicator
  final double? width;
  final double? height;

  /// Whether to show default animated dots if no custom animation is provided
  final bool showDefaultDots;

  /// Creates typing indicator configuration with sensible defaults
  TypingIndicatorConfig({
    this.modernLottieAsset,
    this.minimalLottieAsset,
    this.colorfulLottieAsset,
    this.darkLottieAsset,
    this.glassmorphismLottieAsset,
    this.neonLottieAsset,
    this.customTypingWidget,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.width = 60,
    this.height = 40,
    this.showDefaultDots = true,
  });

  /// Returns the appropriate Lottie asset path for the given theme
  /// Returns null if no asset is configured for the theme
  String? getLottieAssetForTheme(ChatBotTheme theme) {
    switch (theme) {
      case ChatBotTheme.modern:
        return modernLottieAsset;
      case ChatBotTheme.minimal:
        return minimalLottieAsset;
      case ChatBotTheme.colorful:
        return colorfulLottieAsset;
      case ChatBotTheme.dark:
        return darkLottieAsset;
      case ChatBotTheme.glassmorphism:
        return glassmorphismLottieAsset;
      case ChatBotTheme.neon:
        return neonLottieAsset;
    }
  }
}

/// Comprehensive UI configuration for customizing the chat interface appearance
/// Allows fine-grained control over colors, styles, and visual elements
class ChatBotUIConfig {
  /// Overall theme that affects default colors and styles
  final ChatBotTheme theme;

  /// Style of message bubbles
  final BubbleStyle bubbleStyle;

  /// Primary color used for user elements and accents
  final Color? primaryColor;

  /// Secondary color used for bot elements
  final Color? secondaryColor;

  /// Specific color for user message bubbles
  final Color? userBubbleColor;

  /// Specific color for bot message bubbles
  final Color? botBubbleColor;

  /// Background color of the entire chat screen
  final Color? backgroundColor;

  /// Text style for user messages
  final TextStyle? userTextStyle;

  /// Text style for bot messages
  final TextStyle? botTextStyle;

  /// Padding inside message bubbles
  final EdgeInsets? messagePadding;

  /// Border radius for message bubbles
  final double? borderRadius;

  /// Whether to show timestamps on messages
  final bool showTimestamp;

  /// Whether to show avatar icons next to messages
  final bool showAvatar;

  /// Custom avatar widget for user messages
  final Widget? userAvatar;

  /// Custom avatar widget for bot messages
  final Widget? botAvatar;

  /// Elevation/shadow height for message bubbles
  final double? bubbleElevation;

  /// Custom shadow configuration for message bubbles
  final List<BoxShadow>? bubbleShadow;

  /// Configuration for typing indicator animation
  final TypingIndicatorConfig? typingIndicatorConfig;

  /// Creates UI configuration with sensible defaults
  ChatBotUIConfig({
    this.theme = ChatBotTheme.modern,
    this.bubbleStyle = BubbleStyle.rounded,
    this.primaryColor,
    this.secondaryColor,
    this.userBubbleColor,
    this.botBubbleColor,
    this.backgroundColor,
    this.userTextStyle,
    this.botTextStyle,
    this.messagePadding,
    this.borderRadius,
    this.showTimestamp = false,
    this.showAvatar = false,
    this.userAvatar,
    this.botAvatar,
    this.bubbleElevation,
    this.bubbleShadow,
    this.typingIndicatorConfig,
  });
}

/// Configuration for the app bar at the top of the chat screen
/// Provides full customization of the AppBar widget
class ChatBotAppBarConfig {
  /// Simple string title for the app bar
  final String? title;

  /// Custom widget to use as the title (overrides string title)
  final Widget? titleWidget;

  /// Action buttons to display on the right side of the app bar
  final List<Widget>? actions;

  /// Background color of the app bar
  final Color? backgroundColor;

  /// Color of text and icons in the app bar
  final Color? foregroundColor;

  /// Shadow elevation of the app bar
  final double? elevation;

  /// Whether to center the title
  final bool centerTitle;

  /// Custom leading widget (usually back button)
  final Widget? leading;

  /// Widget to display below the app bar (like tabs)
  final PreferredSizeWidget? bottom;

  /// Custom shape for the app bar
  final ShapeBorder? shape;

  /// Whether to automatically add a back button
  final bool automaticallyImplyLeading;

  /// Creates app bar configuration with defaults
  ChatBotAppBarConfig({
    this.title,
    this.titleWidget,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle = true,
    this.leading,
    this.bottom,
    this.shape,
    this.automaticallyImplyLeading = true,
  });
}

/// Configuration for the message input field at the bottom of the screen
/// Allows customization of the text input area and send button
class ChatInputConfig {
  /// Placeholder text shown in the input field
  final String? hintText;

  /// Background color of the input field
  final Color? backgroundColor;

  /// Border color of the input field
  final Color? borderColor;

  /// Border color when input field is focused
  final Color? focusedBorderColor;

  /// Border radius of the input field
  final double? borderRadius;

  /// Internal padding of the input field
  final EdgeInsets? padding;

  /// Text style for user input
  final TextStyle? textStyle;

  /// Text style for placeholder text
  final TextStyle? hintStyle;

  /// Custom icon for the send button
  final Widget? sendIcon;

  /// Background color of the send button
  final Color? sendButtonColor;

  /// Maximum number of lines for input text
  final int? maxLines;

  /// Whether the input field is enabled
  final bool enabled;

  /// Icon to show at the beginning of the input field
  final Widget? prefixIcon;

  /// Icon to show at the end of the input field
  final Widget? suffixIcon;

  /// Shadow elevation for the input field
  final double? elevation;

  /// Custom shadow configuration
  final List<BoxShadow>? shadow;

  /// Creates input configuration with sensible defaults
  ChatInputConfig({
    this.hintText = 'Type a message...',
    this.backgroundColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.hintStyle,
    this.sendIcon,
    this.sendButtonColor,
    this.maxLines = 1,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.elevation,
    this.shadow,
  });
}

/// Main ChatBot widget that provides a complete chat interface
/// This is the primary widget that developers will use in their apps
class ChatBotScreen extends StatefulWidget {
  /// API configuration for communicating with the chatbot service
  final ChatBotApiConfig apiConfig;

  /// Configuration for error messages shown to users
  final ErrorMessagesConfig errorConfig;

  /// UI customization options
  final ChatBotUIConfig? uiConfig;

  /// App bar customization options
  final ChatBotAppBarConfig? appBarConfig;

  /// Input field customization options
  final ChatInputConfig? inputConfig;

  /// Callback fired when the chat is closed
  final VoidCallback? onClose;

  /// Callback fired when a message is sent by the user
  final Function(ChatMessage message)? onMessageSent;

  /// Callback fired when a message is received from the bot
  final Function(ChatMessage message)? onMessageReceived;

  /// Callback fired when an error occurs
  final Function(String error)? onError;

  /// Timeout duration for API requests
  final Duration? requestTimeout;

  /// Whether to show loading indicator during initial load
  final bool showLoadingIndicator;

  /// Custom loading widget to display during initial load
  final Widget? loadingWidget;

  /// Custom widget to display when there are no messages
  final Widget? emptyStateWidget;

  /// Custom scroll controller for the message list
  final ScrollController? scrollController;

  /// Whether to automatically scroll to bottom when new messages arrive
  final bool autoScroll;

  /// Padding around the entire chat interface
  final EdgeInsets? padding;

  /// Whether to display messages in reverse order (newest first)
  final bool reverseMessageOrder;

  /// Creates a new ChatBotScreen widget
  /// [apiConfig] and [errorConfig] are required for basic functionality
  const ChatBotScreen({
    super.key,
    required this.apiConfig,
    required this.errorConfig,
    this.uiConfig,
    this.appBarConfig,
    this.inputConfig,
    this.onClose,
    this.onMessageSent,
    this.onMessageReceived,
    this.onError,
    this.requestTimeout = const Duration(seconds: 30),
    this.showLoadingIndicator = true,
    this.loadingWidget,
    this.emptyStateWidget,
    this.scrollController,
    this.autoScroll = true,
    this.padding,
    this.reverseMessageOrder = false,
  });

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

/// Private state class for ChatBotScreen
/// Manages the chat interface state, message handling, and animations
class _ChatBotScreenState extends State<ChatBotScreen>
    with TickerProviderStateMixin {
  /// Controller for the message input text field
  final TextEditingController _messageController = TextEditingController();

  /// List of all messages in the conversation
  final List<ChatMessage> _messages = [];

  /// Controller for scrolling the message list
  late ScrollController _scrollController;

  /// Whether the initial messages are currently being loaded
  bool _isLoading = false;

  /// Whether a message is currently being sent
  bool _isSending = false;

  /// Animation controller for general UI animations
  late AnimationController _animationController;

  /// Animation controller specifically for the typing indicator
  late AnimationController _typingAnimationController;

  /// Cached UI configuration (with defaults applied)
  late ChatBotUIConfig _uiConfig;

  /// ID of the current typing indicator message (null if not showing)
  String? _typingMessageId;

  @override
  void initState() {
    super.initState();

    // Initialize scroll controller (use provided one or create new)
    _scrollController = widget.scrollController ?? ScrollController();

    // Set up animation controllers for smooth UI transitions
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Set up typing indicator animation
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Apply UI configuration with defaults
    _uiConfig = widget.uiConfig ?? ChatBotUIConfig();

    // Load initial messages when the widget is first created
    _loadInitialMessages();
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _messageController.dispose();

    // Only dispose scroll controller if we created it
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }

    // Dispose animation controllers
    _animationController.dispose();
    _typingAnimationController.dispose();

    super.dispose();
  }

  /// Loads initial messages from the API (welcome messages, conversation history, etc.)
  /// Called automatically when the widget is initialized
  Future<void> _loadInitialMessages() async {
    // Don't proceed if widget has been disposed
    if (!mounted) return;

    // Show loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Make GET request to fetch initial messages
      final response = await http
          .get(
            Uri.parse(widget.apiConfig.initialGetUrl),
            headers: widget.apiConfig.headers,
          )
          .timeout(widget.requestTimeout!); // Apply timeout

      // Check if request was successful (2xx status codes)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Parse response body as JSON
        final data = json.decode(response.body);

        // Use configured parser to extract messages
        final messages = widget.apiConfig.initialMessagesParser(data);

        // Update UI if widget is still mounted
        if (mounted) {
          setState(() {
            _messages.clear(); // Clear any existing messages

            // Add messages in specified order
            _messages.addAll(widget.reverseMessageOrder
                ? messages.reversed.toList()
                : messages);

            _isLoading = false; // Hide loading state
          });

          // Scroll to bottom to show latest messages
          _scrollToBottom();
        }
      } else {
        // Handle HTTP error responses
        _handleError(response.statusCode);
      }
    } catch (e) {
      // Handle network errors, timeouts, etc.
      _handleError(null, e.toString());
    }
  }

  /// Shows the typing indicator bubble to indicate bot is responding
  /// Creates a temporary message with typing type
  void _showTypingIndicator() {
    final typingMessage = ChatMessage(
      id: 'typing_${DateTime.now().millisecondsSinceEpoch}',
      content: '', // Empty content for typing indicator
      type: MessageType.typing,
      timestamp: DateTime.now(),
    );

    setState(() {
      _typingMessageId = typingMessage.id; // Track the typing message
      _messages.add(typingMessage); // Add to message list
    });

    // Start the typing animation loop
    _typingAnimationController.repeat();

    // Scroll to show the typing indicator
    _scrollToBottom();
  }

  /// Removes the typing indicator from the message list
  /// Called when bot response is received or on error
  void _hideTypingIndicator() {
    if (_typingMessageId != null) {
      setState(() {
        // Remove the typing message from the list
        _messages.removeWhere((msg) => msg.id == _typingMessageId);
        _typingMessageId = null; // Clear the tracking ID
      });

      // Stop the typing animation
      _typingAnimationController.stop();
    }
  }

  /// Sends a message to the chatbot API
  /// Handles the entire flow: add user message, show typing indicator, send request, handle response
  Future<void> _sendMessage(String content) async {
    // Don't send empty messages or if already sending
    if (content.trim().isEmpty || _isSending) return;

    // Create user message object
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
    );

    // Add user message to UI and update state
    setState(() {
      _messages.add(userMessage);
      _isSending = true; // Prevent multiple simultaneous sends
    });

    // Clear input field and notify listeners
    _messageController.clear();
    widget.onMessageSent?.call(userMessage);
    _scrollToBottom();

    // Show typing indicator while waiting for response
    _showTypingIndicator();

    try {
      // Build request body using configured function or default format
      final body = widget.apiConfig.sendMessageBodyBuilder?.call(content) ??
          json.encode({'message': content});

      // Send POST request to chat API
      final response = await http
          .post(
            Uri.parse(widget.apiConfig.sendMessageUrl),
            headers: {
              'Content-Type': 'application/json',
              ...?widget.apiConfig.headers, // Merge any additional headers
            },
            body: body,
          )
          .timeout(widget.requestTimeout!); // Apply timeout

      // Hide typing indicator now that we have a response
      _hideTypingIndicator();

      // Check if request was successful
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Parse response and extract bot message
        final data = json.decode(response.body);
        final botMessage = widget.apiConfig.responseParser(data);

        // Add bot response to UI if widget still mounted
        if (mounted) {
          setState(() {
            _messages.add(botMessage);
            _isSending = false; // Re-enable sending
          });

          // Notify listeners and scroll to show new message
          widget.onMessageReceived?.call(botMessage);
          _scrollToBottom();
        }
      } else {
        // Handle HTTP error responses
        _handleError(response.statusCode);
      }
    } catch (e) {
      // Handle network errors, timeouts, parsing errors, etc.
      _hideTypingIndicator();
      _handleError(null, e.toString());
    }
  }

  /// Handles errors by showing appropriate error messages to the user
  /// Creates a system message with the error text
  void _handleError(int? statusCode, [String? errorMessage]) {
    // Don't proceed if widget has been disposed
    if (!mounted) return;

    // Get appropriate error message using configured error handler
    final error =
        errorMessage ?? widget.errorConfig.getErrorMessage(statusCode);

    // Add error message to chat and update state
    setState(() {
      _isSending = false; // Re-enable sending after error

      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: error,
        type: MessageType.system, // System message type for errors
        timestamp: DateTime.now(),
        status: MessageStatus.failed, // Mark as failed
      ));
    });

    // Notify error listener and scroll to show error message
    widget.onError?.call(error);
    _scrollToBottom();
  }

  /// Smoothly scrolls the message list to the bottom
  /// Used to show new messages and maintain conversation flow
  void _scrollToBottom() {
    // Only scroll if auto-scroll is enabled and scroll controller is ready
    if (widget.autoScroll && _scrollController.hasClients) {
      // Use post-frame callback to ensure layout is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent, // Scroll to very bottom
          duration: const Duration(milliseconds: 300), // Smooth animation
          curve: Curves.easeOut, // Natural easing curve
        );
      });
    }
  }

  /// Gets the appropriate color for the current theme
  /// Falls back to theme defaults if custom color isn't provided
  Color _getThemeColor(Color? customColor, Color defaultColor) {
    return customColor ?? _getThemeColors()[defaultColor] ?? defaultColor;
  }

  /// Returns a color mapping for the current theme
  /// Each theme has its own color palette for consistent styling
  Map<Color, Color> _getThemeColors() {
    switch (_uiConfig.theme) {
      case ChatBotTheme.modern:
        // Clean, professional colors
        return {
          Colors.blue: const Color(0xFF6366F1), // Modern purple-blue
          Colors.grey: const Color(0xFFF3F4F6), // Light grey background
          Colors.white: Colors.white, // Pure white
        };
      case ChatBotTheme.minimal:
        // Subdued, minimal colors
        return {
          Colors.blue: const Color(0xFF374151), // Dark grey for contrast
          Colors.grey: const Color(0xFFF9FAFB), // Very light grey
          Colors.white: Colors.white, // Pure white
        };
      case ChatBotTheme.colorful:
        // Vibrant, playful colors
        return {
          Colors.blue: const Color(0xFF8B5CF6), // Bright purple
          Colors.grey: const Color(0xFFFEF3C7), // Warm yellow background
          Colors.white: const Color(0xFFFFFBEB), // Cream white
        };
      case ChatBotTheme.dark:
        // Dark mode colors
        return {
          Colors.blue: const Color(0xFF3B82F6), // Bright blue for contrast
          Colors.grey: const Color(0xFF374151), // Dark grey
          Colors.white: const Color(0xFF1F2937), // Very dark grey (not black)
        };
      case ChatBotTheme.glassmorphism:
        // Translucent, glass-like colors
        return {
          Colors.blue: const Color(0xFF6366F1)
              .withValues(alpha: 0.8), // Semi-transparent blue
          Colors.grey:
              Colors.white.withValues(alpha: 0.1), // Very transparent white
          Colors.white:
              Colors.white.withValues(alpha: 0.05), // Almost transparent white
        };
      case ChatBotTheme.neon:
        // Bright, cyberpunk-style colors
        return {
          Colors.blue: const Color(0xFF00D9FF), // Bright cyan
          Colors.grey: const Color(0xFF1A1A2E), // Dark purple-grey
          Colors.white: const Color(0xFF16213E), // Dark blue-grey
        };
    }
  }

  /// Builds the typing indicator widget with theme-appropriate animation
  /// Can use Lottie animations or fall back to default animated dots
  Widget _buildTypingIndicator() {
    final config = _uiConfig.typingIndicatorConfig ?? TypingIndicatorConfig();
    final lottieAsset = config.getLottieAssetForTheme(_uiConfig.theme);

    // Use custom widget if provided
    if (config.customTypingWidget != null) {
      return config.customTypingWidget!;
    }

    // Use Lottie animation if available for current theme
    if (lottieAsset != null) {
      return SizedBox(
        width: config.width,
        height: config.height,
        child: Lottie.asset(
          lottieAsset,
          controller: _typingAnimationController,
          repeat: true, // Loop the animation
          reverse: false, // Don't reverse the animation
          animate: true, // Start animating immediately
        ),
      );
    }

    // Fall back to default animated dots if enabled
    if (config.showDefaultDots) {
      return AnimatedBuilder(
        animation: _typingAnimationController,
        builder: (context, child) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              // Create staggered animation for each dot
              final delay = index * 0.2;
              final animValue =
                  (_typingAnimationController.value + delay) % 1.0;

              // Calculate scale using sine wave for smooth bounce effect
              final scale =
                  0.5 + (0.5 * (1 + math.sin(animValue * 2 * math.pi)) / 2);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade500,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      );
    }

    // Return empty widget if no typing indicator should be shown
    return const SizedBox.shrink();
  }

  /// Builds the chat message bubble widget with appropriate styles and layout
  Widget _buildMessageBubble(ChatMessage message) {
    // Determine the message sender type
    final isUser = message.type == MessageType.user;
    final isSystem = message.type == MessageType.system;
    final isTyping = message.type == MessageType.typing;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Display bot avatar if applicable
          if (!isUser && !isSystem && _uiConfig.showAvatar)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _uiConfig.botAvatar ??
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: _getThemeColor(
                        _uiConfig.secondaryColor, Colors.grey.shade300),
                    child: Icon(
                      Icons.smart_toy,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
            ),
          // Render the message bubble content or typing indicator
          Flexible(
            child: Container(
              margin: EdgeInsets.only(
                left: isUser ? 50 : 0,
                right: isUser ? 0 : 50,
              ),
              child: isTyping
                  ? _buildTypingBubble()
                  : _buildBubbleContent(message),
            ),
          ),
          // Display user avatar if applicable
          if (isUser && _uiConfig.showAvatar)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _uiConfig.userAvatar ??
                  CircleAvatar(
                    radius: 16,
                    backgroundColor:
                        _getThemeColor(_uiConfig.primaryColor, Colors.blue),
                    child: Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
            ),
        ],
      ),
    );
  }

  /// Constructs a typing indicator bubble
  Widget _buildTypingBubble() {
    final bubbleColor = _getThemeColor(
      _uiConfig.botBubbleColor,
      _getThemeColors()[Colors.grey] ?? Colors.grey.shade200,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _buildBubbleDecoration(bubbleColor, false),
      child: _buildTypingIndicator(),
    );
  }

  /// Builds the main content for a message bubble
  Widget _buildBubbleContent(ChatMessage message) {
    final isUser = message.type == MessageType.user;
    final isSystem = message.type == MessageType.system;

    // Select bubble color based on message type
    Color bubbleColor;
    if (isSystem) {
      bubbleColor = Colors.red.shade100;
    } else if (isUser) {
      bubbleColor = _getThemeColor(
        _uiConfig.userBubbleColor,
        _getThemeColors()[Colors.blue] ?? Colors.blue,
      );
    } else {
      bubbleColor = _getThemeColor(
        _uiConfig.botBubbleColor,
        _getThemeColors()[Colors.grey] ?? Colors.grey.shade200,
      );
    }

    return Container(
      padding: _uiConfig.messagePadding ?? const EdgeInsets.all(12),
      decoration: _buildBubbleDecoration(bubbleColor, isUser),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display message content text
          Text(
            message.content,
            style: isUser
                ? (_uiConfig.userTextStyle ??
                    TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ))
                : (_uiConfig.botTextStyle ??
                    TextStyle(
                      color: isSystem ? Colors.red.shade700 : Colors.black87,
                      fontSize: 16,
                    )),
          ),
          // Optionally display timestamp
          if (_uiConfig.showTimestamp)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _formatTime(message.timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: isUser ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the decoration (e.g., color, border radius) for a message bubble
  BoxDecoration _buildBubbleDecoration(Color color, bool isUser) {
    final borderRadius = _uiConfig.borderRadius ?? 20.0;

    // Define bubble border radius based on style
    BorderRadius bubbleBorderRadius;
    switch (_uiConfig.bubbleStyle) {
      case BubbleStyle.rounded:
        bubbleBorderRadius = BorderRadius.circular(borderRadius);
        break;
      case BubbleStyle.sharp:
        bubbleBorderRadius = BorderRadius.circular(4);
        break;
      case BubbleStyle.balloon:
        bubbleBorderRadius = BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
          bottomLeft: Radius.circular(isUser ? borderRadius : 4),
          bottomRight: Radius.circular(isUser ? 4 : borderRadius),
        );
        break;
      case BubbleStyle.minimal:
        bubbleBorderRadius = BorderRadius.circular(8);
        break;
      case BubbleStyle.gradient:
      case BubbleStyle.neon:
        bubbleBorderRadius = BorderRadius.circular(borderRadius);
        break;
    }

    // Gradient style bubble decoration
    if (_uiConfig.bubbleStyle == BubbleStyle.gradient) {
      return BoxDecoration(
        gradient: LinearGradient(
          colors: isUser
              ? [color, color.withValues(alpha: 0.8)]
              : [color, color.withValues(alpha: 0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: bubbleBorderRadius,
        boxShadow: [
          BoxShadow(
            color: (isUser ? const Color(0xFF00D9FF) : const Color(0xFF00FFB7))
                .withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      );
    }

    // Neon style bubble decoration
    if (_uiConfig.bubbleStyle == BubbleStyle.neon) {
      return BoxDecoration(
        color: color,
        borderRadius: bubbleBorderRadius,
        border: Border.all(
          color: isUser ? const Color(0xFF00D9FF) : const Color(0xFF00FFB7),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isUser ? const Color(0xFF00D9FF) : const Color(0xFF00FFB7))
                .withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      );
    }

    // Default bubble decoration
    return BoxDecoration(
      color: color,
      borderRadius: bubbleBorderRadius,
      boxShadow: _uiConfig.bubbleShadow ??
          [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: _uiConfig.bubbleElevation! * 2,
              offset: Offset(0, _uiConfig.bubbleElevation!),
            ),
          ],
    );
  }

  /// Formats a DateTime object to a readable string (HH:mm)
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Builds the main widget tree of the chat interface
  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getThemeColor(
      _uiConfig.backgroundColor,
      _getThemeColors()[Colors.white] ?? Colors.white,
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: Container(
        padding: widget.padding,
        child: Column(
          children: [
            // Displays messages or empty/loading states
            Expanded(
              child: _isLoading
                  ? Center(
                      child: widget.loadingWidget ??
                          CircularProgressIndicator(
                            color: _getThemeColor(
                                _uiConfig.primaryColor, Colors.blue),
                          ),
                    )
                  : _messages.isEmpty
                      ? Center(
                          child: widget.emptyStateWidget ??
                              Text(
                                'Start a conversation!',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          reverse: widget.reverseMessageOrder,
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            return _buildMessageBubble(_messages[index]);
                          },
                        ),
            ),
            _buildInputArea(), // Input text field and send button
          ],
        ),
      ),
    );
  }

  /// Optionally builds a custom AppBar if provided in the configuration
  PreferredSizeWidget? _buildAppBar() {
    if (widget.appBarConfig == null) return null;

    final config = widget.appBarConfig!;

    return AppBar(
      title: config.titleWidget ??
          (config.title != null ? Text(config.title!) : null),
      actions: config.actions,
      backgroundColor: config.backgroundColor ??
          _getThemeColor(_uiConfig.primaryColor, Colors.blue),
      foregroundColor: config.foregroundColor,
      elevation: config.elevation,
      centerTitle: config.centerTitle,
      leading: config.leading,
      bottom: config.bottom,
      shape: config.shape,
      automaticallyImplyLeading: config.automaticallyImplyLeading,
    );
  }

  /// Builds the message input area including the text field and send button
  Widget _buildInputArea() {
    final config = widget.inputConfig ?? ChatInputConfig();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: config.backgroundColor ??
            _getThemeColor(_uiConfig.backgroundColor, Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Optional prefix icon
          if (config.prefixIcon != null) ...[
            config.prefixIcon!,
            const SizedBox(width: 8),
          ],
          // Text input field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: config.backgroundColor ?? Colors.grey.shade100,
                borderRadius: BorderRadius.circular(config.borderRadius ?? 25),
                border: Border.all(
                  color: config.borderColor ?? Colors.transparent,
                ),
                boxShadow: config.elevation != null
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: config.elevation! * 2,
                          offset: Offset(0, config.elevation!),
                        ),
                      ]
                    : null,
              ),
              child: TextField(
                controller: _messageController,
                enabled: config.enabled && !_isSending,
                maxLines: config.maxLines,
                style: config.textStyle,
                decoration: InputDecoration(
                  hintText: config.hintText,
                  hintStyle: config.hintStyle,
                  border: InputBorder.none,
                  contentPadding: config.padding ??
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  suffixIcon: config.suffixIcon,
                ),
                onSubmitted: _isSending
                    ? null
                    : (value) {
                        _sendMessage(value);
                      },
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Send button or loading indicator
          Container(
            decoration: BoxDecoration(
              color: config.sendButtonColor ??
                  _getThemeColor(_uiConfig.primaryColor, Colors.blue),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (config.sendButtonColor ??
                          _getThemeColor(_uiConfig.primaryColor, Colors.blue))
                      .withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _isSending
                  ? null
                  : () {
                      _sendMessage(_messageController.text);
                    },
              icon: _isSending
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : (config.sendIcon ??
                      const Icon(Icons.send, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
