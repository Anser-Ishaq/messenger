import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:messanger_ui/model/chat.dart';
import 'package:messanger_ui/model/message.dart';
import 'package:messanger_ui/model/usermodel.dart';
import 'package:messanger_ui/screens/chatuserprofile_screen.dart';
import 'package:messanger_ui/services/database_service.dart';
import 'package:messanger_ui/services/navigation_service.dart';
import 'package:messanger_ui/widgets/custom_back_button.dart';
import 'package:messanger_ui/widgets/custom_profile_view.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen(
      {super.key, required this.chatUser, required this.currentUser});

  final UserModel chatUser;
  final UserModel currentUser;

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final _chatDataStreamController = StreamController<DocumentSnapshot>();
  final _messageController = TextEditingController();
  final GetIt _getIt = GetIt.instance;
  final _focusNode = FocusNode();

  late DatabaseService _databaseService;
  late NavigationService _navigationService;

  @override
  void initState() {
    super.initState();
    _databaseService = _getIt.get<DatabaseService>();
    _navigationService = _getIt.get<NavigationService>();
    _refreshChatDataStream();
  }

  void _refreshChatDataStream() {
    _chatDataStreamController.addStream(
      _databaseService.getChatData(
        widget.currentUser.uid!,
        widget.chatUser.uid!,
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    _chatDataStreamController.close();
    super.dispose();
  }

  void _sendMessage() {
    final messageText = _messageController.text.toString();
    if (messageText.isNotEmpty) {
      final message = Message(
        senderID: widget.currentUser.uid!,
        content: messageText,
        messageType: MessageType.text,
        sentAt: Timestamp.now(),
      );

      _databaseService.sendChatMessage(
          widget.currentUser.uid!, widget.chatUser.uid!, message);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        automaticallyImplyLeading: false,
        title: _userBar(),
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Flexible(
                flex: 8,
                child: SingleChildScrollView(
                  reverse: true,
                  child: _userChat(),
                ),
              ),
              Flexible(child: _messageBar()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _userBar() {
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
                    widget.chatUser.pfpURL!,
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _navigationService.push(
                      MaterialPageRoute(
                        builder: (context) => ChatUserProfileScreen(
                          chatUser: widget.chatUser,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.chatUser.username!,
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
                ),
              )
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.phone_rounded,
            size: 25,
            color: Color(0xFF0584FE),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.videocam_rounded,
            size: 30,
            color: Color(0xFF0584FE),
          ),
        )
      ],
    );
  }

  Widget _userChat() {
    return Column(
      children: [
        Container(
          height: 255,
          width: 275,
          margin: const EdgeInsets.symmetric(
            horizontal: 50,
            vertical: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 10.5,
                ),
                child: CustomProfileView(
                    src: widget.chatUser.pfpURL!,
                    name: widget.chatUser.username!,
                    subtitle: 'You\'re friends on Facebook'),
              ),
              const SizedBox(
                height: 26,
              ),
              _newChat(),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        _messageBox(),
      ],
    );
  }

  Widget _newChat() {
    return Column(
      children: [
        SizedBox(
          width: 275,
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: (275 - 48) / 2 - 32 / 2,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: ClipOval(
                    child: Image.network(
                      widget.chatUser.pfpURL!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: (275 - 48) / 2 + 32 / 2,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      width: 2,
                      color: Colors.white,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      widget.currentUser.pfpURL!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(
          'Say hi to your new Facebook friend, ${widget.chatUser.username!.split(' ')[0]}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.01,
            color: Color(0x4D000000),
          ),
        ),
      ],
    );
  }

  Widget _messageBox() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _chatDataStreamController.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text("Unable to load data."),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: SizedBox());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
            child: Text("No messages found."),
          );
        }

        dynamic data = snapshot.data!.data();
        if (data == null) {
          return const Center(
            child: Text("No data available."),
          );
        }
        Chat chat = data;
        List<Message> messages = _generateChatMessagesList(chat.messages!);
        return Column(
          children: messages.map((message) => _messageItem(message)).toList(),
        );
      },
    );
  }

  List<Message> _generateChatMessagesList(List<Message?> messages) {
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

  Widget _messageBar() {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(4.0),
      child: _focusNode.hasFocus
          ? Row(
              children: [
                IconButton(
                  padding: const EdgeInsets.all(10),
                  onPressed: () {
                    setState(() {
                      _focusNode.unfocus();
                    });
                  },
                  icon: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF0584FE),
                  ),
                ),
                Expanded(child: _textField()),
                _sendButton(),
              ],
            )
          : Row(
              children: [
                IconButton(
                  padding: const EdgeInsets.all(10),
                  onPressed: () {},
                  icon: const Icon(
                    Icons.pix_rounded,
                    color: Color(0xFF0584FE),
                  ),
                ),
                IconButton(
                  padding: const EdgeInsets.all(10),
                  onPressed: () {},
                  icon: const Icon(
                    Icons.camera_alt_rounded,
                    color: Color(0xFF0584FE),
                  ),
                ),
                IconButton(
                  padding: const EdgeInsets.all(10),
                  onPressed: () {},
                  icon: const Icon(
                    Icons.photo_rounded,
                    color: Color(0xFF0584FE),
                  ),
                ),
                IconButton(
                  padding: const EdgeInsets.all(10),
                  onPressed: () {},
                  icon: const Icon(
                    Icons.mic_rounded,
                    color: Color(0xFF0584FE),
                  ),
                ),
                Expanded(
                  child: _textField(),
                ),
                _sendButton(),
              ],
            ),
    );
  }

  Widget _textField() {
    return Container(
      height: 40,
      // margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.only(left: 7),
      decoration: BoxDecoration(
        color: const Color(0x0A000000),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              cursorRadius: const Radius.circular(2),
              cursorWidth: 1.5,
              expands: true,
              focusNode: _focusNode,
              maxLines: null,
              cursorColor: const Color(0xFF0584FE),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Aa',
              ),
            ),
          ),
          IconButton(
            padding: const EdgeInsets.all(0),
            constraints: const BoxConstraints(
              maxHeight: 35,
              maxWidth: 35,
            ),
            highlightColor: const Color(0x30000000),
            onPressed: () {},
            icon: const Icon(
              Icons.tag_faces_rounded,
              size: 27,
              color: Color(0xFF0584FE),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sendButton() {
    return IconButton(
      padding: const EdgeInsets.all(10),
      onPressed: _sendMessage,
      icon: const Icon(
        Icons.thumb_up_off_alt_rounded,
        color: Color(0xFF0584FE),
      ),
    );
  }
}
