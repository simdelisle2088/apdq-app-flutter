import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:apdq_flutter_app/blocs/messages/message_bloc.dart';
import 'package:apdq_flutter_app/blocs/messages/message_event.dart';
import 'package:apdq_flutter_app/blocs/messages/message_state.dart';
import 'package:apdq_flutter_app/screens/message_screen.dart';
import 'package:apdq_flutter_app/blocs/messages/message_api_service.dart';

// This widget wraps the notification icon and provides the necessary bloc
class NotificationSystem extends StatefulWidget {
  const NotificationSystem({super.key});

  @override
  State<NotificationSystem> createState() => _NotificationSystemState();
}

class _NotificationSystemState extends State<NotificationSystem> {
  late Future<String?> _userIdFuture;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _userIdFuture = _storage.read(key: 'user_id');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _userIdFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(width: 48);
        }

        final userId = int.parse(snapshot.data!);

        // Provide the MessageBloc here
        return BlocProvider(
          create: (context) => MessageBloc(
            apiService: context.read<MessageApiService>(),
            remorqueurId: userId,
          )..add(LoadMessages()),
          child: const NotificationIconWithBadge(),
        );
      },
    );
  }
}

// The actual notification icon widget
class NotificationIconWithBadge extends StatelessWidget {
  const NotificationIconWithBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageBloc, MessageState>(
      builder: (context, state) {
        bool hasUnreadMessages = false;
        if (state.status == MessageStatus.loaded) {
          final remorqueurId = context.read<MessageBloc>().remorqueurId;
          hasUnreadMessages = state.messages.any((message) =>
              !message.is_read &&
              (message.remorqueur_ids.contains(remorqueurId) ||
                  message.to_all));
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: IconButton(
                icon: const Icon(Icons.notifications, color: Colors.black),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        // Create a new MessageBloc for the MessageScreen
                        create: (context) => MessageBloc(
                          apiService: context.read<MessageApiService>(),
                          remorqueurId:
                              context.read<MessageBloc>().remorqueurId,
                        )..add(LoadMessages()),
                        child: const MessageScreen(),
                      ),
                    ),
                  )
                      .then((_) {
                    if (context.mounted) {
                      context.read<MessageBloc>().add(LoadMessages());
                    }
                  });
                },
              ),
            ),
            if (hasUnreadMessages)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
