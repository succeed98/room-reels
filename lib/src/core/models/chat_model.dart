import 'package:equatable/equatable.dart';

class ChatModel extends Equatable {
  final String? id;
  final String buyer;
  final String seller;
  final List<Message> messages;

  const ChatModel({
    this.id,
    required this.buyer,
    required this.seller,
    required this.messages,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'],
      buyer: json['buyer'],
      seller: json['seller'],
      messages: List<Message>.from(json['messages']
          .map((message) => Message(
                content: message['content'],
                from: message['from'],
                to: message['to'],
                timestamp: message['timestamp'],
              ))
          .toList()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyer': buyer,
      'seller': seller,
      'messages': messages.map((message) => message.toJson()).toList(),
    };
  }

  ChatModel copy({
    String? id,
    String? buyer,
    String? seller,
    List<Message>? messages,
  }) {
    return ChatModel(
      id: id ?? this.id,
      buyer: buyer ?? this.buyer,
      seller: seller ?? this.seller,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [id, messages];
}

class Message extends Equatable {
  final String to;
  final String from;
  final String content;
  final String timestamp;

  const Message({
    required this.to,
    required this.from,
    required this.content,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      to: json['to'],
      from: json['from'],
      content: json['content'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'to': to,
      'from': from,
      'content': content,
      'timestamp': timestamp,
    };
  }

  @override
  List<Object?> get props => [to, from, content, timestamp];
}
