import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:messanger_ui/components/messagebar.dart';
import 'package:messanger_ui/models/groupmodel.dart';
import 'package:messanger_ui/models/message.dart';
import 'package:messanger_ui/models/usermodel.dart';
import 'package:messanger_ui/services/database_service.dart';
// import 'package:messanger_ui/services/navigation_service.dart';
import 'package:messanger_ui/widgets/custom_back_button.dart';

class GroupMessageScreen extends StatefulWidget {
  const GroupMessageScreen(
      {super.key, required this.group, required this.currentUser});

  final Group group;
  final UserModel currentUser;

  @override
  State<GroupMessageScreen> createState() => _GroupMessageScreenState();
}

class _GroupMessageScreenState extends State<GroupMessageScreen> {
  final _groupDataStreamController = StreamController<DocumentSnapshot>();
  final _messageController = TextEditingController();
  final GetIt _getIt = GetIt.instance;
  final _focusNode = FocusNode();

  late DatabaseService _databaseService;
  // late NavigationService _navigationService;

  @override
  void initState() {
    super.initState();
    _databaseService = _getIt.get<DatabaseService>();
    // _navigationService = _getIt.get<NavigationService>();
    _refreshGroupDataStream();
  }

  void _refreshGroupDataStream() {
    _groupDataStreamController.addStream(
      _databaseService.getGroupData(widget.group.gid!),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    _groupDataStreamController.close();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.toString();
    if (messageText.isNotEmpty) {
      final message = Message(
        senderID: widget.currentUser.uid!,
        content: messageText,
        messageType: MessageType.text,
        sentAt: Timestamp.now(),
      );
      await _databaseService.sendGroupMessage(widget.group.gid!, message);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        automaticallyImplyLeading: false,
        title: _groupBar(),
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Expanded(
                flex: 8,
                child: _groupChat(),
              ),
              Flexible(
                  child: MessageBar(
                context: context,
                messageController: _messageController,
                focusNode: _focusNode,
                arrowForwordOnPressed: () {
                  setState(() {
                    _focusNode.unfocus();
                  });
                },
                sendButtonOnPressed: _sendMessage,
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _groupBar() {
    return Row(
      children: [
        const CustomBackButton(
          color: Color(0xFF0584FE),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.symmetric(
                  horizontal: 7.0,
                  vertical: 8.0,
                ),
                padding: const EdgeInsets.all(0.0),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: Image.network(
                    widget.group.pfpURL!,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.group.groupName!,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.41,
                      ),
                    ),
                    const Text(
                      'Messanger',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.08,
                        color: Color(0x59000000),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.info_outline,
            size: 25,
            color: Color(0xFF0584FE),
          ),
        )
      ],
    );
  }

  Widget _groupChat() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _groupDataStreamController.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text("Unable to load data."),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        dynamic data = snapshot.data!.data();
        if (data == null) {
          return const SizedBox.shrink();
        }
        Group group = data;
        if (group.messages == null || group.messages!.isEmpty) {
          return const SizedBox.shrink();
        }
        List<Message> messages = _generateGroupMessagesList(group.messages!);
        return ListView.builder(
        itemCount: messages.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final message = messages[index];
          return _messageItem(message);
        },
      );
      },
    );
  }

  List<Message> _generateGroupMessagesList(List<Message?> messages) {
    List<Message> messagesList = messages
        .where((m) => m != null && m.messageType == MessageType.text)
        .map((m) => Message.fromJson(m!.toJson()))
        .toList();

    messagesList.sort((a, b) {
      return a.sentAt!.compareTo(b.sentAt!);
    });

    return messagesList;
  }

  Widget _messageItem(Message message) {
    return Align(
      alignment: (message.senderID == widget.currentUser.uid!)
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 14),
          decoration: BoxDecoration(
            color: (message.senderID == widget.currentUser.uid!)
                ? const Color(0xFF0584FE)
                : const Color(0x0F000000),
            borderRadius: (message.senderID == widget.currentUser.uid!)
                ? const BorderRadius.only(
                    topLeft: Radius.circular(17),
                    bottomLeft: Radius.circular(17),
                    topRight: Radius.circular(17),
                    bottomRight: Radius.circular(4),
                  )
                : const BorderRadius.only(
                    topRight: Radius.circular(17),
                    bottomRight: Radius.circular(17),
                    topLeft: Radius.circular(17),
                    bottomLeft: Radius.circular(4),
                  ),
          ),
          child: Text(
            message.content!,
            softWrap: true,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: (message.senderID == widget.currentUser.uid!)
                  ? Colors.white
                  : Colors.black,
              letterSpacing: -0.41,
            ),
          ),
        ),
      ),
    );
  }
}
