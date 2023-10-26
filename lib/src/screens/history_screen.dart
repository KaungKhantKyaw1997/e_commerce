import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:e_commerce/src/providers/noti_provider.dart';
import 'package:e_commerce/src/services/auth_service.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/services/notification_service.dart';
import 'package:e_commerce/src/utils/format_amount.dart';
import 'package:e_commerce/src/widgets/custom_date_range.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/screens/bottombar_screen.dart';
import 'package:e_commerce/src/services/orders_service.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final crashlytic = new CrashlyticsService();
  final orderService = OrderService();
  final authService = AuthService();
  final notificationService = NotificationService();
  final storage = FlutterSecureStorage();
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List orders = [];
  List data = [];
  int page = 1;
  DateTime? startDate = null;
  DateTime? endDate = null;
  String role = "";
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    getData();
    getOrders();
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
      if (role == 'admin') {
        unreadNotifications();
      }
    });
  }

  unreadNotifications() async {
    try {
      final response = await notificationService.unreadNotificationsData();
      if (response!["code"] == 200) {
        NotiProvider notiProvider =
            Provider.of<NotiProvider>(context, listen: false);
        notiProvider.addCount(response["data"]);
        FlutterAppBadger.updateBadgeCount(response["data"]);
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

  getOrders() async {
    try {
      String fromDate = "";
      if (startDate != null) {
        fromDate = DateFormat('yyyy-MM-dd').format(startDate!);
      }

      String toDate = "";
      if (endDate != null) {
        toDate = DateFormat('yyyy-MM-dd').format(endDate!);
      }

      final response = await orderService.getOrdersData(
          page: page, fromDate: fromDate, toDate: toDate);
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();

      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          orders = [];

          data += response["data"];
          page++;

          final groupedItemsMap = groupBy(data, (item) {
            return Jiffy.parseFromDateTime(
                    DateTime.parse(item["created_at"] + "Z").toLocal())
                .format(pattern: 'dd/MM/yyyy');
          });

          groupedItemsMap.forEach((date, items) {
            orders.add({
              "date": date,
              "items": items,
            });
          });
        }
        setState(() {
          if (orders.isEmpty) {
            _dataLoaded = true;
          }
        });
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
      setState(() {});
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

  _selectDateRange(BuildContext context) async {
    return showCustomDateRangePicker(
      context,
      dismissible: true,
      minimumDate: DateTime.now().subtract(Duration(days: 30 * 12 * 1)),
      maximumDate: DateTime.now(),
      endDate: endDate,
      startDate: startDate,
      backgroundColor: Colors.white,
      primaryColor: Theme.of(context).primaryColor,
      onApplyClick: (start, end) {
        page = 1;
        orders = [];
        data = [];
        endDate = end;
        startDate = start;
        getOrders();
      },
      onCancelClick: () {
        page = 1;
        orders = [];
        data = [];
        endDate = null;
        startDate = null;
        getOrders();
      },
    );
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
            role == "admin" || role == 'agent'
                ? language["Order"] ?? "Order"
                : language["History"] ?? "History",
            style: FontConstants.title2,
          ),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              "assets/icons/calendar.svg",
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              _selectDateRange(context);
            },
          ),
        ],
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
          if (role == 'admin') {
            unreadNotifications();
          }
          page = 1;
          data = [];
          await getOrders();
        },
        onLoading: () async {
          await getOrders();
        },
        child: orders.isNotEmpty
            ? SingleChildScrollView(
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
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      String date = orders[index]["date"];

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
                              itemCount: orders[index]["items"].length,
                              itemBuilder: (context, i) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      Routes.history_details,
                                      arguments: {
                                        "order_id": orders[index]["items"][i]
                                            ["order_id"],
                                        "user_name": orders[index]["items"][i]
                                            ["user_name"],
                                        "phone": orders[index]["items"][i]
                                            ["phone"],
                                        "email": orders[index]["items"][i]
                                            ["email"],
                                        "home_address": orders[index]["items"]
                                            [i]["home_address"],
                                        "street_address": orders[index]["items"]
                                            [i]["street_address"],
                                        "city": orders[index]["items"][i]
                                            ["city"],
                                        "state": orders[index]["items"][i]
                                            ["state"],
                                        "postal_code": orders[index]["items"][i]
                                            ["postal_code"],
                                        "country": orders[index]["items"][i]
                                            ["country"],
                                        "township": orders[index]["items"][i]
                                            ["township"],
                                        "ward": orders[index]["items"][i]
                                            ["ward"],
                                        "note": orders[index]["items"][i]
                                            ["note"],
                                        "order_total": orders[index]["items"][i]
                                            ["order_total"],
                                        "item_counts": orders[index]["items"][i]
                                            ["item_counts"],
                                        "payment_type": orders[index]["items"]
                                            [i]["payment_type"],
                                        "payslip_screenshot_path": orders[index]
                                                ["items"][i]
                                            ["payslip_screenshot_path"],
                                        "created_at": orders[index]["items"][i]
                                            ["created_at"],
                                        "status": orders[index]["items"][i]
                                            ["status"],
                                        "commission_amount": orders[index]
                                            ["items"][i]["commission_amount"],
                                        "symbol": orders[index]["items"][i]
                                            ["symbol"],
                                      },
                                    );
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.baseline,
                                              textBaseline:
                                                  TextBaseline.alphabetic,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '#${orders[index]["items"][i]["order_id"]}',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: FontConstants.body1,
                                                  ),
                                                ),
                                                Text(
                                                  orders[index]["items"][i]
                                                      ["status"],
                                                  style: FontConstants.caption1,
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.baseline,
                                              textBaseline:
                                                  TextBaseline.alphabetic,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    Jiffy.parseFromDateTime(
                                                            DateTime.parse(orders[index]
                                                                            [
                                                                            "items"][i]
                                                                        [
                                                                        "created_at"] +
                                                                    "Z")
                                                                .toLocal())
                                                        .format(
                                                            pattern: 'hh:mm a'),
                                                    style:
                                                        FontConstants.caption1,
                                                  ),
                                                ),
                                                FormattedAmount(
                                                  amount: double.parse(
                                                      orders[index]["items"][i]
                                                              ["order_total"]
                                                          .toString()),
                                                  mainTextStyle:
                                                      FontConstants.caption2,
                                                  decimalTextStyle:
                                                      FontConstants.caption2,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      i < orders[index]["items"].length - 1
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
                      );
                    },
                  ),
                ),
              )
            : _dataLoaded
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).orientation ==
                                  Orientation.landscape
                              ? 150
                              : 300,
                          height: MediaQuery.of(context).orientation ==
                                  Orientation.landscape
                              ? 150
                              : 300,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/no_data.png'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 4,
                          ),
                          child: Text(
                            "Empty History",
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
                            "There is no data...",
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
      bottomNavigationBar: const BottomBarScreen(),
    );
  }
}
