import 'package:flutter/material.dart';

class MessageBar extends StatelessWidget {
  const MessageBar({
    super.key,
    required this.context,
    required this.focusNode,
    required this.messageController,
    required this.arrowForwordOnPressed,
    required this.sendButtonOnPressed,
  });

  final BuildContext context;
  final FocusNode focusNode;
  final TextEditingController messageController;
  final VoidCallback arrowForwordOnPressed;
  final VoidCallback sendButtonOnPressed;

  @override
  Widget build(BuildContext context) {
    return _messageBar();
  }

  Widget _messageBar() {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(4.0),
      child: focusNode.hasFocus
          ? Row(
              children: [
                IconButton(
                  padding: const EdgeInsets.all(10),
                  onPressed: arrowForwordOnPressed,
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
              controller: messageController,
              cursorRadius: const Radius.circular(2),
              cursorWidth: 1.5,
              expands: true,
              focusNode: focusNode,
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
      onPressed: sendButtonOnPressed,
      icon: const Icon(
        Icons.send_rounded,
        color: Color(0xFF0584FE),
      ),
    );
  }
}
