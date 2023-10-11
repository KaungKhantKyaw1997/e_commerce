import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/services/orders_service.dart';
import 'package:e_commerce/src/utils/format_amount.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:jiffy/jiffy.dart';

class HistoryDetailsScreen extends StatefulWidget {
  const HistoryDetailsScreen({super.key});

  @override
  State<HistoryDetailsScreen> createState() => _HistoryDetailsScreenState();
}

class _HistoryDetailsScreenState extends State<HistoryDetailsScreen> {
  int id = 0;
  final orderService = OrderService();
  final ScrollController _scrollController = ScrollController();
  Map<String, dynamic> details = {};

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
    _scrollController.dispose();
    super.dispose();
  }

  getOrderDetails() async {
    try {
      final response = await orderService.getOrderDetailsData(id);
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          details = response["data"][0];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          details["order_id"] != null ? formatNumber(details["order_id"]) : "",
          style: FontConstants.title1,
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          width: double.infinity,
          child: Container(
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
                details.containsKey("product_images") &&
                        details["product_images"].isNotEmpty
                    ? Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                                '${ApiConstants.baseUrl}${details["product_images"][0].toString()}'),
                            fit: BoxFit.fill,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.transparent,
                          ),
                        ),
                      )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8,
                  ),
                  child: Text(
                    language["Total Amount"] ?? "Total Amount",
                    style: FontConstants.caption1,
                  ),
                ),
                details["amount"] != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          FormattedAmount(
                            amount: double.parse(details["amount"].toString()),
                            mainTextStyle: FontConstants.title2,
                            decimalTextStyle: FontConstants.subheadline1,
                          ),
                          Text(
                            " Ks",
                            style: FontConstants.subheadline2,
                          ),
                        ],
                      )
                    : Text(""),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8,
                  ),
                  child: const Divider(
                    height: 0,
                    color: Colors.grey,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        language["Date"] ?? "Date",
                        style: FontConstants.caption1,
                      ),
                      Text(
                        details["created_at"] != null
                            ? Jiffy.parse(details["created_at"])
                                .format(pattern: 'dd/MM/yyyy')
                            : "",
                        style: FontConstants.caption2,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        language["Time"] ?? "Time",
                        style: FontConstants.caption1,
                      ),
                      Text(
                        details["created_at"] != null
                            ? Jiffy.parse(details["created_at"])
                                .format(pattern: 'hh:mm a')
                            : "",
                        style: FontConstants.caption2,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        language["Brand"] ?? "Brand",
                        style: FontConstants.caption1,
                      ),
                      Text(
                        details["brand"].toString(),
                        style: FontConstants.caption2,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        language["Model"] ?? "Model",
                        style: FontConstants.caption1,
                      ),
                      Text(
                        details["model"].toString(),
                        style: FontConstants.caption2,
                      ),
                    ],
                  ),
                ),
                details["price"] != null
                    ? Padding(
                        padding: const EdgeInsets.only(
                          top: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              language["Amount"] ?? "Amount",
                              style: FontConstants.caption1,
                            ),
                            FormattedAmount(
                              amount: double.parse(details["price"].toString()),
                              mainTextStyle: FontConstants.caption2,
                              decimalTextStyle: FontConstants.caption2,
                            ),
                          ],
                        ),
                      )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        language["Quantity"] ?? "Quantity",
                        style: FontConstants.caption1,
                      ),
                      Text(
                        details["quantity"].toString(),
                        style: FontConstants.caption2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
