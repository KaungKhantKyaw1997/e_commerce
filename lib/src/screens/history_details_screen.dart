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
import 'package:url_launcher/url_launcher.dart';

class HistoryDetailsScreen extends StatefulWidget {
  const HistoryDetailsScreen({super.key});

  @override
  State<HistoryDetailsScreen> createState() => _HistoryDetailsScreenState();
}

class _HistoryDetailsScreenState extends State<HistoryDetailsScreen> {
  final orderService = OrderService();
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
  String status = "Pending";
  String role = "";
  Map<String, dynamic> orderData = {
    "order_id": 0,
    "user_name": "",
    "phone": "",
    "email": "",
    "home_address": "",
    "street_address": "",
    "city": "",
    "state": "",
    "postal_code": "",
    "country": "",
    "township": "",
    "ward": "",
    "note": "",
    "status": "Pending",
    "order_total": 0.0,
    "item_counts": 0,
    "payment_type": "Cash on Delivery",
    "payslip_screenshot_path": "",
    "created_at": ""
  };
  List<Map<String, dynamic>> orderItems = [];

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      getData();
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (arguments != null) {
        getOrderDetails(arguments["order_id"]);
        setState(() {
          this.orderData = arguments;
          this.status = this.orderData['status'];
        });
      }
    });
  }

  @override
  void dispose() {
    orderService.cancelRequest();
    super.dispose();
  }

  getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role') ?? "";
    });
  }

  getOrderDetails(int order_id) async {
    try {
      final response = await orderService.getOrderDetailsData(order_id);
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          orderItems = (response["data"] as List).cast<Map<String, dynamic>>();
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
          await orderService.updateOrderData(orderData["order_id"], body);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Track Order',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () =>
                Navigator.of(context).popAndPushNamed(Routes.history)),
      ),
      body: Container(
        // color: Colors.white,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orderData["created_at"].isEmpty
                            ? ""
                            : Jiffy.parseFromDateTime(DateTime.parse(
                                        orderData["created_at"] + "Z")
                                    .toLocal())
                                .format(pattern: "dd MMM yyyy, hh:mm a"),
                        style: TextStyle(
                          color: Color(0xff7B7B7B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            'Order ID: #${orderData["order_id"]}',
                            style: TextStyle(
                              color: Color(0xff7B7B7B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Amt: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              FormattedAmount(
                                amount: orderData["order_total"],
                                mainTextStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                decimalTextStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      // New code begins here
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Order Status:",
                            style: TextStyle(
                              color: Color(0xff7B7B7B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          role == "admin"
                              ? Container(
                                  width: 150,
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      isDense: true,
                                      // labelText: "Order Status",
                                      filled: true,
                                      fillColor: Colors.white,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade400,
                                            width: 2),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide(
                                            color: Colors.green, width: 2),
                                      ),
                                    ),
                                    value: status,
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors
                                          .green, // Change color to suit your theme
                                    ),
                                    iconSize: 24,
                                    elevation: 16,
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 16), // Change text style
                                    onChanged: (newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          status = newValue;
                                          orderData["status"] = newValue;
                                        });
                                        updateOrder();
                                      }
                                    },
                                    items: statuslist
                                        .map<DropdownMenuItem<String>>((value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                              0.0), // Adds padding to the item
                                          child: Text(value),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                )
                              : Text(
                                  status,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ],
                      ),
                      // New code ends here
                      // SizedBox(height: 15),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                      ),
                      child: ListView(
                        // itemCount: orderData["item_counts"],
                        // itemBuilder: (context, index) {
                        //   return ListTile(
                        //     title: Text('Item ${index + 1} Details'),
                        //     subtitle: Text('More details about item...'),
                        //   );
                        // },
                        children: [
                          role == "admin"
                              ? Container(
                                  padding: const EdgeInsets.all(20),
                                  margin: const EdgeInsets.only(
                                      bottom:
                                          20), // Optional, to give some spacing between this container and the others
                                  decoration: BoxDecoration(
                                    color: Color(0xff36936C),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // User Name
                                        Row(
                                          children: [
                                            Icon(Icons.person_outline,
                                                color: Colors.white, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              'Ordered by: ${orderData["user_name"]}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),

                                        // Phone Number
                                        GestureDetector(
                                          onTap: () async {
                                            String phoneNumber =
                                                orderData["phone"];
                                            String uri = 'tel:+$phoneNumber';
                                            await launchUrl(Uri.parse(uri));
                                          },
                                          child: Row(
                                            children: [
                                              Icon(Icons.phone,
                                                  color: Colors.white,
                                                  size: 20),
                                              SizedBox(width: 8),
                                              Text(
                                                "+" + orderData["phone"],
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 10),

                                        // Email
                                        GestureDetector(
                                          onTap: () async {
                                            String emailAddress =
                                                orderData["email"];
                                            String uri =
                                                'mailto:+$emailAddress';
                                            await launchUrl(Uri.parse(uri));
                                          },
                                          child: Row(
                                            children: [
                                              Icon(Icons.email_outlined,
                                                  color: Colors.white,
                                                  size: 20),
                                              SizedBox(width: 8),
                                              Text(
                                                orderData["email"],
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]),
                                )
                              : Text(""),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Color(0xff1f335a),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Spacer(),
                                    Text('ADDRESS',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12)),
                                  ],
                                ),
                                Text('Deliver to',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontStyle: FontStyle.italic,
                                    )),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                    '${orderData["home_address"]}, ${orderData["street_address"]}, Ward ${orderData["ward"]}, ${orderData["township"]}',
                                    style: TextStyle(color: Colors.white)),
                                Text(
                                    '${orderData["city"]}, ${orderData["state"]} ${orderData["postal_code"]}',
                                    style: TextStyle(color: Colors.white)),
                                Text('${orderData["country"]}',
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          ...orderItems.map((item) {
                            return Card(
                              elevation: 0,
                              margin: EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    20), // Rounded corners for Card
                              ),
                              child: ListTile(
                                leading: Image.network(
                                  ApiConstants.baseUrl +
                                      item["product_images"][
                                          0], // Replace "YOUR_SERVER_URL_HERE" with your server URL
                                  fit: BoxFit.cover,
                                  height: 60,
                                  width: 60,
                                ),
                                title: Text(
                                  "${item["brand"]} ${item["model"]}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Quantity: ${item["quantity"]}"),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text("Price: "),
                                        FormattedAmount(
                                          amount: item["price"],
                                          mainTextStyle: TextStyle(
                                            color: Colors.grey,
                                          ),
                                          decimalTextStyle: TextStyle(),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text("Amount: "),
                                        FormattedAmount(
                                          amount: item["amount"],
                                          mainTextStyle: TextStyle(
                                            color: Colors.grey,
                                          ),
                                          decimalTextStyle: TextStyle(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList()
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
