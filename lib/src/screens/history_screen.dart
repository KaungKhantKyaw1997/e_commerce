import 'package:collection/collection.dart';
import 'package:e_commerce/src/widgets/custom_date_range.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/screens/bottombar_screen.dart';
import 'package:e_commerce/src/services/orders_service.dart';
import 'package:e_commerce/src/utils/toast.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final orderService = OrderService();
  final ScrollController _orderController = ScrollController();
  List orders = [];
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    getOrders();
  }

  @override
  void dispose() {
    orderService.cancelRequest();
    _orderController.dispose();
    super.dispose();
  }

  getOrders() async {
    try {
      orders = [];
      String fromDate = DateFormat('yyyy-MM-dd').format(startDate);
      String toDate = DateFormat('yyyy-MM-dd').format(endDate);
      final response =
          await orderService.getOrdersData(fromDate: fromDate, toDate: toDate);
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          List data = response["data"];

          final groupedItemsMap = groupBy(data, (item) {
            final createdAt = item["created_at"].toString();
            return createdAt.split('T')[0];
          });

          groupedItemsMap.forEach((date, items) {
            orders.add({
              "date": date,
              "items": items,
            });
          });
        }
        setState(() {});
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  String formatNumber(int number) {
    return 'ORD-${number.toString().padLeft(6, '0')}';
  }

  String formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    final formattedTime = DateFormat("hh:mm a").format(dateTime);
    return formattedTime;
  }

  _selectDateRange(BuildContext context) async {
    endDate = DateTime.now();
    startDate = DateTime.now();
    return showCustomDateRangePicker(
      context,
      dismissible: true,
      minimumDate: DateTime.now().subtract(const Duration(days: 30)),
      maximumDate: DateTime.now().add(const Duration(days: 30)),
      endDate: endDate,
      startDate: startDate,
      backgroundColor: Colors.white,
      primaryColor: Theme.of(context).primaryColor,
      onApplyClick: (start, end) {
        endDate = end;
        startDate = start;
        getOrders();
      },
      onCancelClick: () {
        endDate = DateTime.now();
        startDate = DateTime.now();
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
        title: Text(
          language["History"] ?? "History",
          style: FontConstants.title1,
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
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          width: double.infinity,
          child: ListView.builder(
            controller: _orderController,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: orders.length,
            itemBuilder: (context, index) {
              String formattedDate = DateFormat("dd/MM/yyyy")
                  .format(DateTime.parse(orders[index]["date"].toString()));

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
                        currentDate == formattedDate
                            ? "Today"
                            : yesterdayDate == formattedDate
                                ? "Yesterday"
                                : formattedDate,
                        style: FontConstants.body1,
                      ),
                    ),
                    const Divider(
                      height: 0,
                      color: Colors.grey,
                    ),
                    ListView.builder(
                      controller: _orderController,
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
                                "id": orders[index]["items"][i]["order_id"],
                              },
                            );
                          },
                          child: Column(
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
                                        Text(
                                          formatNumber(orders[index]["items"][i]
                                              ["order_id"]),
                                          style: FontConstants.body1,
                                        ),
                                        Text(
                                          orders[index]["items"][i]["status"],
                                          style: FontConstants.caption1,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      formatTimestamp(orders[index]["items"][i]
                                              ["created_at"]
                                          .toString()),
                                      style: FontConstants.caption1,
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
      ),
      bottomNavigationBar: const BottomBarScreen(),
    );
  }
}
