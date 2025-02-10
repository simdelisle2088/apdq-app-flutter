import 'package:equatable/equatable.dart';

class GarageMessageResponse extends Equatable {
  final int id;
  final String title;
  final String content;
  final DateTime created_at;
  final bool to_all;
  final List<int> remorqueur_ids;
  final bool is_read;

  const GarageMessageResponse({
    required this.id,
    required this.title,
    required this.content,
    required this.created_at,
    required this.to_all,
    required this.remorqueur_ids,
    required this.is_read,
  });

  factory GarageMessageResponse.fromJson(Map<String, dynamic> json) {
    return GarageMessageResponse(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      created_at: DateTime.parse(json['created_at'] as String),
      to_all: json['to_all'] as bool,
      remorqueur_ids: (json['remorqueur_ids'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      is_read: json['is_read'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': created_at.toIso8601String(),
      'to_all': to_all,
      'remorqueur_ids': remorqueur_ids,
      'is_read': is_read,
    };
  }

  @override
  List<Object?> get props =>
      [id, title, content, created_at, to_all, remorqueur_ids, is_read];
}
