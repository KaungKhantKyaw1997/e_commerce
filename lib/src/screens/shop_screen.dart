import 'package:e_commerce/global.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:flutter/material.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  ScrollController _scrollController = ScrollController();
  Map<String, dynamic> shop = {};

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        setState(() {
          shop = arguments;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          shop["name"] ?? "",
          style: FontConstants.title1,
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.vertical,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
            ),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(
                    top: 16,
                  ),
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      // image: NetworkImage(
                      //     '${ApiConstants.baseUrl}${shop["cover_image"].toString()}'),
                      image: AssetImage("assets/images/gshock1.png"),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                    bottom: 4,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      shop["description"] ?? "",
                      style: FontConstants.body2,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8,
                    bottom: 4,
                  ),
                  child: const Divider(
                    height: 0,
                    color: Colors.grey,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8,
                    bottom: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        language["Address"] ?? "Address",
                        style: FontConstants.caption1,
                      ),
                      Text(
                        shop["address"] ?? "",
                        style: FontConstants.caption2,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        language["City"] ?? "City",
                        style: FontConstants.caption1,
                      ),
                      Text(
                        shop["city"] ?? "",
                        style: FontConstants.caption2,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        language["State"] ?? "State",
                        style: FontConstants.caption1,
                      ),
                      Text(
                        shop["state"] ?? "",
                        style: FontConstants.caption2,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        language["Country"] ?? "Country",
                        style: FontConstants.caption1,
                      ),
                      Text(
                        shop["country"] ?? "",
                        style: FontConstants.caption2,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        language["Postal Code"] ?? "Postal Code",
                        style: FontConstants.caption1,
                      ),
                      Text(
                        shop["postal_code"] ?? "",
                        style: FontConstants.caption2,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        language["Phone Number"] ?? "Phone Number",
                        style: FontConstants.caption1,
                      ),
                      Text(
                        shop["phone"] ?? "",
                        style: FontConstants.caption2,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        language["Email"] ?? "Email",
                        style: FontConstants.caption1,
                      ),
                      Text(
                        shop["email"] ?? "",
                        style: FontConstants.caption2,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        language["Website"] ?? "Website",
                        style: FontConstants.caption1,
                      ),
                      Text(
                        shop["website_url"] ?? "",
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 24,
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
          onPressed: () async {},
          child: Text(
            language["Next"] ?? "Next",
            style: FontConstants.button1,
          ),
        ),
      ),
    );
  }
}
