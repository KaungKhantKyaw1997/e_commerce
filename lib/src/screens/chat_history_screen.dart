import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/providers/chat_histories_provider.dart';
import 'package:e_commerce/src/providers/chats_provider.dart';
import 'package:e_commerce/src/screens/bottombar_screen.dart';
import 'package:e_commerce/src/services/chat_service.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String from = '';
  String role = "";
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        from = arguments["from"] ?? '';
      }
    });
    getData();
    getChatSessions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role') ?? "";
    });
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
        setState(() {
          if (chatHistoriesProvider.chatHistories.isEmpty) {
            _dataLoaded = true;
          }
        });
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

  deleteSession(chatId) async {
    ChatHistoriesProvider chatHistoriesProvider =
        Provider.of<ChatHistoriesProvider>(context, listen: false);
    try {
      final response = await chatService.deleteSessionData(chatId);
      if (response!["code"] == 204) {
        _dataLoaded = true;
        List chatHistories = (chatHistoriesProvider.chatHistories as List)
            .where((element) => element["chat_id"] != chatId)
            .toList();
        chatHistoriesProvider.setChatHistories(chatHistories);
      }
    } catch (e, s) {
      _refreshController.loadComplete();
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

    List<String> profiles = [];
    if (chatHistoriesProvider
        .chatHistories[index]["profile_image"].isNotEmpty) {
      profiles = (chatHistoriesProvider.chatHistories[index]["profile_image"]
              .split(",")
              .map((e) => e.trim())
              .toList() as List)
          .cast<String>();
    }

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
          Center(
            child: ClipOval(
              child: Container(
                width: 50,
                height: 50,
                color: ColorConstants.fillcolor,
                child: profiles.isNotEmpty
                    ? Stack(
                        children: <Widget>[
                          Positioned(
                            left: 0,
                            child: profiles[0].isNotEmpty
                                ? Image.network(
                                    '${ApiConstants.baseUrl}${profiles[0]}',
                                    width: role == 'admin' ? 25 : 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    'assets/images/profile.png',
                                    width: role == 'admin' ? 25 : 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          if (role == 'admin' && profiles.length > 1)
                            Positioned(
                              right: 0,
                              child: profiles[1].isNotEmpty
                                  ? Image.network(
                                      '${ApiConstants.baseUrl}${profiles[1]}',
                                      width: 25,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/images/profile.png',
                                      width: 25,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                        ],
                      )
                    : Image.asset(
                        'assets/images/profile.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
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
                                  ["chat_name"]
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
                                  0 &&
                              (role == 'user' || role == 'agent')
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
        child: chatHistoriesProvider.chatHistories.isNotEmpty
            ? SingleChildScrollView(
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
                            onTap: () async {
                              ChatsProvider chatProvider =
                                  Provider.of<ChatsProvider>(context,
                                      listen: false);
                              chatProvider.setChats([]);

                              await Navigator.pushNamedAndRemoveUntil(
                                context,
                                Routes.chat,
                                arguments: {
                                  'chat_id': chatHistoriesProvider
                                      .chatHistories[index]["chat_id"],
                                  'chat_name': chatHistoriesProvider
                                      .chatHistories[index]["chat_name"],
                                  'profile_image': chatHistoriesProvider
                                      .chatHistories[index]["profile_image"],
                                  'user_id': (chatHistoriesProvider
                                              .chatHistories[index]
                                          ["chat_participants"] as List)
                                      .where((element) => !element["is_me"])
                                      .map<String>((participant) =>
                                          participant["user_id"].toString())
                                      .toList()[0],
                                  'from': from,
                                },
                                (route) => true,
                              );

                              chatHistoriesProvider.setChatHistories([]);
                              page = 1;
                              search.text = '';
                              getChatSessions();
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Slidable(
                                  key: const ValueKey(0),
                                  endActionPane: ActionPane(
                                    motion: const BehindMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (BuildContext context) {
                                          deleteSession(chatHistoriesProvider
                                              .chatHistories[index]["chat_id"]);
                                        },
                                        backgroundColor:
                                            ColorConstants.redcolor,
                                        foregroundColor: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(
                                              index == 0 ? 10 : 0),
                                          bottomRight: Radius.circular(index ==
                                                  chatHistoriesProvider
                                                          .chatHistories
                                                          .length -
                                                      1
                                              ? 10
                                              : 0),
                                        ),
                                        icon: Icons.delete,
                                        label: language["Delete"] ?? "Delete",
                                      ),
                                    ],
                                  ),
                                  child: chatCard(index),
                                ),
                                index <
                                        chatHistoriesProvider
                                                .chatHistories.length -
                                            1
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
              )
            : _dataLoaded
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/icons/message.svg",
                          width: 120,
                          height: 120,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).primaryColor,
                            BlendMode.srcIn,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16,
                            bottom: 10,
                          ),
                          child: Text(
                            "No Messages",
                            textAlign: TextAlign.center,
                            style: MediaQuery.of(context).orientation ==
                                    Orientation.landscape
                                ? FontConstants.title1
                                : FontConstants.title2,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                          ),
                          child: Text(
                            "Your inbox is empty...",
                            textAlign: TextAlign.center,
                            style: MediaQuery.of(context).orientation ==
                                    Orientation.landscape
                                ? FontConstants.caption1
                                : FontConstants.subheadline2,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
      ),
      bottomNavigationBar: from == 'bottom' ? const BottomBarScreen() : null,
    );
  }
}
