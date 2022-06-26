// ignore_for_file: prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/chat_model.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../components/loading.dart';

class ChatHistory extends ConsumerWidget {
  const ChatHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final user = watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: Text('Chat History', style: F_24_MEDIUM),
      ),
      body: user.chats.isEmpty
          ? Center(child: Text('No chats available'))
          : ListView.separated(
              itemCount: user.chats.length,
              itemBuilder: (context, index) {
                return buildChatList(user.chats.elementAt(index));
              },
              separatorBuilder: (context, index) => Divider(),
            ),
    );
  }

  Widget buildChatList(String chatId) {
    return Consumer(
      builder: (context, watch, child) {
        final getChatStream = watch(getChatStreamProvider(chatId));

        return getChatStream.when(
          data: (chat) => buildUserList(chat),
          loading: () => Loading(),
          error: (error, stack) => TextButton(
            child: Text('oops failed to load data...Tap to refresh screen.'),
            onPressed: () => context.refresh(userStreamProvider(chatId)),
          ),
        );
      },
    );
  }

  Widget buildUserList(ChatModel chat) {
    return Consumer(
      builder: (context, watch, child) {
        final currentUser = watch(userProvider);
        final uid = currentUser.uid == chat.buyer ? chat.seller : chat.buyer;
        
        final otherUser = watch(userStreamProvider(uid));

        return otherUser.when(
          data: (user) {
            return GestureDetector(
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF2A3736).withOpacity(0.1),
                    image: user.photoURL!.isNotEmpty
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(
                              user.photoURL ?? '',
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),
                title:
                    Text('${user.name}', maxLines: 2, style: F_15_BOLD),
              ),
              onTap: () {
                final selectedChat = context.read(selectedChatProvider);
                selectedChat.state = chat;
                final otherUser = context.read(otherUserProvider);
                otherUser.state = user;

                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => Chat()));
              },
            );
          },
          loading: () => Loading(),
          error: (error, stack) => TextButton(
            child: Text('oops failed to load data...Tap to refresh screen.'),
            onPressed: () => context.refresh(userStreamProvider(uid)),
          ),
        );
      },
    );
  }
}

final selectedChatProvider = StateProvider<ChatModel>(
    (ref) => ChatModel(id: '', buyer: '', seller: '', messages: []));
final otherUserProvider = StateProvider<UserModel>((ref) => UserModel());

class Chat extends ConsumerWidget {
  Chat({Key? key}) : super(key: key);

  final TextEditingController _textController = TextEditingController();

  void handleSubmitted(BuildContext context, String text) async {
    _textController.clear();

    final user = context.read(userProvider);
    final otherUser = context.read(otherUserProvider);
    final selectedChat = context.read(selectedChatProvider);
    final chatDataSource = context.read(chatDataSourceProvider);

    final message = Message(
      from: user.uid ?? '',
      to: otherUser.state.uid ?? '',
      content: text,
      timestamp: DateTime.now().microsecondsSinceEpoch.toString(),
    );

    selectedChat.state.messages.insert(0, message);
    await chatDataSource
        .updateChat(selectedChat.state)
        .then((chat) => selectedChat.state = chat);
  }

  // The Chat interface
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final selectedChat = watch(selectedChatProvider);
    final otherUser = watch(otherUserProvider);
    final user = watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF2A3736).withOpacity(0.1),
              image: otherUser.state.photoURL == null ||
                      otherUser.state.photoURL!.isNotEmpty
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(
                        otherUser.state.photoURL ?? '',
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
          ),
          title: Text(
            '${otherUser.state.name}',
            maxLines: 2,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_, int index) {
                final message = selectedChat.state.messages.elementAt(index);
                return ChatMessage(
                  text: message.content,
                  name: otherUser.state.uid == message.from
                      ? otherUser.state.name ?? ''
                      : user.name ?? '',
                  type: otherUser.state.uid != message.from,
                );
              },
              itemCount: selectedChat.state.messages.length,
            ),
          ),
          Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: IconTheme(
              data: IconThemeData(color: Theme.of(context).accentColor),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: TextField(
                        controller: _textController,
                        onSubmitted: (value) => handleSubmitted(context, value),
                        decoration: InputDecoration.collapsed(
                            hintText: "Send a message"),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.0),
                      child: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () =>
                            handleSubmitted(context, _textController.text),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// The Chat message balloon
class ChatMessage extends StatelessWidget {
  const ChatMessage({Key? key, required this.text, required this.name, required this.type}) : super(key: key);

  final String text;
  final String name;
  final bool type;

  List<Widget> otherMessage(context) {
    return <Widget>[
      Container(
        margin: const EdgeInsets.only(right: 16.0),
        child: CircleAvatar(child: Text(name[0])),
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: Text(text),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> myMessage(context) {
    return <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(name, style: Theme.of(context).textTheme.subtitle1),
            Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: Text(text),
            ),
          ],
        ),
      ),
      Container(
        margin: const EdgeInsets.only(left: 16.0),
        child: CircleAvatar(
          child: Text(
            name[0],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: type ? myMessage(context) : otherMessage(context),
      ),
    );
  }
}
