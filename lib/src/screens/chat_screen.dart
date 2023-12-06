import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/providers/bottom_provider.dart';
import 'package:e_commerce/src/providers/chat_scroll_provider.dart';
import 'package:e_commerce/src/providers/chats_provider.dart';
import 'package:e_commerce/src/providers/message_provider.dart';
import 'package:e_commerce/src/services/auth_service.dart';
import 'package:e_commerce/src/services/chat_service.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final crashlytic = new CrashlyticsService();
  final chatService = ChatService();
  ScrollController _imageController = ScrollController();
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
  String profileImage = '';
  int page = 1;
  String status = '';
  String role = "";
  AppLifecycleState? _lastLifecycleState;
  BottomProvider? _bottomProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);

    Future.delayed(Duration.zero, () {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        receiverId = arguments["receiver_id"] ?? 0;
        chatId = arguments["chat_id"] ?? 0;
        chatName = arguments["chat_name"] ?? '';
        profileImage = arguments["profile_image"] ?? '';
      }
      getData();
      getLastActiveAt(arguments!["user_id"]);
      getChatMessages();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bottomProvider ??= Provider.of<BottomProvider>(context, listen: false);
  }

  @override
  void dispose() {
    if (role == 'admin' && _bottomProvider != null) {
      if (previousRouteName == '/history') {
        _bottomProvider!.selectIndex(0);
      } else if (previousRouteName == '/noti') {
        _bottomProvider!.selectIndex(1);
      } else if (previousRouteName == '/setting') {
        _bottomProvider!.selectIndex(3);
      }
    }

    WidgetsBinding.instance?.removeObserver(this);
    _imageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == _lastLifecycleState) {
      return;
    }

    _lastLifecycleState = state;
    if (state == AppLifecycleState.resumed) {
      resumeChatMessages();
    }
  }

  getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role') ?? "";
    });
  }

  getLastActiveAt(userId) async {
    try {
      final response =
          await chatService.getLastActiveAtData(int.parse(userId.toString()));
      if (response!["code"] == 200) {
        lastSeenTime = response["data"] ?? "";
        setState(() {});
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e, s) {
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

  resumeChatMessages() async {
    ChatScrollProvider chatScrollProvider =
        Provider.of<ChatScrollProvider>(context, listen: false);
    ChatsProvider chatProvider =
        Provider.of<ChatsProvider>(context, listen: false);

    try {
      final response = await chatService.getChatMessagesData(
          chatId: chatId,
          receiverId: receiverId,
          page: 1,
          perPage: 999999,
          status: 'sent');
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          List chats = chatProvider.chats;
          var message_id_list = chats.map((e) => e["message_id"]).toList();

          for (var message in (response["data"] as List).reversed.toList()) {
            if (!message_id_list.contains(message["message_id"])) {
              chats.insert(0, (message));
              message_id_list.add(message["message_id"]);
              updateMessageStatus(message["message_id"]);
            }
          }
          chatProvider.setChats(chats);
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            chatScrollProvider.chatScrollController.animateTo(
              chatScrollProvider.chatScrollController.position.minScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        }
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e, s) {
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

  getChatMessages({String type = ''}) async {
    ChatsProvider chatProvider =
        Provider.of<ChatsProvider>(context, listen: false);

    try {
      final response = await chatService.getChatMessagesData(
          chatId: chatId, receiverId: receiverId, page: page);
      _refreshController.loadComplete();

      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          for (var message in response["data"]) {
            if ((message["status"] == "sent" ||
                    message["status"] == "delivered") &&
                !message["is_my_message"]) {
              updateMessageStatus(message["message_id"]);
            }
          }

          List chats = chatProvider.chats;
          if (type == 'onload') {
            chats += response["data"];
          } else {
            chats = response["data"];
          }
          chatProvider.setChats(chats);
          page++;
        }
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e, s) {
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

  updateMessageStatus(id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String role = prefs.getString('role') ?? "";
    MessageProvider messageProvider =
        Provider.of<MessageProvider>(context, listen: false);

    if (role == 'agent' || role == 'user') {
      int count = messageProvider.count - 1;
      messageProvider.addCount(count);
      final body = {
        "status": "read",
      };
      chatService.updateMessageStatusData(body, id);
    }
  }

  sendMessage() async {
    ChatScrollProvider chatScrollProvider =
        Provider.of<ChatScrollProvider>(context, listen: false);
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
        imageUrls = [];
        page = 1;
        await getChatMessages();
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          chatScrollProvider.chatScrollController.animateTo(
            chatScrollProvider.chatScrollController.position.minScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
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
      if (pickedMultiFile.isNotEmpty) {
        message.text = '';
        await uploadFile();
        sendMessage();
      }
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

  deleteMessage(messageId) async {
    ChatsProvider chatProvider =
        Provider.of<ChatsProvider>(context, listen: false);
    try {
      final response = await chatService.deleteMessageData(messageId);
      if (response!["code"] == 204) {
        List chats = (chatProvider.chats as List)
            .where((element) => element["message_id"] != messageId)
            .toList();
        chatProvider.setChats(chats);
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

  isMyMessage(message) {
    return message["image_urls"].isNotEmpty
        ? GridView.builder(
            controller: _imageController,
            shrinkWrap: true,
            itemCount: message["image_urls"].length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisExtent: MediaQuery.of(context).size.width * 0.75,
              childAspectRatio: 2 / 1,
              crossAxisSpacing: 8,
              crossAxisCount: 1,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  left: 100,
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.image_preview,
                      arguments: {
                        "image_url":
                            '${ApiConstants.baseUrl}${message["image_urls"][index].toString()}'
                      },
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                            '${ApiConstants.baseUrl}${message["image_urls"][index].toString()}'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.transparent,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(
                        message["status"] == 'sent'
                            ? Icons.done
                            : Icons.done_all,
                        color: message["status"] == 'read'
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                        size: 12,
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        : Align(
            alignment: Alignment.bottomRight,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(26),
                  topRight: Radius.circular(26),
                  bottomLeft: Radius.circular(26),
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              margin: EdgeInsets.only(
                left: 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message["message_text"],
                    style: FontConstants.caption4,
                  ),
                  Icon(
                    message["status"] == 'sent' ? Icons.done : Icons.done_all,
                    color: message["status"] == 'read'
                        ? Colors.white
                        : Colors.grey,
                    size: 12,
                  ),
                ],
              ),
            ),
          );
  }

  isNotMyMessage(message) {
    return message["image_urls"].isNotEmpty
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  right: 8,
                ),
                child: message["profile_image"].isEmpty
                    ? CircleAvatar(
                        radius: 10,
                        backgroundImage:
                            AssetImage("assets/images/profile.png"),
                        backgroundColor: ColorConstants.fillColor,
                      )
                    : CircleAvatar(
                        radius: 10,
                        backgroundImage: NetworkImage(
                            '${message["profile_image"].startsWith("/images") ? ApiConstants.baseUrl : ""}${message["profile_image"]}'),
                      ),
              ),
              Expanded(
                child: GridView.builder(
                  controller: _imageController,
                  shrinkWrap: true,
                  itemCount: message["image_urls"].length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisExtent: MediaQuery.of(context).size.width * 0.75,
                    childAspectRatio: 2 / 1,
                    crossAxisSpacing: 8,
                    crossAxisCount: 1,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: 100,
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.image_preview,
                            arguments: {
                              "image_url":
                                  '${ApiConstants.baseUrl}${message["image_urls"][index].toString()}'
                            },
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                  '${ApiConstants.baseUrl}${message["image_urls"][index].toString()}'),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  right: 8,
                ),
                child: message["profile_image"].isEmpty
                    ? CircleAvatar(
                        radius: 10,
                        backgroundImage:
                            AssetImage("assets/images/profile.png"),
                        backgroundColor: ColorConstants.fillColor,
                      )
                    : CircleAvatar(
                        radius: 10,
                        backgroundImage: NetworkImage(
                            '${message["profile_image"].startsWith("/images") ? ApiConstants.baseUrl : ""}${message["profile_image"]}'),
                      ),
              ),
              Flexible(
                fit: FlexFit.loose,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xffE0E6EC),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(26),
                      bottomRight: Radius.circular(26),
                      bottomLeft: Radius.circular(26),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10.0,
                  ),
                  margin: EdgeInsets.only(
                    right: 100,
                  ),
                  child: Text(
                    message["message_text"],
                    style: FontConstants.caption2,
                    softWrap: true,
                  ),
                ),
              ),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    ChatScrollProvider chatScrollProvider =
        Provider.of<ChatScrollProvider>(context, listen: true);
    ChatsProvider chatProvider =
        Provider.of<ChatsProvider>(context, listen: true);

    List<String> profiles = [];
    if (profileImage.isNotEmpty) {
      profiles =
          profileImage.split(",").map((e) => e.trim()).toList().cast<String>();
    }

    return GestureDetector(
      onTap: () {
        _messageFocusNode.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  right: 8,
                ),
                child: Stack(
                  children: [
                    Center(
                      child: ClipOval(
                        child: Container(
                          width: 40,
                          height: 40,
                          color: ColorConstants.fillColor,
                          child: profiles.isNotEmpty
                              ? Stack(
                                  children: <Widget>[
                                    Positioned(
                                      left: 0,
                                      child: profiles[0].isNotEmpty
                                          ? Image.network(
                                              '${profiles[0].startsWith("/images") ? ApiConstants.baseUrl : ""}${profiles[0]}',
                                              width: role == 'admin' ? 20 : 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              'assets/images/profile.png',
                                              width: role == 'admin' ? 20 : 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                    if (role == 'admin')
                                      Positioned(
                                        right: 0,
                                        child: profiles[1].isNotEmpty
                                            ? Image.network(
                                                '${profiles[1].startsWith("/images") ? ApiConstants.baseUrl : ""}${profiles[1]}',
                                                width: 20,
                                                height: 40,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.asset(
                                                'assets/images/profile.png',
                                                width: 20,
                                                height: 40,
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                  ],
                                )
                              : Image.asset(
                                  'assets/images/profile.png',
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chatName,
                      style: FontConstants.body1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (lastSeenTime.isNotEmpty)
                      Text(
                        'Last seen: ${Jiffy.parseFromDateTime(DateTime.parse(lastSeenTime + "Z").toLocal()).format(pattern: "hh:mm a")}',
                        style: FontConstants.caption1,
                      ),
                  ],
                ),
              ),
            ],
          ),
          titleSpacing: 0,
          leadingWidth: 50,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SmartRefresher(
                footer: ClassicFooter(),
                controller: _refreshController,
                enablePullDown: false,
                enablePullUp: true,
                onLoading: () async {
                  await getChatMessages(type: 'onload');
                },
                child: ListView.builder(
                  controller: chatScrollProvider.chatScrollController,
                  itemCount: chatProvider.chats.length,
                  reverse: true,
                  itemBuilder: (BuildContext context, int index) {
                    final message = chatProvider.chats[index];
                    return Column(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              bottom: 16,
                            ),
                            child: Text(
                              formatTime(message["created_at"]),
                              style: FontConstants.smallText1,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: 8,
                            right: 8,
                            bottom: 16,
                          ),
                          child: Align(
                            alignment: message["is_my_message"]
                                ? Alignment.topRight
                                : Alignment.topLeft,
                            child: !message["is_my_message"]
                                ? Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 26,
                                          bottom: 2,
                                        ),
                                        child: Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Text(
                                            message["sender_name"],
                                            style: FontConstants.smallText1,
                                          ),
                                        ),
                                      ),
                                      isNotMyMessage(message),
                                    ],
                                  )
                                : Slidable(
                                    key: const ValueKey(0),
                                    endActionPane: ActionPane(
                                      motion: const BehindMotion(),
                                      children: [
                                        SlidableAction(
                                          onPressed: (BuildContext context) {
                                            deleteMessage(
                                                message["message_id"]);
                                          },
                                          backgroundColor: Colors.transparent,
                                          foregroundColor:
                                              ColorConstants.redColor,
                                          icon: Icons.delete,
                                        ),
                                      ],
                                      extentRatio: 0.15,
                                    ),
                                    child: isMyMessage(message),
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
                  GestureDetector(
                    onTap: () {
                      _pickMultiImage();
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                        right: 16,
                      ),
                      child: SvgPicture.asset(
                        "assets/icons/gallery.svg",
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: message,
                      focusNode: _messageFocusNode,
                      keyboardType: TextInputType.multiline,
                      style: FontConstants.body1,
                      cursorColor: Colors.black,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: language["Message"] ?? "Message",
                        filled: true,
                        fillColor: ColorConstants.fillColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (message.text.isNotEmpty) {
                        imageUrls = [];
                        sendMessage();
                      }
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
    );
  }
}
