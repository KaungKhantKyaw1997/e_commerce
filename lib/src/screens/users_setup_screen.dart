import 'package:e_commerce/global.dart';
import 'package:e_commerce/routes.dart';
import 'package:e_commerce/src/constants/api_constants.dart';
import 'package:e_commerce/src/constants/color_constants.dart';
import 'package:e_commerce/src/constants/font_constants.dart';
import 'package:e_commerce/src/services/user_service.dart';
import 'package:e_commerce/src/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UsersSetupScreen extends StatefulWidget {
  const UsersSetupScreen({super.key});

  @override
  State<UsersSetupScreen> createState() => _UsersSetupScreenState();
}

class _UsersSetupScreenState extends State<UsersSetupScreen> {
  final userService = UserService();
  TextEditingController search = TextEditingController(text: '');
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List users = [];
  int page = 1;

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  @override
  void dispose() {
    // userService.cancelRequest();
    _scrollController.dispose();
    super.dispose();
  }

  getUsers() async {
    try {
      final response =
          await userService.getUsersData(page: page, search: search.text);
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();

      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          users += response["data"];
          page++;
        }
        setState(() {});
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
      print('Error: $e');
    }
  }

  userCard(index) {
    return Container(
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
          bottomLeft: Radius.circular(index == users.length - 1 ? 10 : 0),
          bottomRight: Radius.circular(index == users.length - 1 ? 10 : 0),
        ),
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              image: users[index]["profile_image"] != ""
                  ? DecorationImage(
                      image: NetworkImage(
                          '${ApiConstants.baseUrl}${users[index]["profile_image"].toString()}'),
                      fit: BoxFit.cover,
                    )
                  : DecorationImage(
                      image: AssetImage('assets/images/profile.png'),
                      fit: BoxFit.cover,
                    ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.transparent,
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(
                left: 15,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        users[index]["username"].toString(),
                        overflow: TextOverflow.ellipsis,
                        style: FontConstants.body1,
                      ),
                      Text(
                        Jiffy.parse(users[index]["created_at"])
                            .format(pattern: 'dd/MM/yyyy'),
                        overflow: TextOverflow.ellipsis,
                        style: FontConstants.caption1,
                      ),
                    ],
                  ),
                  Text(
                    users[index]["phone"].toString(),
                    overflow: TextOverflow.ellipsis,
                    style: FontConstants.caption1,
                  ),
                  Text(
                    users[index]["email"].toString(),
                    overflow: TextOverflow.ellipsis,
                    style: FontConstants.caption1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: TextField(
          controller: search,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          style: FontConstants.body1,
          cursorColor: Colors.black,
          decoration: InputDecoration(
            hintText: language["Search"] ?? "Search",
            filled: true,
            fillColor: ColorConstants.fillcolor,
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
            page = 1;
            users = [];
            getUsers();
          },
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
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
          users = [];
          await getUsers();
        },
        onLoading: () async {
          await getUsers();
        },
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            width: double.infinity,
            child: Column(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          Routes.user_setup,
                          arguments: {
                            "id": users[index]["user_id"],
                          },
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          userCard(index),
                          index < users.length - 1
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
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
          Navigator.pushNamed(
            context,
            Routes.user_setup,
            arguments: {
              "id": 0,
            },
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          Icons.add,
        ),
      ),
    );
  }
}
