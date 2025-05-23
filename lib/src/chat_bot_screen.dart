import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

// Message Model
class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final MessageStatus status;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.metadata,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: json['content'] ?? json['message'] ?? '',
      type: json['type'] == 'bot' || json['sender'] == 'bot'
          ? MessageType.bot
          : MessageType.user,
      timestamp: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'])
          : DateTime.now(),
      status: MessageStatus.sent,
      metadata: json['metadata'],
    );
  }
}

enum MessageType { user, bot, system, typing }

enum MessageStatus { sending, sent, delivered, failed }

// API Configuration
class ChatBotApiConfig {
  final String initialGetUrl;
  final String sendMessageUrl;
  final Map<String, String>? headers;
  final Map<String, dynamic>? initialGetBody;
  final String Function(String message)? sendMessageBodyBuilder;
  final ChatMessage Function(Map<String, dynamic> response) responseParser;
  final List<ChatMessage> Function(Map<String, dynamic> response)
      initialMessagesParser;

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

class ErrorMessagesConfig {
  final String unknownError;
  final Map<int, String>? statusCodeMessages;
  final String networkError;
  final String timeoutError;

  ErrorMessagesConfig({
    this.unknownError = 'Something went wrong. Please try again.',
    this.statusCodeMessages,
    this.networkError = 'Network error. Please check your connection.',
    this.timeoutError = 'Request timeout. Please try again.',
  });

  String getErrorMessage(int? statusCode) {
    if (statusCode == null) return networkError;
    return statusCodeMessages?[statusCode] ?? unknownError;
  }
}

// UI Theme Enums
enum ChatBotTheme { modern, minimal, colorful, dark, glassmorphism, neon }

enum BubbleStyle { rounded, sharp, balloon, minimal, gradient, neon }

// Typing Indicator Configuration
class TypingIndicatorConfig {
  final String? modernLottieAsset;
  final String? minimalLottieAsset;
  final String? colorfulLottieAsset;
  final String? darkLottieAsset;
  final String? glassmorphismLottieAsset;
  final String? neonLottieAsset;
  final Widget? customTypingWidget;
  final Duration animationDuration;
  final double? width;
  final double? height;
  final bool showDefaultDots;

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

// UI Customization
class ChatBotUIConfig {
  final ChatBotTheme theme;
  final BubbleStyle bubbleStyle;
  final Color? primaryColor;
  final Color? secondaryColor;
  final Color? userBubbleColor;
  final Color? botBubbleColor;
  final Color? backgroundColor;
  final TextStyle? userTextStyle;
  final TextStyle? botTextStyle;
  final EdgeInsets? messagePadding;
  final double? borderRadius;
  final bool showTimestamp;
  final bool showAvatar;
  final Widget? userAvatar;
  final Widget? botAvatar;
  final double? bubbleElevation;
  final List<BoxShadow>? bubbleShadow;
  final TypingIndicatorConfig? typingIndicatorConfig;

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

// App Bar Configuration
class ChatBotAppBarConfig {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool centerTitle;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final ShapeBorder? shape;
  final bool automaticallyImplyLeading;

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

// Input Field Configuration
class ChatInputConfig {
  final String? hintText;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final double? borderRadius;
  final EdgeInsets? padding;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final Widget? sendIcon;
  final Color? sendButtonColor;
  final int? maxLines;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double? elevation;
  final List<BoxShadow>? shadow;

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

// Main ChatBot Widget
class ChatBotScreen extends StatefulWidget {
  final ChatBotApiConfig apiConfig;
  final ErrorMessagesConfig errorConfig;
  final ChatBotUIConfig? uiConfig;
  final ChatBotAppBarConfig? appBarConfig;
  final ChatInputConfig? inputConfig;
  final VoidCallback? onClose;
  final Function(ChatMessage message)? onMessageSent;
  final Function(ChatMessage message)? onMessageReceived;
  final Function(String error)? onError;
  final Duration? requestTimeout;
  final bool showLoadingIndicator;
  final Widget? loadingWidget;
  final Widget? emptyStateWidget;
  final ScrollController? scrollController;
  final bool autoScroll;
  final EdgeInsets? padding;
  final bool reverseMessageOrder;

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

class _ChatBotScreenState extends State<ChatBotScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  late ScrollController _scrollController;
  bool _isLoading = false;
  bool _isSending = false;
  late AnimationController _animationController;
  late AnimationController _typingAnimationController;
  late ChatBotUIConfig _uiConfig;
  String? _typingMessageId;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _uiConfig = widget.uiConfig ?? ChatBotUIConfig();
    _loadInitialMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    _animationController.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialMessages() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http
          .get(
            Uri.parse(widget.apiConfig.initialGetUrl),
            headers: widget.apiConfig.headers,
          )
          .timeout(widget.requestTimeout!);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        final messages = widget.apiConfig.initialMessagesParser(data);

        if (mounted) {
          setState(() {
            _messages.clear();
            _messages.addAll(widget.reverseMessageOrder
                ? messages.reversed.toList()
                : messages);
            _isLoading = false;
          });
          _scrollToBottom();
        }
      } else {
        _handleError(response.statusCode);
      }
    } catch (e) {
      _handleError(null, e.toString());
    }
  }

  void _showTypingIndicator() {
    final typingMessage = ChatMessage(
      id: 'typing_${DateTime.now().millisecondsSinceEpoch}',
      content: '',
      type: MessageType.typing,
      timestamp: DateTime.now(),
    );

    setState(() {
      _typingMessageId = typingMessage.id;
      _messages.add(typingMessage);
    });

    _typingAnimationController.repeat();
    _scrollToBottom();
  }

  void _hideTypingIndicator() {
    if (_typingMessageId != null) {
      setState(() {
        _messages.removeWhere((msg) => msg.id == _typingMessageId);
        _typingMessageId = null;
      });
      _typingAnimationController.stop();
    }
  }

  Future<void> _sendMessage(String content) async {
    if (content.trim().isEmpty || _isSending) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isSending = true;
    });

    _messageController.clear();
    widget.onMessageSent?.call(userMessage);
    _scrollToBottom();

    // Show typing indicator
    _showTypingIndicator();

    try {
      final body = widget.apiConfig.sendMessageBodyBuilder?.call(content) ??
          json.encode({'message': content});

      final response = await http
          .post(
            Uri.parse(widget.apiConfig.sendMessageUrl),
            headers: {
              'Content-Type': 'application/json',
              ...?widget.apiConfig.headers,
            },
            body: body,
          )
          .timeout(widget.requestTimeout!);

      // Hide typing indicator
      _hideTypingIndicator();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        final botMessage = widget.apiConfig.responseParser(data);

        if (mounted) {
          setState(() {
            _messages.add(botMessage);
            _isSending = false;
          });
          widget.onMessageReceived?.call(botMessage);
          _scrollToBottom();
        }
      } else {
        _handleError(response.statusCode);
      }
    } catch (e) {
      _hideTypingIndicator();
      _handleError(null, e.toString());
    }
  }

  void _handleError(int? statusCode, [String? errorMessage]) {
    if (!mounted) return;

    final error =
        errorMessage ?? widget.errorConfig.getErrorMessage(statusCode);

    setState(() {
      _isSending = false;
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: error,
        type: MessageType.system,
        timestamp: DateTime.now(),
        status: MessageStatus.failed,
      ));
    });

    widget.onError?.call(error);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (widget.autoScroll && _scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Color _getThemeColor(Color? customColor, Color defaultColor) {
    return customColor ?? _getThemeColors()[defaultColor] ?? defaultColor;
  }

  Map<Color, Color> _getThemeColors() {
    switch (_uiConfig.theme) {
      case ChatBotTheme.modern:
        return {
          Colors.blue: const Color(0xFF6366F1),
          Colors.grey: const Color(0xFFF3F4F6),
          Colors.white: Colors.white,
        };
      case ChatBotTheme.minimal:
        return {
          Colors.blue: const Color(0xFF374151),
          Colors.grey: const Color(0xFFF9FAFB),
          Colors.white: Colors.white,
        };
      case ChatBotTheme.colorful:
        return {
          Colors.blue: const Color(0xFF8B5CF6),
          Colors.grey: const Color(0xFFFEF3C7),
          Colors.white: const Color(0xFFFFFBEB),
        };
      case ChatBotTheme.dark:
        return {
          Colors.blue: const Color(0xFF3B82F6),
          Colors.grey: const Color(0xFF374151),
          Colors.white: const Color(0xFF1F2937),
        };
      case ChatBotTheme.glassmorphism:
        return {
          Colors.blue: const Color(0xFF6366F1).withValues(alpha: 0.8),
          Colors.grey: Colors.white.withValues(alpha: 0.1),
          Colors.white: Colors.white.withValues(alpha: 0.05),
        };
      case ChatBotTheme.neon:
        return {
          Colors.blue: const Color(0xFF00D9FF),
          Colors.grey: const Color(0xFF1A1A2E),
          Colors.white: const Color(0xFF16213E),
        };
    }
  }

  Widget _buildTypingIndicator() {
    final config = _uiConfig.typingIndicatorConfig ?? TypingIndicatorConfig();
    final lottieAsset = config.getLottieAssetForTheme(_uiConfig.theme);

    if (config.customTypingWidget != null) {
      return config.customTypingWidget!;
    }

    if (lottieAsset != null) {
      return SizedBox(
        width: config.width,
        height: config.height,
        child: Lottie.asset(
          lottieAsset,
          controller: _typingAnimationController,
          repeat: true,
          reverse: false,
          animate: true,
        ),
      );
    }

    // Default animated dots
    if (config.showDefaultDots) {
      return AnimatedBuilder(
        animation: _typingAnimationController,
        builder: (context, child) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              final delay = index * 0.2;
              final animValue =
                  (_typingAnimationController.value + delay) % 1.0;
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

    return const SizedBox.shrink();
  }

  Widget _buildMessageBubble(ChatMessage message) {
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

  Widget _buildBubbleContent(ChatMessage message) {
    final isUser = message.type == MessageType.user;
    final isSystem = message.type == MessageType.system;

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

  BoxDecoration _buildBubbleDecoration(Color color, bool isUser) {
    final borderRadius = _uiConfig.borderRadius ?? 20.0;

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
        bubbleBorderRadius = BorderRadius.circular(borderRadius);
        break;
      case BubbleStyle.neon:
        bubbleBorderRadius = BorderRadius.circular(borderRadius);
        break;
    }

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

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

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
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

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
          if (config.prefixIcon != null) ...[
            config.prefixIcon!,
            const SizedBox(width: 8),
          ],
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
