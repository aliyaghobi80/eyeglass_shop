import 'package:eyewear/controllers/product_controller.dart';
import 'package:eyewear/screens/add_product_screen.dart';
import 'package:eyewear/screens/manage_categories_screen.dart';
import 'package:eyewear/screens/product_details_screen.dart';
import 'package:eyewear/screens/setting_screen.dart';
import 'package:eyewear/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'controllers/auth_controller.dart';
import 'controllers/theme_controller.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(); // مقداردهی اولیه GetStorage
  Get.put(ThemeController()); // مقداردهی کنترلر

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ThemeController themeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'فروشگاه عینک',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode:
          themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        GetPage(name: '/home', page: () => HomeScreen()),
        GetPage(name: '/setting', page: () => SettingScreen()),
        GetPage(name: '/product-details', page: () => ProductDetailsScreen()),
        GetPage(name: '/add-product', page: () => AddProductScreen()),

        GetPage(
          name: '/manage-categories',
          page: () => ManageCategoriesScreen(),
        ),
      ],
      initialBinding: BindingsBuilder(() {
        Get.put(ApiService()); // AuthController فقط یه بار ساخته بشه
        Get.put(AuthController());
        Get.put(ProductController());
      }),
    );
  }
}
