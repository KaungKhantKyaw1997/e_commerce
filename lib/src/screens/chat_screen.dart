import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/services/auth_service.dart';
import 'package:e_commerce/src/services/chat_service.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final crashlytic = new CrashlyticsService();
  final chatService = ChatService();
  ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  TextEditingController message = TextEditingController(text: '');
  FocusNode _messageFocusNode = FocusNode();
  List imageUrls = [];
  List<XFile> pickedMultiFile = <XFile>[];
  int receiverId = 0;
  int chatId = 0;
  String chatName = '';
  String lastSeenTime = '';
  String from = '';
  List chatData = [];
  int page = 1;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        receiverId = arguments["receiver_id"] ?? 0;
        chatId = arguments["chat_id"] ?? 0;
        chatName = arguments["chat_name"] ?? '';
        lastSeenTime = arguments["created_at"] ?? '';
        from = arguments["from"] ?? '';
      }
      await getChatMessages();
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  getChatMessages() async {
    try {
      final response = await chatService.getChatMessagesData(
          chatId: chatId, receiverId: receiverId, page: page);
      _refreshController.refreshCompleted();

      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          for (var message in response["data"]) {
            if (message["status"] == "sent") {
              updateMessageStatus(message["message_id"]);
            }
          }

          chatData += response["data"];
          chatData.sort((a, b) => a["created_at"].compareTo(b["created_at"]));
          page++;
        }
        setState(() {});
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e, s) {
      _refreshController.refreshCompleted();
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

  updateMessageStatus(id) {
    final body = {
      "status": "read",
    };
    chatService.updateMessageStatusData(body, id);
  }

  sendMessage() async {
    try {
      final body = {
        "receiver_id": receiverId,
        "chat_id": chatId,
        "message_text": message.text,
        "image_urls": imageUrls,
      };
      final response = await chatService.sendMessageData(body);
      if (response!["code"] == 201) {
        _messageFocusNode.unfocus();
        message.text = '';
        this.chatData = [];
        this.page = 1;
        getChatMessages();
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e, s) {
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

  Future<void> _pickMultiImage() async {
    try {
      pickedMultiFile = await ImagePicker().pickMultiImage();
      imageUrls = [];
      setState(() {});
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  Future<void> uploadFile() async {
    for (var pickedFile in pickedMultiFile) {
      try {
        var response = await AuthService.uploadFile(File(pickedFile.path),
            resolution: "800x800");
        var res = jsonDecode(response.body);
        if (res["code"] == 200) {
          imageUrls.add(res["url"]);
        }
      } catch (error) {
        print('Error uploading file: $error');
      }
    }
  }

  String formatTime(String time) {
    final currentTime = DateTime.now();
    final messageTime = DateTime.parse(time);

    if (currentTime.difference(messageTime).inDays < 7) {
      return messageTime.weekday == currentTime.weekday
          ? '${Jiffy.parseFromDateTime(DateTime.parse(time + "Z").toLocal()).format(pattern: "hh:mm a")}'
          : '${Jiffy.parseFromDateTime(DateTime.parse(time + "Z").toLocal()).format(pattern: "EEE AT hh:mm a")}';
    } else if (currentTime.year == messageTime.year) {
      return '${Jiffy.parseFromDateTime(DateTime.parse(time + "Z").toLocal()).format(pattern: "MMM dd AT hh:mm a")}';
    } else {
      return '${Jiffy.parseFromDateTime(DateTime.parse(time + "Z").toLocal()).format(pattern: "yyyy MMM dd AT hh:mm a")}';
    }
  }

  final String profilePhotoUrl = 'your_profile_photo_url_here';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _messageFocusNode.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chatName,
                  style: FontConstants.body1,
                ),
                lastSeenTime.isNotEmpty
                    ? Text(
                        'Last seen: ${Jiffy.parseFromDateTime(DateTime.parse(lastSeenTime + "Z").toLocal()).format(pattern: "hh:mm a")}',
                        style: FontConstants.caption1,
                      )
                    : Text(''),
              ],
            ),
          ),
          leading: BackButton(
            color: Colors.black,
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(
                context,
                from == 'chat_history' ? Routes.chat_history : Routes.product,
              );
            },
          ),
        ),
        body: WillPopScope(
          onWillPop: () async {
            Navigator.of(context).pop();
            Navigator.pushNamed(
              context,
              from == 'chat_history' ? Routes.chat_history : Routes.product,
            );
            return true;
          },
          child: Padding(
            padding: const EdgeInsets.only(
              top: 24,
            ),
            child: Column(
              children: [
                Expanded(
                  child: SmartRefresher(
                    header: ClassicHeader(),
                    footer: ClassicFooter(),
                    controller: _refreshController,
                    enablePullDown: true,
                    enablePullUp: false,
                    onRefresh: () async {
                      await getChatMessages();
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: chatData.length,
                      itemBuilder: (BuildContext context, int index) {
                        final message = chatData[index];
                        return Column(
                          children: [
                            Center(
                              child: Text(
                                formatTime(message["created_at"]),
                                style: FontConstants.smallText1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 8,
                                right: 8,
                                bottom: 16,
                              ),
                              child: Align(
                                alignment: message["is_my_message"]
                                    ? Alignment.topRight
                                    : Alignment.topLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: message["is_my_message"]
                                        ? Theme.of(context).primaryColor
                                        : Color(0xffE0E6EC),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(
                                          message["is_my_message"] ? 26 : 0),
                                      topRight: Radius.circular(26.0),
                                      bottomRight: Radius.circular(
                                          message["is_my_message"] ? 0 : 26),
                                      bottomLeft: Radius.circular(26.0),
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 10.0,
                                  ),
                                  margin: EdgeInsets.only(
                                    left: message["is_my_message"] ? 100 : 0,
                                    right: message["is_my_message"] ? 0 : 100,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        message["message_text"],
                                        style: message["is_my_message"]
                                            ? FontConstants.caption4
                                            : FontConstants.caption2,
                                      ),
                                      if (message["is_my_message"])
                                        Icon(
                                          Icons.done_all,
                                          color: message["status"] == 'send'
                                              ? Colors.grey
                                              : Colors.white,
                                          size: 12,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                    top: 8,
                    left: 16,
                    right: 16,
                    bottom: 24,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      // GestureDetector(
                      //   onTap: () {
                      //     _pickMultiImage();
                      //   },
                      //   child: Container(
                      //     margin: EdgeInsets.only(
                      //       right: 16,
                      //     ),
                      //     child: SvgPicture.asset(
                      //       "assets/icons/camera.svg",
                      //       width: 24,
                      //       height: 24,
                      //     ),
                      //   ),
                      // ),
                      Expanded(
                        child: TextFormField(
                          controller: message,
                          focusNode: _messageFocusNode,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          style: FontConstants.body1,
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            hintText: language["Message"] ?? "Message",
                            filled: true,
                            fillColor: ColorConstants.fillcolor,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          sendMessage();
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                            left: 16,
                          ),
                          child: SvgPicture.asset(
                            "assets/icons/send.svg",
                            height: 24,
                            width: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
