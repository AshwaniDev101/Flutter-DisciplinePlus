import 'package:flutter/material.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final Color color;
  final DateTime createdAt;
  final List<String> tags;
  final bool pinned;
  final bool archived;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.color,
    required this.createdAt,
    this.tags = const [],
    this.pinned = false,
    this.archived = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'content': content,
    'color': color.value,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'tags': tags,
    'pinned': pinned,
    'archived': archived,
  };

  factory Note.fromMap(Map<String, dynamic> m) => Note(
    id: m['id'] as String,
    title: m['title'] as String,
    content: m['content'] as String,
    color: Color(m['color'] as int),
    createdAt: DateTime.fromMillisecondsSinceEpoch(m['createdAt'] as int),
    tags: List<String>.from(m['tags'] ?? []),
    pinned: m['pinned'] ?? false,
    archived: m['archived'] ?? false,
  );
}
