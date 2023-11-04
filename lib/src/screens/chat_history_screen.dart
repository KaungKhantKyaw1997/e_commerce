import 'package:e_commerce/global.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  int crossAxisCount = 1;
  final chatService=ChatService();
  int page = 1;
   bool isSearching = false;
   List chats=[];
   TextEditingController search = TextEditingController(text: '');

   getChatHistory()
   {
    
   }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
      backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
     title: isSearching
            ? TextField(
                controller: search,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          style: FontConstants.body1,
          cursorColor: Colors.black,
          decoration: InputDecoration(
            hintText: language["Search"] ?? "Search",
            filled: true,
            fillColor: ColorConstants.fillcolor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (value) {
            page = 1;
            chats = [];
            if (value.isEmpty) {
              setState(() {});
              return;
            }
            // getProducts();
          },
              ) : Text('Chat History',style:  TextStyle(color: Colors.black),),
               actions: [
          IconButton(
            icon: SvgPicture.asset(
              "assets/icons/search.svg",
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              page = 1;
              chats = [];
              if (search.text.isEmpty) {
                setState(() {});
                return;
              }
               getChatHistory();
            },
          ),
        ],
        iconTheme: IconThemeData(
          color: Colors.black,
        )
           
      ),
      body: ListView.builder(
        itemCount: 10, // Replace this with the actual number of chats
        itemBuilder: (BuildContext context, int index) {
          String lastMessageTime = "Yesterday";
          String senderName = 'Who sent the last message will be many time'; // Replace with actual sender's name
          return ListTile(
            leading:  CircleAvatar(
              // Replace with actual profile image
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
            title:  Text('User Name'),
            subtitle: Row(
              children: [
                 Text('You: '),
                Expanded(
                 
                    child: Text(
                      senderName,
                        overflow: TextOverflow.ellipsis,
                style: crossAxisCount == 1
                    ? FontConstants.body1
                    : FontConstants.caption2,
                    ),
                 
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 25,
                  height: 25,
                  decoration:  BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '3', 
                      style:  TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                Text(
                  lastMessageTime,
                  style: FontConstants.smallText1,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
