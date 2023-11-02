import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  String formatTime(String time) {
    final currentTime = DateTime.now();
    final messageTime = DateTime.parse(time);

    if (currentTime.difference(messageTime).inDays < 7) {
      return messageTime.weekday == currentTime.weekday
          ? 'Today at ${messageTime.hour}:${messageTime.minute}'
          : '${_getWeekday(messageTime.weekday)} at ${messageTime.hour}:${messageTime.minute}';
    } else if (currentTime.year == messageTime.year) {
      return '${_getMonth(messageTime.month)} ${messageTime.day} at ${messageTime.hour}:${messageTime.minute}';
    } else {
      return '${messageTime.year} ${_getMonth(messageTime.month)} ${messageTime.day} at ${messageTime.hour}:${messageTime.minute}';
    }
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  String _getMonth(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

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
                    alignment:
                        message.isMe ? Alignment.topRight : Alignment.topLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: message.isMe
                            ? Theme.of(context).primaryColor
                            : Color(0xffE0E6EC),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(message.isMe ? 26 : 0),
                          topRight: Radius.circular(26.0),
                          bottomRight: Radius.circular(message.isMe ? 0 : 26),
                          bottomLeft: Radius.circular(26.0),
                        ),
                      ),
                      width: MediaQuery.of(context).size.width - 100,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 10.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatTime(message.time),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            message.message,
                            style: TextStyle(
                              color: message.isMe ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
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
                      "assets/icons/camera.svg",
                      width: 30,
                      height: 30,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 5, right: 5),
                    child: SizedBox(
                      height: 50, 
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
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: InkWell(
                    onTap: () async {
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset(
                        "assets/icons/send.svg",
                        height: 24,
                        width: 24,
                      ),
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
    time: '2022-10-30 23:18:00',
  ),
  ChatMessage(
    message: 'Just working on some Flutter code. You?',
    isMe: false,
    profileImageUrl: 'https://via.placeholder.com/150',
    time: '2022-10-30 23:18:00',
  ),
  ChatMessage(
    message: 'That\'s cool! I am watching a movie.',
    isMe: true,
    profileImageUrl: 'https://via.placeholder.com/150',
    time: '2022-10-30 23:18:00',
  ),
  ChatMessage(
    message: 'Just working on some Flutter code. You?',
    isMe: false,
    profileImageUrl: 'https://via.placeholder.com/150',
    time: '2023-10-30 23:18:00',
  ),
  ChatMessage(
    message: 'Just working on some Flutter code. You?',
    isMe: false,
    profileImageUrl: 'https://via.placeholder.com/150',
    time: '2023-10-30 23:18:00',
  ),
  ChatMessage(
    message: 'Just working on some Flutter code. You?',
    isMe: false,
    profileImageUrl: 'https://via.placeholder.com/150',
    time: '2023-10-30 23:18:00',
  ),
  ChatMessage(
    message: 'Just working on some Flutter code. You?',
    isMe: false,
    profileImageUrl: 'https://via.placeholder.com/150',
    time: '2023-10-30 23:18:00',
  ),
  ChatMessage(
    message: 'Just working on some Flutter code. You?',
    isMe: false,
    profileImageUrl: 'https://via.placeholder.com/150',
    time: '2023-10-30 23:18:00',
  ),
  ChatMessage(
    message: 'Just working on some Flutter code. You?',
    isMe: false,
    profileImageUrl: 'https://via.placeholder.com/150',
    time: '2023-10-30 23:18:00',
  ),
  ChatMessage(
    message: 'Just working on some Flutter code. You?',
    isMe: false,
    profileImageUrl: 'https://via.placeholder.com/150',
    time: '2023-10-30 23:18:00',
  ),
];
