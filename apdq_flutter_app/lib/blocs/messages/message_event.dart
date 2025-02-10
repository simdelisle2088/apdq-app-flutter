import 'package:equatable/equatable.dart';

abstract class MessageEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMessages extends MessageEvent {}

class CheckNewMessages extends MessageEvent {}

class MarkMessageAsRead extends MessageEvent {
  final int messageId;

  MarkMessageAsRead(this.messageId);

  @override
  List<Object?> get props => [messageId];
}
