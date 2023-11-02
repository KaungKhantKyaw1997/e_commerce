import 'package:e_commerce/global.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final ScrollController _scrollController = ScrollController();
  String phoneNumber = '+959 782227894';
  String emailAddress = 'kaungkhant@gmail.com';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
          language["Contact Us"] ?? "Contact Us",
          style: FontConstants.title1,
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: Column(
            children: [
              Container(
                width:
                    MediaQuery.of(context).orientation == Orientation.landscape
                        ? 150
                        : 300,
                height:
                    MediaQuery.of(context).orientation == Orientation.landscape
                        ? 150
                        : 300,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/contact_us.png'),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 16,
                  bottom: 8,
                ),
                child: Text(
                  "Questions about our watches?",
                  style: FontConstants.headline1,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: 24,
                ),
                child: Text(
                  "Reach out to us anytime!",
                  style: FontConstants.headline1,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  String uri = 'tel:+$phoneNumber';
                  await launchUrl(Uri.parse(uri));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  margin: EdgeInsets.only(
                    bottom: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        "assets/icons/phone.svg",
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: Text(
                          phoneNumber,
                          overflow: TextOverflow.ellipsis,
                          style: FontConstants.caption2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  String uri = 'mailto:+$emailAddress';
                  await launchUrl(Uri.parse(uri));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        "assets/icons/mailbox.svg",
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: Text(
                          emailAddress,
                          overflow: TextOverflow.ellipsis,
                          style: FontConstants.caption2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
