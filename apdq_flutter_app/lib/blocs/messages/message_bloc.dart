import 'dart:async';
import 'package:apdq_flutter_app/blocs/messages/message_api_service.dart';
import 'package:apdq_flutter_app/blocs/messages/message_event.dart';
import 'package:apdq_flutter_app/blocs/messages/message_state.dart';
import 'package:apdq_flutter_app/models/message_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final MessageApiService apiService;
  Timer? _refreshTimer;
  final int remorqueurId;

  MessageBloc({
    required this.apiService,
    required this.remorqueurId,
  }) : super(MessageState()) {
    on<LoadMessages>(_onLoadMessages);
    on<CheckNewMessages>(_onCheckNewMessages);
    on<MarkMessageAsRead>(_onMarkMessageAsRead);

    _refreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => add(LoadMessages()),
    );
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }

  Future<void> _onMarkMessageAsRead(
    MarkMessageAsRead event,
    Emitter<MessageState> emit,
  ) async {
    try {
      // Call the API to mark the message as read
      final success = await apiService.markMessageAsRead(
        event.messageId,
        remorqueurId,
      );

      if (success) {
        // Update the local state to reflect the change
        final updatedMessages = state.messages.map((message) {
          if (message.id == event.messageId) {
            // Create a new message object with is_read set to true
            return GarageMessageResponse(
              id: message.id,
              title: message.title,
              content: message.content,
              created_at: message.created_at,
              to_all: message.to_all,
              remorqueur_ids: message.remorqueur_ids,
              is_read: true,
            );
          }
          return message;
        }).toList();

        emit(state.copyWith(messages: updatedMessages));
      }
    } catch (e) {
      print('Error marking message as read: $e');
      // Optionally emit an error state if needed
    }
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<MessageState> emit,
  ) async {
    try {
      emit(state.copyWith(status: MessageStatus.loading));

      final messages = await apiService.getRemorqueurMessages(remorqueurId);

      emit(state.copyWith(
        status: MessageStatus.loaded,
        messages: messages,
        hasNewMessages: false,
        lastChecked: DateTime.now(),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MessageStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onCheckNewMessages(
    CheckNewMessages event,
    Emitter<MessageState> emit,
  ) async {
    try {
      final newMessages = await apiService.getRemorqueurMessages(remorqueurId);

      // Check if there are any new messages
      final hasNew = newMessages.any((newMsg) {
        return !state.messages.any((oldMsg) => oldMsg.id == newMsg.id);
      });

      if (hasNew) {
        emit(state.copyWith(
          messages: newMessages,
          hasNewMessages: true,
          lastChecked: DateTime.now(),
        ));
      }
    } catch (e) {
      // Don't update state on error during background check
      print('Error checking new messages: $e');
    }
  }
}
