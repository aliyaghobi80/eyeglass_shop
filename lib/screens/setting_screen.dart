import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/theme_controller.dart';

class SettingScreen extends StatelessWidget {
   const SettingScreen({super.key});



  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    return Scaffold(
      appBar: AppBar(title: Text('تنظیمات'), centerTitle: true),
      body: ListView(
        children: [
          ListTile(
            title: Text('تم برنامه'),
            trailing: Obx(
              () => Switch(
                value: themeController.isDarkMode.value,
                onChanged: (value) {
                  themeController.toggleTheme(value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
