import 'package:apdq_flutter_app/models/message_models.dart';
import 'package:equatable/equatable.dart';

enum MessageStatus { initial, loading, loaded, error }

class MessageState extends Equatable {
  final MessageStatus status;
  final List<GarageMessageResponse> messages;
  final String? error;
  final bool hasNewMessages;
  final DateTime lastChecked;

  // Create a static final field for the initial empty list
  static const List<GarageMessageResponse> _emptyMessages = [];

  MessageState._({
    this.status = MessageStatus.initial,
    List<GarageMessageResponse>? messages,
    this.error,
    this.hasNewMessages = false,
    DateTime? lastChecked,
  })  : messages = messages ?? _emptyMessages,
        lastChecked = lastChecked ?? DateTime.now();

  // Factory constructor for creating the initial state
  factory MessageState({
    MessageStatus status = MessageStatus.initial,
    List<GarageMessageResponse>? messages,
    String? error,
    bool hasNewMessages = false,
    DateTime? lastChecked,
  }) {
    return MessageState._(
      status: status,
      messages: messages,
      error: error,
      hasNewMessages: hasNewMessages,
      lastChecked: lastChecked,
    );
  }

  MessageState copyWith({
    MessageStatus? status,
    List<GarageMessageResponse>? messages,
    String? error,
    bool? hasNewMessages,
    DateTime? lastChecked,
  }) {
    return MessageState._(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      error: error,
      hasNewMessages: hasNewMessages ?? this.hasNewMessages,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }

  @override
  List<Object?> get props =>
      [status, messages, error, hasNewMessages, lastChecked];
}
