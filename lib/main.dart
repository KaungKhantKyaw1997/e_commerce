import 'package:camera/camera.dart';
import 'package:e_commerce/agent_palette.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/socket_manager.dart';
import 'package:e_commerce/src/providers/chat_histories_provider.dart';
import 'package:e_commerce/src/providers/chat_scroll_provider.dart';
import 'package:e_commerce/src/providers/chats_provider.dart';
import 'package:e_commerce/src/providers/role_provider.dart';
import 'package:e_commerce/src/providers/socket_provider.dart';
import 'package:e_commerce/src/services/chat_service.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/services/local_notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:e_commerce/src/providers/noti_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:e_commerce/palette.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/providers/bottom_provider.dart';
import 'package:e_commerce/src/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'src/screens/scan_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  int cartCount = prefs.getInt('cartCount') ?? 0;
  int notiCount = prefs.getInt('notiCount') ?? 0;
  // final cameras = await availableCameras();
  // final firstCamera = cameras.first;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ChatScrollProvider()),
        ChangeNotifierProvider(create: (context) => SocketProvider()),
        ChangeNotifierProvider(create: (context) => ChatHistoriesProvider()),
        ChangeNotifierProvider(create: (context) => ChatsProvider()),
        ChangeNotifierProvider(create: (context) => RoleProvider()),
        ChangeNotifierProvider(create: (context) => BottomProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider(cartCount)),
        ChangeNotifierProvider(create: (context) => NotiProvider(notiCount)),
      ],
      child: MyApp(),
      // child: MyApp(
      //   camera: firstCamera,
      // ),
    ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

Future<void> backgroundMessageHandler(RemoteMessage message) async {
  // Handle the background notification here
  print("Handling background message: ${message.data}");
}

class MyApp extends StatefulWidget {
  // final CameraDescription camera;

  const MyApp({
    Key? key,
    // required this.camera,
  }) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final crashlytic = new CrashlyticsService();
  final chatService = ChatService();

  @override
  void initState() {
    super.initState();
    SocketManager socketManager = SocketManager(context);
    WidgetsBinding.instance?.addObserver(socketManager);
    LocalNotificationService.setup(context);

    // FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
    //   print("Refreshed Token: $token");
    // });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        String chatId =
            message.data.isNotEmpty ? message.data["chat_id"].toString() : '0';

        if (message.notification!.title!.isNotEmpty &&
            message.notification!.body!.isNotEmpty) {
          if (ModalRoute.of(context)!.settings.name != '/chat' &&
              ModalRoute.of(context)!.settings.name != '/noti') {
            LocalNotificationService.display(
              message.notification!.title.toString(),
              message.notification!.body.toString(),
              chatId,
            );
          }
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String role = prefs.getString('role') ?? "";

      BottomProvider bottomProvider =
          Provider.of<BottomProvider>(context, listen: false);

      if (message.notification != null) {
        int chatId = message.data.isNotEmpty
            ? int.parse(message.data["chat_id"].toString())
            : 0;

        if (chatId != 0) {
          try {
            final response =
                await chatService.getChatSessionData(chatId: chatId);
            if (response!["code"] == 200) {
              if (role == 'admin') {
                bottomProvider.selectIndex(2);
              }

              navigatorKey.currentState!.pushNamed(
                Routes.chat,
                arguments: {
                  'chat_id': response["data"]["chat_id"],
                  'chat_name': response["data"]["chat_name"],
                  'profile_image': response["data"]["profile_image"],
                  'user_id': (response["data"]["chat_participants"] as List)
                      .where((element) => !element["is_me"])
                      .map<String>(
                          (participant) => participant["user_id"].toString())
                      .toList()[0],
                  'from': role == 'admin' ? 'bottom' : 'home',
                },
              );
            }
          } catch (e, s) {
            crashlytic.myGlobalErrorHandler(e, s);
          }
        } else {
          bottomProvider.selectIndex(role == 'admin' ? 1 : 3);
          navigatorKey.currentState!.pushNamed(Routes.noti);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    RoleProvider roleProvider =
        Provider.of<RoleProvider>(context, listen: true);

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Watch Vault by Diggie',
      theme: ThemeData(
        primarySwatch: roleProvider.role == 'agent'
            ? AgentPalette.kToDark
            : Palette.kToDark,
        scaffoldBackgroundColor: Color(0xFFF1F3F6),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      initialRoute: Routes.splash,
      routes: {
        ...Routes.routes,
        // "/scan": (context) => ScanScreen(camera: widget.camera),
      },
    );
  }
}
