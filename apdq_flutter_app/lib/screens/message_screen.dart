import 'package:apdq_flutter_app/blocs/messages/message_api_service.dart';
import 'package:apdq_flutter_app/blocs/messages/message_bloc.dart';
import 'package:apdq_flutter_app/blocs/messages/message_event.dart';
import 'package:apdq_flutter_app/blocs/messages/message_state.dart';
import 'package:apdq_flutter_app/models/message_models.dart';
import 'package:apdq_flutter_app/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  late Future<String?> _userIdFuture;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _userIdFuture = _storage.read(key: 'user_id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF6F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEBF6F1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const SearchScreen()),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/Logorbsmall.png',
              height: 30,
            ),
          ],
        ),
        actions: const [SizedBox(width: 48)],
      ),
      // Wrap the body in a SafeArea to respect system UI
      body: SafeArea(
        child: Builder(
          builder: (builderContext) {
            final messageApiService =
                Provider.of<MessageApiService>(builderContext);

            return FutureBuilder<String?>(
              future: _userIdFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) {
                  return const Center(child: Text('User ID not found'));
                }

                final userId = int.parse(snapshot.data!);

                return BlocProvider(
                  create: (context) => MessageBloc(
                    apiService: messageApiService,
                    remorqueurId: userId,
                  )..add(LoadMessages()),
                  child: Builder(
                    builder: (blocContext) =>
                        BlocBuilder<MessageBloc, MessageState>(
                      builder: (context, state) {
                        if (state.status == MessageStatus.loading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (state.status == MessageStatus.error) {
                          return Center(
                            child: Text(state.error ?? 'An error occurred'),
                          );
                        }

                        if (state.messages.isEmpty) {
                          return const Center(child: Text('No messages'));
                        }

                        // Wrap ListView in a SizedBox.expand to provide constraints
                        return SizedBox.expand(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.messages.length,
                            itemBuilder: (context, index) {
                              final message = state.messages[index];
                              return MessageCard(message: message);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class MessageCard extends StatelessWidget {
  final GarageMessageResponse message;

  const MessageCard({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    // Get the required services and data from the current context
    final messageApiService = context.read<MessageApiService>();
    final messageBloc = context.read<MessageBloc>();

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 100,
        maxHeight: 200,
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        // Change background color based on read status
        color: message.is_read ? Colors.white : const Color(0xFFE3F2FD),
        child: InkWell(
          onTap: () async {
            // Navigate to detail screen with proper BlocProvider
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  // Create a new MessageBloc for the detail screen
                  create: (context) => MessageBloc(
                    apiService: messageApiService,
                    remorqueurId: messageBloc.remorqueurId,
                  ),
                  child: MessageDetailScreen(
                    message: message,
                    remorqueurId: messageBloc.remorqueurId,
                  ),
                ),
              ),
            );

            // Refresh messages list when returning from detail screen
            if (result == true && context.mounted) {
              messageBloc.add(LoadMessages());
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        message.title.toUpperCase(),
                        style: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontWeight: message.is_read
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                    ),
                    // Show unread indicator dot
                    if (!message.is_read)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(message.created_at),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: Text(
                    message.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// The detail screen that shows the full message
class MessageDetailScreen extends StatefulWidget {
  final GarageMessageResponse message;
  final int remorqueurId;

  const MessageDetailScreen({
    super.key,
    required this.message,
    required this.remorqueurId,
  });

  @override
  State<MessageDetailScreen> createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends State<MessageDetailScreen> {
  bool _hasMarkedAsRead = false;

  @override
  void initState() {
    super.initState();
    // Use post-frame callback to ensure the context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markAsReadIfNeeded();
    });
  }

  // Mark the message as read if it hasn't been read yet
  Future<void> _markAsReadIfNeeded() async {
    if (!widget.message.is_read && !_hasMarkedAsRead) {
      setState(() => _hasMarkedAsRead = true);
      context.read<MessageBloc>().add(MarkMessageAsRead(widget.message.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // When popping the screen, return true to indicate the message was viewed
      onWillPop: () async {
        Navigator.of(context).pop(true);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEBF6F1),
        appBar: AppBar(
          backgroundColor: const Color(0xFFEBF6F1),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          title: Text(
            widget.message.title,
            style: const TextStyle(color: Colors.black),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd MMM yyyy, HH:mm')
                        .format(widget.message.created_at),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.message.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
