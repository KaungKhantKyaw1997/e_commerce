import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/providers/noti_provider.dart';
import 'package:e_commerce/src/screens/bottombar_screen.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/services/notification_service.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final crashlytic = new CrashlyticsService();
  final notificationService = NotificationService();
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List notifications = [];
  List data = [];
  int page = 1;

  @override
  void initState() {
    super.initState();
    getNotifications();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getNotifications() async {
    try {
      final body = {
        "page": page,
        "per_page": 10,
        "search": "",
      };
      final response = await notificationService.getNotificationsData(body);
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();

      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          notifications = [];
          for (var i = 0; i < response["data"].length; i++) {
            if (response["data"][i]["status"] == "Unread") {
              NotiProvider notiProvider =
                  Provider.of<NotiProvider>(context, listen: false);

              int count = notiProvider.count - 1;
              notiProvider.addCount(count);

              FlutterAppBadger.updateBadgeCount(count);

              updateNotificationsData(response["data"][i]["notification_id"]);
            }
          }

          data += response["data"];
          page++;

          final groupedItemsMap = groupBy(data, (item) {
            return Jiffy.parseFromDateTime(
                    DateTime.parse(item["created_at"] + "Z").toLocal())
                .format(pattern: 'dd/MM/yyyy');
          });

          groupedItemsMap.forEach((date, items) {
            notifications.add({
              "date": date,
              "items": items,
            });
          });
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

  updateNotificationsData(id) {
    final body = {
      "status": "Read",
    };
    notificationService.updateNotificationsData(body, id);
  }

  @override
  Widget build(BuildContext context) {
    String currentDate =
        DateFormat("dd/MM/yyyy").format(DateTime.now()).toString();
    String yesterdayDate = DateFormat("dd/MM/yyyy")
        .format(DateTime.now().subtract(const Duration(days: 1)))
        .toString();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            language["Notification"] ?? "Notification",
            style: FontConstants.title2,
          ),
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
          data = [];
          await getNotifications();
        },
        onLoading: () async {
          await getNotifications();
        },
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            width: double.infinity,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                String date = notifications[index]["date"];

                return Container(
                  margin: const EdgeInsets.only(
                    bottom: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 8,
                          bottom: 4,
                        ),
                        child: Text(
                          currentDate == date
                              ? "Today"
                              : yesterdayDate == date
                                  ? "Yesterday"
                                  : date,
                          style: FontConstants.caption2,
                        ),
                      ),
                      const Divider(
                        height: 0,
                        color: Colors.grey,
                      ),
                      ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: notifications[index]["items"].length,
                        itemBuilder: (context, i) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  bottom: 8,
                                  top: 8,
                                ),
                                color: Colors.transparent,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            notifications[index]["items"][i]
                                                ["title"],
                                            overflow: TextOverflow.ellipsis,
                                            style: FontConstants.body1,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                right: 4,
                                              ),
                                              child: Text(
                                                Jiffy.parseFromDateTime(DateTime
                                                            .parse(notifications[
                                                                            index]
                                                                        [
                                                                        "items"][i]
                                                                    [
                                                                    "created_at"] +
                                                                "Z")
                                                        .toLocal())
                                                    .format(pattern: 'hh:mm a'),
                                                style: FontConstants.caption1,
                                              ),
                                            ),
                                            notifications[index]["items"][i]
                                                        ["status"] ==
                                                    "Unread"
                                                ? Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.orangeAccent,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Text(
                                      notifications[index]["items"][i]
                                          ["message"],
                                      style: FontConstants.caption1,
                                    ),
                                  ],
                                ),
                              ),
                              i < notifications[index]["items"].length - 1
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
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomBarScreen(),
    );
  }
}
