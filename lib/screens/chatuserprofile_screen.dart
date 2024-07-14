import 'package:flutter/material.dart';
import 'package:messanger_ui/models/usermodel.dart';
import 'package:messanger_ui/widgets/custom_back_button.dart';
import 'package:messanger_ui/widgets/custom_divider.dart';
import 'package:messanger_ui/widgets/custom_icon_buttom.dart';
import 'package:messanger_ui/widgets/custom_profile_view.dart';

class ChatUserProfileScreen extends StatefulWidget {
  const ChatUserProfileScreen({
    super.key,
    required this.chatUser,
  });

  final UserModel chatUser;

  @override
  State<ChatUserProfileScreen> createState() => _ChatUserProfileScreenState();
}

class _ChatUserProfileScreenState extends State<ChatUserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 48,
                            height: 48,
                            child: CustomBackButton(),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 11.5,
                              ),
                              child: CustomProfileView(
                                src: widget.chatUser.pfpURL!,
                                name: widget.chatUser.username!,
                                subtitle: 'Messanger',
                                subtitleColor: const Color(0x80000000),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 48,
                            height: 48,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomIconButtom(
                            iconData: Icons.phone_rounded,
                            title: 'Audio',
                          ),
                          CustomIconButtom(
                            iconData: Icons.videocam_rounded,
                            title: 'Video',
                          ),
                          CustomIconButtom(
                            iconData: Icons.person,
                            title: 'Profile',
                          ),
                          CustomIconButtom(
                            iconData: Icons
                                .notifications, // adjust // album   keyboard_arrow_right_rounded
                            title: 'Mute', //    trip_origin_rounded
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _rowItem(
                      text: 'Color',
                      child: const Icon(
                        Icons.trip_origin_rounded,
                        color: Color(0xFF0584FE),
                      ),
                    ),
                    const CustomDivider(),
                    _rowItem(
                      text: 'Emoji',
                      child: const Icon(
                        Icons.thumb_up_off_alt_rounded,
                        color: Color(0xFF0584FE),
                      ),
                    ),
                    const CustomDivider(),
                    _rowItem(
                      text: 'Nicknames',
                      child: GestureDetector(
                        onTap: () {},
                        child: const Icon(
                          Icons.keyboard_arrow_right_rounded,
                          color: Color(0x33000000),
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
                _spaceDivider(),

                // More Actions
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.only(left: 12),
                      child: const Text(
                        'MORE ACTIONS',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Color(0x59000000),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.15,
                          height: 15.51 / 13,
                        ),
                      ),
                    ),
                    _rowItem(
                      text: 'Search in Conversation',
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: const BoxDecoration(
                          color: Color(0x0A000000),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: const EdgeInsets.all(0.0),
                          onPressed: () {},
                          icon: const Icon(
                            Icons.search_rounded,
                            size: 23,
                          ),
                        ),
                      ),
                    ),
                    const CustomDivider(),
                    _rowItem(
                      text: 'Create Group',
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: const BoxDecoration(
                          color: Color(0x0A000000),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: const EdgeInsets.all(0.0),
                          onPressed: () {},
                          icon: const Icon(
                            Icons.groups_2_rounded,
                            size: 23,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                _spaceDivider(),

                // Privacy
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.only(left: 12),
                      child: const Text(
                        'PRIVACY',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Color(0x59000000),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.15,
                          height: 15.51 / 13,
                        ),
                      ),
                    ),
                    _rowItem(
                      text: 'Notifications',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'On',
                            style: TextStyle(
                                color: Color(0x59000000),
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.41,
                                height: 20.29 / 17),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Icon(
                              Icons.keyboard_arrow_right_rounded,
                              textDirection: TextDirection.rtl,
                              color: Color(0x33000000),
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const CustomDivider(),
                    _rowItem(
                      text: 'Ignore Messages',
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: const BoxDecoration(
                          color: Color(0x0A000000),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: const EdgeInsets.all(0),
                          onPressed: () {},
                          icon: const Icon(
                            Icons.circle,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    const CustomDivider(),
                    _rowItem(
                      text: 'Block',
                      child: const SizedBox(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _rowItem({
    required String text,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.41,
              height: 20.29 / 17,
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _spaceDivider() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.032,
    );
  }
}
