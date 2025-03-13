import 'package:eyewear/models/user.dart';
import 'package:eyewear/utils/utf_fix.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class HomeScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eyewear Store'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                authController.logout();
              }
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Text('Logout'),
                  ),
                ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            FutureBuilder<bool>(
              future: authController.isAdmin(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                return Text('Admin: ${snapshot.data ?? false}');
              },
            ),
            Obx(() {

              if (authController.user.value == null) {
                return const CircularProgressIndicator();
              }
              // نمایش اطلاعات یوزر
              return Column(children: [
                Text('username: ${authController.user.value!.username}'),
                Text('phoneNumber: ${authController.user.value!.phoneNumber}'),
                Text('token: ${authController.user.value!.token}'),

                Text('address: ${decodeUTF8(authController.user.value!.address)}'),
              ],);
            }),
          ],
        ),
      ),
    );
  }
}
