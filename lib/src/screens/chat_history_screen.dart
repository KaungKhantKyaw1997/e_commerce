import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/services/chat_service.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  bool isSearching = true;
  List chats = [];
  int crossAxisCount = 1;
  final chatService = ChatService();
  int page = 1;
final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  TextEditingController search = TextEditingController(text: '');
   final crashlytic = new CrashlyticsService();
  getChatHistory() async {
    try {
      final response =
          await chatService.getChatSessionsData(page: page);
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();

      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          chats += response["data"];
          page++;
        }
        setState(() {});
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e, s) {
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
      if (e is DioException &&
          e.error is SocketException &&
          !isConnectionTimeout) {
        isConnectionTimeout = true;
        Navigator.pushNamed(
          context,
          Routes.connection_timeout,
        );
        return;
      }
      crashlytic.myGlobalErrorHandler(e, s);
      if (e is DioException && e.response != null && e.response!.data != null) {
        if (e.response!.data["message"] == "invalid token" ||
            e.response!.data["message"] ==
                "invalid authorization header format") {
          Navigator.pushNamed(
            context,
            Routes.unauthorized,
          );
        } else {
          ToastUtil.showToast(
              e.response!.data['code'], e.response!.data['message']);
        }
      }
    }
  }

    @override
  void initState() {
    super.initState();
    getChatHistory();
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
                )
              : Text(
                  'Chat History',
                  style: TextStyle(color: Colors.black),
                ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right : 18.0),
              child: IconButton(
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
            ),
          ],
          iconTheme: IconThemeData(
            color: Colors.black,
          )
          ),
      body: ListView.builder(
        itemCount: 10, 
        itemBuilder: (BuildContext context, int index) {
          String lastMessageTime = "Yesterday";
          String senderName =
              'Who sent the last message will be many time';
          return ListTile(
              //  contentPadding: EdgeInsets.only(right: ,left:10),
            leading: CircleAvatar(
              
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
            title: Text('User Name'),
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
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '3',
                      style: TextStyle(color: Colors.white),
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
