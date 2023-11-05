import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/providers/chat_histories_provider.dart';
import 'package:e_commerce/src/providers/chats_provider.dart';
import 'package:e_commerce/src/services/chat_service.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  final crashlytic = new CrashlyticsService();
  ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  TextEditingController search = TextEditingController(text: '');
  int crossAxisCount = 1;
  final chatService = ChatService();
  int page = 1;

  @override
  void initState() {
    super.initState();
    getChatSessions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getChatSessions() async {
    ChatHistoriesProvider chatHistoriesProvider =
        Provider.of<ChatHistoriesProvider>(context, listen: false);
    try {
      final response = await chatService.getChatSessionsData(
          page: page, search: search.text);
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();

      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          List chatHistories = chatHistoriesProvider.chatHistories;
          chatHistories += response["data"];
          chatHistoriesProvider.setChatHistories(chatHistories);
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

  chatCard(index) {
    ChatHistoriesProvider chatHistoriesProvider =
        Provider.of<ChatHistoriesProvider>(context, listen: true);

    return Container(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(index == 0 ? 10 : 0),
          topRight: Radius.circular(index == 0 ? 10 : 0),
          bottomLeft: Radius.circular(
              index == chatHistoriesProvider.chatHistories.length - 1 ? 10 : 0),
          bottomRight: Radius.circular(
              index == chatHistoriesProvider.chatHistories.length - 1 ? 10 : 0),
        ),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: chatHistoriesProvider
                    .chatHistories[index]["profile_image"].isNotEmpty
                ? BoxDecoration(
                    color: ColorConstants.fillcolor,
                    image: DecorationImage(
                      image: NetworkImage(
                          '${ApiConstants.baseUrl}${chatHistoriesProvider.chatHistories[index]["profile_image"].toString()}'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: Colors.transparent,
                    ),
                  )
                : BoxDecoration(
                    color: ColorConstants.fillcolor,
                    image: DecorationImage(
                      image: AssetImage('assets/images/profile.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: Colors.transparent,
                    ),
                  ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(
                left: 15,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chatHistoriesProvider.chatHistories[index]
                                  ["sender_name"]
                              .toString(),
                          overflow: TextOverflow.ellipsis,
                          style: FontConstants.body1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 8,
                        ),
                        child: Text(
                          Jiffy.parseFromDateTime(DateTime.parse(
                                      chatHistoriesProvider.chatHistories[index]
                                              ["created_at"] +
                                          "Z")
                                  .toLocal())
                              .format(pattern: 'dd/MM/yyyy'),
                          overflow: TextOverflow.ellipsis,
                          style: FontConstants.caption1,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          '${chatHistoriesProvider.chatHistories[index]["sender_name"]}: ${chatHistoriesProvider.chatHistories[index]["last_message_text"]}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: FontConstants.caption1,
                        ),
                      ),
                      chatHistoriesProvider.chatHistories[index]
                                  ["unread_counts"] !=
                              0
                          ? Container(
                              margin: EdgeInsets.only(
                                left: 8,
                              ),
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Text(
                                chatHistoriesProvider.chatHistories[index]
                                        ["unread_counts"]
                                    .toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: FontConstants.bottom,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : Text(''),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ChatHistoriesProvider chatHistoriesProvider =
        Provider.of<ChatHistoriesProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: TextField(
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
          onChanged: (value) {
            page = 1;
            chatHistoriesProvider.setChatHistories([]);
            getChatSessions();
          },
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: SmartRefresher(
        header: WaterDropMaterialHeader(
          backgroundColor: Theme.of(context).primaryColor,
          color: Colors.white,
        ),
        footer: ClassicFooter(),
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: true,
        onRefresh: () async {
          page = 1;
          chatHistoriesProvider.setChatHistories([]);
          await getChatSessions();
        },
        onLoading: () async {
          await getChatSessions();
        },
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            width: double.infinity,
            child: Column(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: chatHistoriesProvider.chatHistories.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        print(chatHistoriesProvider.chatHistories[index]
                            ["chat_participants"]);
                        ChatsProvider chatProvider =
                            Provider.of<ChatsProvider>(context, listen: false);
                        chatProvider.setChats([]);

                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          Routes.chat,
                          arguments: {
                            'chat_id': chatHistoriesProvider
                                .chatHistories[index]["chat_id"],
                            'chat_name': chatHistoriesProvider
                                .chatHistories[index]["chat_name"],
                            'profile_image': chatHistoriesProvider
                                .chatHistories[index]["profile_image"],
                            'user_id':
                                (chatHistoriesProvider.chatHistories[index]
                                        ["chat_participants"] as List)
                                    .where((element) => !element["is_me"])
                                    .map<String>((participant) =>
                                        participant["user_id"].toString())
                                    .toList()[0],
                            'from': 'chat_history',
                          },
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          chatCard(index),
                          index < chatHistoriesProvider.chatHistories.length - 1
                              ? Container(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    right: 16,
                                  ),
                                  child: const Divider(
                                    height: 0,
                                    color: Colors.grey,
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
