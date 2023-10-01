import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/services/orders_service.dart';
import 'package:e_commerce/src/utils/format_amount.dart';
import 'package:e_commerce/src/utils/toast.dart';

class HistoryDetailsScreen extends StatefulWidget {
  const HistoryDetailsScreen({super.key});

  @override
  State<HistoryDetailsScreen> createState() => _HistoryDetailsScreenState();
}

class _HistoryDetailsScreenState extends State<HistoryDetailsScreen> {
  int id = 0;
  final orderService = OrderService();
  final ScrollController _orderController = ScrollController();
  Map<String, dynamic> details = {};
  List items = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        id = arguments["id"];
        getOrderDetails();
      }
    });
  }

  @override
  void dispose() {
    orderService.cancelRequest();
    super.dispose();
  }

  getOrderDetails() async {
    try {
      final response = await orderService.getOrderDetailsData(id);
      if (response!["code"] == 200) {
        if (response["data"] != null) {
          details = response["data"];
          print(details);
        }
        if (response["data"]["items"].isNotEmpty) {
          items = response["data"]["items"];
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

  String formatDate(String date) {
    final dateTime = DateTime.parse(date);
    final formattedTime = DateFormat("dd/MM/yyyy").format(dateTime);
    return formattedTime;
  }

  String formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    final formattedTime = DateFormat("hh:mm a").format(dateTime);
    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          language["Details"] ?? "Details",
          style: FontConstants.title1,
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          // width: double.infinity,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          language["Date"] ?? "Date",
                          style: FontConstants.caption1,
                        ),
                        Text(
                          details["created_at"] != null
                              ? formatDate(details["created_at"])
                              : "",
                          style: FontConstants.caption2,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          language["Time"] ?? "Time",
                          style: FontConstants.caption1,
                        ),
                        Text(
                          details["created_at"] != null
                              ? formatTimestamp(details["created_at"])
                              : "",
                          style: FontConstants.caption2,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          language["Name"] ?? "Name",
                          style: FontConstants.caption1,
                        ),
                        Text(
                          details["waiter_name"].toString(),
                          style: FontConstants.caption2,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          language["Order No."] ?? "Order No.",
                          style: FontConstants.caption1,
                        ),
                        Text(
                          details["id"] != null
                              ? formatNumber(details["id"])
                              : "",
                          style: FontConstants.caption2,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          language["Table No."] ?? "Table No.",
                          style: FontConstants.caption1,
                        ),
                        Text(
                          details["table_number"].toString(),
                          style: FontConstants.caption2,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 24,
                  bottom: 8,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    language["Order Information"] ?? "Order Information",
                    style: FontConstants.smallText1,
                  ),
                ),
              ),
              ListView.builder(
                controller: _orderController,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 8,
                          bottom: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(index == 0 ? 10 : 0),
                            topRight: Radius.circular(index == 0 ? 10 : 0),
                            bottomLeft: Radius.circular(
                                index == items.length - 1 ? 10 : 0),
                            bottomRight: Radius.circular(
                                index == items.length - 1 ? 10 : 0),
                          ),
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                      '${ApiConstants.baseUrl}${items[index]["image_url"].toString()}'),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(
                                  left: 4,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${items[index]["item_name"].toString()} x ${items[index]["quantity"].toString()}',
                                      style: FontConstants.body1,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 14,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                language["Amount"] ?? "Amount",
                                                style: FontConstants.caption1,
                                              ),
                                              FormattedAmount(
                                                amount: double.parse(
                                                    items[index]["price"]
                                                        .toString()),
                                                mainTextStyle:
                                                    FontConstants.subheadline1,
                                                decimalTextStyle:
                                                    FontConstants.caption3,
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                language["Total Amount"] ??
                                                    "Total Amount",
                                                style: FontConstants.caption1,
                                              ),
                                              FormattedAmount(
                                                amount: double.parse(
                                                        items[index]["quantity"]
                                                            .toString()) *
                                                    double.parse(items[index]
                                                            ["price"]
                                                        .toString()),
                                                mainTextStyle:
                                                    FontConstants.subheadline1,
                                                decimalTextStyle:
                                                    FontConstants.caption3,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      index < items.length - 1
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
        ),
      ),
    );
  }
}
