import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/utils/loading.dart';
import 'package:flutter/material.dart';
import 'package:e_commerce/global.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/services/orders_service.dart';
import 'package:e_commerce/src/utils/format_amount.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jiffy/jiffy.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  List statuslist = [
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
  String status = "";
  String role = "";

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        id = arguments["id"];
        status = arguments["status"];
        getData();
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

  getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role') ?? "";
    });
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

  updateOrder() async {
    showLoadingDialog(context);
    try {
      final body = {
        "status": status,
      };

      final response =
          await orderService.updateOrderData(details["order_id"], body);
      Navigator.pop(context);
      if (response["code"] == 200) {
        ToastUtil.showToast(response["code"], response["message"]);
        setState(() {});
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      print('Error: $e');
      Navigator.pop(context);
    }
  }

  void _showSelectionBottomSheet(BuildContext context) {
    String _status = status;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              height: double.infinity,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: 45,
                      height: 4,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: statuslist.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(
                            statuslist[index],
                            style: FontConstants.body1,
                          ),
                          trailing: _status == statuslist[index]
                              ? SvgPicture.asset(
                                  "assets/icons/check.svg",
                                  width: 24,
                                  height: 24,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.black,
                                    BlendMode.srcIn,
                                  ),
                                )
                              : null,
                          onTap: () {
                            setState(() {
                              _status = statuslist[index];
                            });
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                    ),
                    child: const Divider(
                      height: 0,
                      color: Colors.grey,
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
                        status = _status;
                        Navigator.pop(context);
                        updateOrder();
                      },
                      child: Text(
                        language["Order"] ?? "Order",
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          '#${details["order_id"]}',
          style: FontConstants.title1,
        ),
        leading: BackButton(
          color: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.pushNamed(
              context,
              Routes.history,
            );
          },
        ),
        actions: [
          role == 'admin'
              ? IconButton(
                  icon: SvgPicture.asset(
                    "assets/icons/check.svg",
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: () {
                    _showSelectionBottomSheet(context);
                  },
                )
              : Container(),
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop();
          Navigator.pushNamed(
            context,
            Routes.history,
          );
          return true;
        },
        child: SingleChildScrollView(
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
                              amount:
                                  double.parse(details["amount"].toString()),
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
                                amount:
                                    double.parse(details["price"].toString()),
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
                  role == 'admin'
                      ? Padding(
                          padding: const EdgeInsets.only(
                            top: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                language["Status"] ?? "Status",
                                style: FontConstants.caption1,
                              ),
                              Text(
                                status,
                                style: FontConstants.caption2,
                              ),
                            ],
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
