import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/providers/bottom_provider.dart';
import 'package:e_commerce/src/providers/cart_provider.dart';
import 'package:e_commerce/src/providers/chat_histories_provider.dart';
import 'package:e_commerce/src/providers/chat_scroll_provider.dart';
import 'package:e_commerce/src/providers/chats_provider.dart';
import 'package:e_commerce/src/providers/message_provider.dart';
import 'package:e_commerce/src/providers/noti_provider.dart';
import 'package:e_commerce/src/providers/socket_provider.dart';
import 'package:e_commerce/src/services/chat_service.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/services/setting_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:e_commerce/routes.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:store_redirect/store_redirect.dart';

class AuthService {
  final crashlytic = new CrashlyticsService();
  final chatService = ChatService();
  final storage = FlutterSecureStorage();

  final Dio dio = Dio();
  CancelToken _cancelToken = CancelToken();

  Future<Map<String, dynamic>?> loginData(Map<String, dynamic> body) async {
    final response = await dio.post(
      ApiConstants.loginUrl,
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ),
      data: jsonEncode(body),
    );

    return response.data;
  }

  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    User? user;
    final GoogleSignInAccount? googleSignInAccount =
        await GoogleSignIn().signIn();
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      authToken = googleSignInAuthentication.idToken!;
      try {
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'The account already exists with a different credential'),
            ),
          );
        } else if (e.code == 'invalid-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Error occurred while accessing credentials. Try again.'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error occurred using Google Sign In. Try again.'),
          ),
        );
      }
    }
    return user;
  }

  static Future<User?> signInWithFacebook(
      {required BuildContext context}) async {
    User? user;
    final LoginResult result = await FacebookAuth.instance.login();
    if (result.accessToken != null) {
      try {
        final AuthCredential credential =
            FacebookAuthProvider.credential(result.accessToken!.token);
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'The account already exists with a different credential'),
            ),
          );
        } else if (e.code == 'invalid-credential') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Error occurred while accessing credentials. Try again.'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error occurred using Facebook Sign In. Try again.'),
          ),
        );
      }
    }
    return user;
  }

  addFCMData(Map<String, dynamic> body) async {
    var token = await storage.read(key: "token") ?? '';
    dio.post(
      '${ApiConstants.fcmUrl}/token',
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ),
      data: jsonEncode(body),
    );
  }

  Future<Map<String, dynamic>?> registerData(Map<String, dynamic> body) async {
    final response = await dio.post(
      ApiConstants.registerUrl,
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ),
      data: jsonEncode(body),
    );

    return response.data;
  }

  Future<Map<String, dynamic>?> forgotPasswordData(
      Map<String, dynamic> body) async {
    final response = await dio.post(
      ApiConstants.forgotPasswordUrl,
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ),
      data: jsonEncode(body),
    );

    return response.data;
  }

  static Future<http.Response> uploadFile(File file,
      {String resolution = ""}) async {
    var uri = Uri.parse(
        '${ApiConstants.imageUploadUrl}${resolution.isNotEmpty ? '?resolution=${resolution}' : ''}');
    var request = http.MultipartRequest('POST', uri);

    var fileStream = http.ByteStream(file.openRead());
    var length = await file.length();
    var multipartFile = http.MultipartFile('file', fileStream, length,
        filename: file.path.split("/").last);
    request.files.add(multipartFile);

    var response = await request.send();
    if (response.statusCode == 200) {
      return http.Response.fromStream(response);
    } else {
      throw Exception('Error uploading file: ${response.statusCode}');
    }
  }

  imageToBase64(File image) async {
    List<int> imageBytes = await image.readAsBytes();
    return base64Encode(imageBytes);
  }

  Future<Map<String, dynamic>?> changePasswordData(
      Map<String, dynamic> body) async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.post(
      ApiConstants.changepasswordUrl,
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ),
      data: jsonEncode(body),
    );

    return response.data;
  }

  Future<Map<String, dynamic>?> verifyTokenData(
      Map<String, dynamic> body) async {
    final response = await dio.post(
      ApiConstants.verifyTokenUrl,
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ),
      data: jsonEncode(body),
    );

    return response.data;
  }

  Future<Map<String, dynamic>?> deleteAccountData() async {
    var token = await storage.read(key: "token") ?? '';
    final response = await dio.delete(
      ApiConstants.deleteAccountUrl,
      options: Options(
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ),
    );

    return response.data;
  }

  void initSocket(String token, context) {
    SocketProvider socketProvider =
        Provider.of<SocketProvider>(context, listen: false);

    socketProvider.socket!.clearListeners();
    socketProvider.socket!.connect();
    socketProvider.socket!.onConnect((_) {
      socketProvider.socket!.emit('join', {'token': token});
      print('Connection established');

      socketProvider.socket!.on("new-message", (data) {
        getChatMessage(data["message_id"], context);
        updateMessageStatus(data["message_id"], context);
        getChatSession(data["chat_id"], context);
      });

      socketProvider.socket!.on("update-message-status", (data) {
        ChatsProvider chatProvider =
            Provider.of<ChatsProvider>(context, listen: false);
        var chats = chatProvider.chats;
        for (var chat in chats) {
          if (chat["message_id"] == data["message_id"]) {
            chat["status"] = data["status"];
          }
        }
        chatProvider.setChats(chats);
        getChatSession(data["chat_id"], context);
      });

      socketProvider.socket!.on("new-invoice", (data) {
        invoiceUrl = data["invoice_url"];
      });
    });

    socketProvider.socket!
        .onDisconnect((_) => print('Connection Disconnection'));
    socketProvider.socket!.onConnectError((err) => print(err));
    socketProvider.socket!.onError((err) => print(err));
  }

  getChatSession(chatId, context) async {
    ChatHistoriesProvider chatHistoriesProvider =
        Provider.of<ChatHistoriesProvider>(context, listen: false);
    try {
      final response = await chatService.getChatSessionData(chatId: chatId);
      if (response!["code"] == 200) {
        List chatHistories = chatHistoriesProvider.chatHistories;
        bool chatExist = false;
        int index = 0;
        for (var chatHistory in chatHistories) {
          if (chatHistory["chat_id"] == chatId) {
            chatExist = true;
            break;
          }
          index++;
        }
        if (!chatExist) {
          chatHistories.insert(0, (response["data"]));
        } else {
          chatHistories[index] = response["data"];
        }
        chatHistoriesProvider.setChatHistories(chatHistories);
      }
    } catch (e, s) {
      crashlytic.myGlobalErrorHandler(e, s);
    }
  }

  getChatMessage(messageId, context) async {
    ChatScrollProvider chatScrollProvider =
        Provider.of<ChatScrollProvider>(context, listen: false);
    ChatsProvider chatProvider =
        Provider.of<ChatsProvider>(context, listen: false);
    try {
      final response =
          await chatService.getChatMessageData(messageId: messageId);
      if (response!["code"] == 200) {
        List chats = chatProvider.chats;
        bool messageExist = false;
        var chatId = 0;
        for (var chat in chats) {
          chatId = chat["chat_id"];
          if (chat["message_id"] == messageId) {
            messageExist = true;
            break;
          }
        }
        if (!messageExist && chatId == response["data"]["chat_id"]) {
          chats.insert(0, (response["data"]));
          chatProvider.setChats(chats);
          if (routeName == '/chat') {
            WidgetsBinding.instance?.addPostFrameCallback((_) {
              chatScrollProvider.chatScrollController.animateTo(
                chatScrollProvider
                    .chatScrollController.position.minScrollExtent,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            });
          }
        }
      }
    } catch (e, s) {
      crashlytic.myGlobalErrorHandler(e, s);
    }
  }

  updateMessageStatus(id, context) async {
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

  getSettings(context) async {
    try {
      var deviceType = Platform.isIOS ? "ios" : "android";
      final settingService = SettingService();
      final response = await settingService.getSettingsData();
      if (response!["code"] == 200) {
        if (deviceType == 'ios') {
          showVersionDialog(response["data"]["ios_version"],
              response["data"]["version_update_message"], context);
        } else {
          showVersionDialog(response["data"]["android_version"],
              response["data"]["version_update_message"], context);
        }

        if (response["data"]["platform_required_signin"] == deviceType) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.login,
            arguments: {
              'first_page': true,
            },
            (route) => false,
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.home,
            (route) => false,
          );
        }
      }
    } catch (e, s) {
      crashlytic.myGlobalErrorHandler(e, s);
    }
  }

  showVersionDialog(version, message, context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String _version = packageInfo.version;
    String _packageName = packageInfo.packageName;

    int _v = int.parse(_version.replaceAll('.', ''));
    int v = int.parse(version.replaceAll('.', ''));

    if (_v < v) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5,
            sigmaY: 5,
          ),
          child: AlertDialog(
            backgroundColor: Colors.white,
            titlePadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            title: Text(
              language["Version Update"] ?? "Version Update",
              style: FontConstants.subheadline1,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
            ),
            content: Text(
              message,
              style: FontConstants.caption2,
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(
                  left: 8,
                  right: 4,
                ),
                child: TextButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  child: Text(
                    language["Cancel"] ?? "Cancel",
                    style: FontConstants.button2,
                  ),
                  onPressed: () {
                    Navigator.of(c).pop();
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 4,
                  right: 8,
                ),
                child: TextButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).primaryColor),
                  ),
                  child: Text(
                    language["Ok"] ?? "Ok",
                    style: FontConstants.button1,
                  ),
                  onPressed: () async {
                    StoreRedirect.redirect(
                      androidAppId: _packageName,
                      iOSAppId: "6469529196",
                    );
                    Navigator.of(c).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  logout(context) async {
    clearData(context);
    getSettings(context);
  }

  clearData(context) async {
    CartProvider cartProvider =
        Provider.of<CartProvider>(context, listen: false);
    cartProvider.addCount(0);

    NotiProvider notiProvider =
        Provider.of<NotiProvider>(context, listen: false);
    notiProvider.addCount(0);

    MessageProvider messageProvider =
        Provider.of<MessageProvider>(context, listen: false);
    messageProvider.addCount(0);

    BottomProvider bottomProvider =
        Provider.of<BottomProvider>(context, listen: false);
    bottomProvider.selectIndex(0);

    SocketProvider socketProvider =
        Provider.of<SocketProvider>(context, listen: false);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool termsandconditions = prefs.getBool("termsandconditions") ?? false;
    String searchhistoriesJson = prefs.getString("searchhistories") ?? "";

    prefs.clear();
    prefs.setBool("termsandconditions", termsandconditions);
    prefs.setString("searchhistories", searchhistoriesJson);
    prefs.setBool('firstLaunch', false);

    await socketProvider.socket!.disconnect();

    await storage.delete(key: "token");
    await FirebaseMessaging.instance.deleteToken();
  }

  void cancelRequest() {
    _cancelToken.cancel('Request canceled');
  }
}
