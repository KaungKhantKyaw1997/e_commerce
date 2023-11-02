import 'package:e_commerce/global.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  String lastSeenTime = "Last seen: 10:30 PM";
  String username = "MgKaung";
  final String profilePhotoUrl = 'your_profile_photo_url_here';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: FontConstants.title1,
              ),
              Text(
                lastSeenTime,
                style: TextStyle(color: Colors.black, fontSize: 12),
              ),
            ],
          ),
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
        ),
    
      body: Column(
        
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chatData.length,
              itemBuilder: (BuildContext context, int index) {
                final message = chatData[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: message.isMe
                        ? Alignment.topRight
                        : Alignment.topLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: message.isMe
                            ? Theme.of(context).primaryColor
                            : Color(0xffE0E6EC),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(message.isMe ? 26 : 0),
                          topRight: Radius.circular(26.0),
                          bottomRight:
                              Radius.circular(message.isMe ? 0 : 26),
                          bottomLeft: Radius.circular(26.0),
                        ),
                      ),
                      width: MediaQuery.of(context).size.width - 100,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 10.0,
                      ),
                      child: Text(
                        message.message,
                        style: TextStyle(
                          color: message.isMe ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: 10,
              left: 10,
              right: 10,
              bottom: 10,
            ),
            child: Row(
              children: [
                Container(
                 
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: SvgPicture.asset(
                      "assets/icons/shop.svg",
                      width: 30,
                      height: 30,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 5, right: 5),
                    child: SizedBox(
                      height: 50, // Adjust the height as needed
                      child: TextField(
                        style: TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Message',
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 0, right: 0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: ColorConstants.primarycolor,
                    ),
                    onPressed: () async {},
                    child: Text(
                      language["Send"] ?? "Send",
                      style: FontConstants.button1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String message;
  final bool isMe;
  final String profileImageUrl;
  final String time;

  ChatMessage({
    required this.message,
    required this.isMe,
    required this.profileImageUrl,
    required this.time,
  });
}

List<ChatMessage> chatData = [
  ChatMessage(
    message: 'Hey, what are you up to?',
    isMe: true,
    profileImageUrl: 'https://via.placeholder.com/150',
    time: '11:30 AM',
  ),
  ChatMessage(
    message: 'Just working on some Flutter code. You?',
    isMe: false,
    profileImageUrl: 'https://via.placeholder.com/150',
    time: '11:30 AM',
  ),
  ChatMessage(
    message: 'That\'s cool! I am watching a movie.',
    isMe: true,
    profileImageUrl: 'https://via.placeholder.com/150',
    time: '11:30 AM',
  ),
  ChatMessage(
    message: 'Just working on some Flutter code. You?',
    isMe: false,
    profileImageUrl: 'https://via.placeholder.com/150',
    time: '11:30 AM',
  ),
  ChatMessage(
    message: 'Just working on some Flutter code. You?',
    isMe: false,
    profileImageUrl: 'https://via.placeholder.com/150',
    time: '11:30 AM',
  ),
  ChatMessage(
    message: 'Just working on some Flutter code. You?',
    isMe: false,
    profileImageUrl: 'https://via.placeholder.com/150',
    time: '11:30 AM',
  ),
  ChatMessage(
    message: 'Just working on some Flutter code. You?',
    isMe: false,
    profileImageUrl: 'https://via.placeholder.com/150',
    time: '11:30 AM',
  ),
  ChatMessage(
    message: 'Just working on some Flutter code. You?',
    isMe: false,
    profileImageUrl: 'https://via.placeholder.com/150',
    time: '11:30 AM',
  ),
  ChatMessage(
    message: 'Just working on some Flutter code. You?',
    isMe: false,
    profileImageUrl: 'https://via.placeholder.com/150',
    time: '11:30 AM',
  ),
  ChatMessage(
    message: 'Just working on some Flutter code. You?',
    isMe: false,
    profileImageUrl: 'https://via.placeholder.com/150',
    time: '11:30 AM',
  ),
];
