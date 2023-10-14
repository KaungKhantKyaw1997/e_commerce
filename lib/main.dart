import 'package:e_commerce/src/screens/history_screen.dart';
import 'package:e_commerce/src/services/local_notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:e_commerce/src/providers/noti_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:e_commerce/palette.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/providers/bottom_provider.dart';
import 'package:e_commerce/src/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationService.setup();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  int cartCount = prefs.getInt('cartCount') ?? 0;
  int notiCount = prefs.getInt('notiCount') ?? 0;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BottomProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider(cartCount)),
        ChangeNotifierProvider(create: (context) => NotiProvider(notiCount)),
      ],
      child: MyApp(),
    ),
  );
}

Future<void> backgroundMessageHandler(RemoteMessage message) async {
  // Handle the background notification here
  print("Handling background message: ${message.data}");
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        LocalNotificationService.display(
          message.notification!.title.toString(),
          message.notification!.body.toString(),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('A new onMessageOpenedApp event was published!');
      Navigator.pushNamed(context, Routes.noti);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Watch Vault by Diggie',
      theme: ThemeData(
        primarySwatch: Palette.kToDark,
        scaffoldBackgroundColor: Color(0xFFF1F3F6),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      initialRoute: Routes.splash,
      routes: Routes.routes,
    );
  }
}
