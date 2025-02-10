import 'package:apdq_flutter_app/blocs/messages/message_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:apdq_flutter_app/blocs/messages/message_bloc.dart';
import 'package:apdq_flutter_app/blocs/messages/message_state.dart';
import 'package:apdq_flutter_app/blocs/messages/message_event.dart';
import 'package:apdq_flutter_app/screens/search_screen.dart';
import 'package:apdq_flutter_app/screens/message_screen.dart';

// This wrapper component handles the MessageBloc provision
class NavigationBarWithNotifications extends StatefulWidget {
  final int currentIndex;

  const NavigationBarWithNotifications({
    super.key,
    required this.currentIndex,
  });

  @override
  State<NavigationBarWithNotifications> createState() =>
      _NavigationBarWithNotificationsState();
}

class _NavigationBarWithNotificationsState
    extends State<NavigationBarWithNotifications> {
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
          // Show regular bottom bar without notifications while loading
          return CustomBottomNavigationBarContent(
            currentIndex: widget.currentIndex,
            hasUnreadMessages: false,
          );
        }

        final userId = int.parse(snapshot.data!);

        // Provide MessageBloc for the navigation bar
        return BlocProvider(
          create: (context) => MessageBloc(
            apiService: context.read<MessageApiService>(),
            remorqueurId: userId,
          )..add(LoadMessages()),
          child: BlocBuilder<MessageBloc, MessageState>(
            builder: (context, state) {
              bool hasUnreadMessages = false;
              if (state.status == MessageStatus.loaded) {
                hasUnreadMessages = state.messages.any((message) =>
                    !message.is_read &&
                    (message.remorqueur_ids.contains(userId) ||
                        message.to_all));
              }

              return CustomBottomNavigationBarContent(
                currentIndex: widget.currentIndex,
                hasUnreadMessages: hasUnreadMessages,
              );
            },
          ),
        );
      },
    );
  }
}

// The actual content of the bottom navigation bar
class CustomBottomNavigationBarContent extends StatelessWidget {
  final int currentIndex;
  final bool hasUnreadMessages;

  const CustomBottomNavigationBarContent({
    super.key,
    required this.currentIndex,
    required this.hasUnreadMessages,
  });

  void _handleNavigation(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        if (currentIndex != 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SearchScreen()),
          );
        }
        break;
      case 1:
        if (currentIndex != 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => MessageBloc(
                  apiService: context.read<MessageApiService>(),
                  remorqueurId: context.read<MessageBloc>().remorqueurId,
                )..add(LoadMessages()),
                child: const MessageScreen(),
              ),
            ),
          );
        }
        break;
      case 2:
        if (currentIndex != 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile feature coming soon!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _handleNavigation(context, index),
        selectedItemColor: const Color(0xFF12BCC1),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Recherche',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.message,
                  color:
                      currentIndex == 1 ? const Color(0xFF12BCC1) : Colors.grey,
                ),
                if (hasUnreadMessages)
                  Positioned(
                    top: -4,
                    right: -4,
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
            ),
            label: 'Message',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
