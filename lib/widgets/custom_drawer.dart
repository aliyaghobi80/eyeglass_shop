import 'package:cached_network_image/cached_network_image.dart';
import 'package:eyewear/widgets/static_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class CustomDrawer extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // هدر دراور با اطلاعات کاربر
          UserAccountsDrawerHeader(
            accountName: Text(authController.user.value!.username), // اینجا نام کاربر را وارد کنید
            accountEmail: Text(authController.user.value!.email), // ایمیل کاربر
            currentAccountPicture: Container(
              decoration: BoxDecoration(
                color: Colors.white30,
                border: Border(
                  left: BorderSide(color: Colors.yellow, width: 3),
                ),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CachedNetworkImage(
                  imageUrl:
                      "https://farsgraphic.com/wp-content/uploads/2016/12/5-1.png",
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),

            decoration: BoxDecoration(color: Colors.blue),
          ),

          ListTile(
            leading: Icon(Icons.category),
            title: Text('اضافه کردن دسته‌بندی عینک'),
            onTap: () {
              Get.toNamed('/manageCategories');
            },
          ),

          ListTile(
            leading: Icon(Icons.settings),
            title: Text('تنظیمات برنامه'),
            onTap: () {
              Get.toNamed('/setting');
            },
          ),

          ListTile(
            leading: Icon(Icons.info),
            title: Text('درباره ما'),
            onTap: () {
              Navigator.pop(context);
              // Navigator.push(context, MaterialPageRoute(builder: (context) => AboutScreen()));
            },
          ),


          Divider(),


          ListTile(
            leading: Icon(Icons.logout),
            title: Text('خروج'),
            onTap: () {
              Get.bottomSheet(
                BottomSheet(
                  onClosing: () {
                    print('close bottomsheet');
                  },
                  builder: (context) {
                    print('oben bottomsheet');
                    return Container(
                      height: 150,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text('آیا واقعا میخواهید از حساب جاری خارج شوید؟'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              spacing: 10,
                              children: [
                                Expanded(
                                  child: CustomOkButton(onPressed: (){}, text: 'بله',)),
                                Expanded(
                                  child: CustomCancelButton(onPressed: (){}, text: 'خیر',)),

                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
