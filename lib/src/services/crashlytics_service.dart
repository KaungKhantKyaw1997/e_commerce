import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CrashlyticsService {
  Future<void> myGlobalErrorHandler(dynamic e, StackTrace s) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userName = prefs.getString("username") ?? "";
    if (userName != "") {
      FirebaseCrashlytics.instance.setUserIdentifier(userName);
    }
    FirebaseCrashlytics.instance.recordError(e, s, reason: 'non-fatal error');
  }
}
