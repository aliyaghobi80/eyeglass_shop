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
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // بررسی وضعیت ادمین بودن کاربر
            FutureBuilder<bool>(
              future: authController.isAdmin(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                return Text('Admin: ${snapshot.data ?? false}');
              },
            ),

            // نمایش اطلاعات کاربر
            Obx(() {
              if (authController.user.value == null) {
                return const CircularProgressIndicator();
              }
              final user = authController.user.value!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Username: ${user.username}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Email: ${user.email}', style: TextStyle(fontSize: 16)),
                  Text('First Name: ${user.firstName}', style: TextStyle(fontSize: 16)),
                  Text('Last Name: ${user.lastName}', style: TextStyle(fontSize: 16)),
                  Text('Active: ${user.isActive}', style: TextStyle(fontSize: 16)),
                  Text('Staff: ${user.isStaff}', style: TextStyle(fontSize: 16)),
                  Text('Admin: ${user.isSuperuser}', style: TextStyle(fontSize: 16)),
                  Text('Date Joined: ${user.dateJoined?.toLocal() ?? "N/A"}', style: TextStyle(fontSize: 16)),
                  Text('Last Login: ${user.lastLogin?.toLocal() ?? "N/A"}', style: TextStyle(fontSize: 16)),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}