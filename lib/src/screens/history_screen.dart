import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/providers/message_provider.dart';
import 'package:e_commerce/src/providers/noti_provider.dart';
import 'package:e_commerce/src/services/auth_service.dart';
import 'package:e_commerce/src/services/chat_service.dart';
import 'package:e_commerce/src/services/crashlytics_service.dart';
import 'package:e_commerce/src/services/notification_service.dart';
import 'package:e_commerce/src/utils/format_amount.dart';
import 'package:e_commerce/src/widgets/custom_date_range.dart';
import 'package:e_commerce/src/widgets/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/screens/bottombar_screen.dart';
import 'package:e_commerce/src/services/order_service.dart';
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
  final chatService = ChatService();
  final storage = FlutterSecureStorage();
  final ScrollController _scrollController = ScrollController();
  TextEditingController search = TextEditingController(text: '');
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List orders = [];
  List data = [];
  int page = 1;
  DateTime? startDate = null;
  DateTime? endDate = null;
  TextEditingController dateRange = TextEditingController(text: '');
  List<String> statuslist = [
    "All",
    "Pending",
    "Processing",
    "Shipped",
    "Delivered",
    "Completed",
    "Cancelled",
    "Refunded",
    "Failed",
    "On Hold",
    "Backordered",
    "Returned"
  ];
  String status = "All";
  bool isApply = false;
  String role = "";
  bool _dataLoaded = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    getData();
    getOrders();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role') ?? "";
      if (role == 'admin') {
        unreadNotifications();
        getTotalUnreadCounts();
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
        }
      }
    }
  }

  getTotalUnreadCounts() async {
    try {
      final response = await chatService.getTotalUnreadCountsData();
      if (response!["code"] == 200) {
        MessageProvider messageProvider =
            Provider.of<MessageProvider>(context, listen: false);
        messageProvider.addCount(response["data"]);
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
          page: page,
          fromDate: fromDate,
          toDate: toDate,
          search: search.text,
          status: status);
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
        startDate = start;
        endDate = end;
        dateRange.text =
            '${DateFormat('dd-MM-yyyy').format(startDate!)} - ${DateFormat('dd-MM-yyyy').format(endDate!)}';
      },
      onCancelClick: () {
        startDate = null;
        endDate = null;
        dateRange.text = '';
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(
                      16,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            orders = [];
                            data = [];
                            page = 1;
                            startDate = null;
                            endDate = null;
                            dateRange.text = "";
                            status = "All";
                            isApply = false;
                            getOrders();
                          },
                          child: Text(
                            language["Reset"] ?? "Reset",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        Text(
                          language["Filters"] ?? "Filters",
                          style: FontConstants.subheadline1,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 22,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            if (!isApply) {
                              startDate = null;
                              endDate = null;
                              dateRange.text = "";
                              status = "All";
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 4,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        language["Date Range"] ?? "Date Range",
                        style: FontConstants.caption1,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    child: TextFormField(
                      controller: dateRange,
                      readOnly: true,
                      style: FontConstants.body2,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: ColorConstants.fillColor,
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
                        suffixIcon: IconButton(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          onPressed: () {
                            _selectDateRange(context);
                          },
                          icon: SvgPicture.asset(
                            "assets/icons/calendar.svg",
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                              Colors.black,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 4,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        language["Status"] ?? "Status",
                        style: FontConstants.caption1,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 24,
                    ),
                    child: CustomDropDown(
                      value: status,
                      fillColor: ColorConstants.fillColor,
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            status = newValue;
                          });
                        }
                      },
                      items: statuslist,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 32,
                    ),
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        orders = [];
                        data = [];
                        page = 1;
                        isApply = true;
                        getOrders();
                      },
                      child: Text(
                        language["Apply"] ?? "Apply",
                        style: FontConstants.button1,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
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
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: TextField(
          controller: search,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          style: FontConstants.body1,
          cursorColor: Colors.black,
          decoration: InputDecoration(
            hintText: language["Search"] ?? "Search",
            filled: true,
            fillColor: ColorConstants.fillColor,
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
            _debounce?.cancel();
            _debounce = Timer(Duration(milliseconds: 300), () {
              orders = [];
              data = [];
              page = 1;
              getOrders();
            });
          },
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              "assets/icons/filter.svg",
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              _showFilterBottomSheet(context);
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
            getTotalUnreadCounts();
          }
          orders = [];
          data = [];
          page = 1;
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
                              thickness: 0.2,
                              color: Colors.grey,
                            ),
                            ListView.builder(
                              controller: _scrollController,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: orders[index]["items"].length,
                              itemBuilder: (context, i) {
                                return GestureDetector(
                                  onTap: () async {
                                    await Navigator.pushNamedAndRemoveUntil(
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
                                        "can_view_address": orders[index]
                                            ["items"][i]["can_view_address"],
                                        "invoice_url": orders[index]["items"][i]
                                            ["invoice_url"],
                                      },
                                      (route) => true,
                                    );

                                    orders = [];
                                    data = [];
                                    page = 1;
                                    search.text = '';
                                    startDate = null;
                                    endDate = null;
                                    dateRange.text = '';
                                    role = "";
                                    _dataLoaded = false;
                                    getOrders();
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
                                                thickness: 0.2,
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
                        SvgPicture.asset(
                          "assets/icons/empty_history.svg",
                          width: 120,
                          height: 120,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16,
                            bottom: 10,
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
