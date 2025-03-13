import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class AuthController extends GetxController {
  final ApiService apiService = ApiService();
  var isLoading = false.obs;
  var user = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final username = prefs.getString('username');
    final phoneNumber = prefs.getString('phone_number');
    final address = prefs.getString('address');
    final isCustomer = prefs.getBool('is_customer') ?? true;
    if (token != null && username != null) {
      user.value = User(
        username: username,
        phoneNumber: phoneNumber ?? '',
        address: address ?? '',
        isCustomer: isCustomer,
        token: token,
      );
    }
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', user.token);
    await prefs.setString('username', user.username);
    await prefs.setString('phone_number', user.phoneNumber);
    await prefs.setString('address', user.address);
    await prefs.setBool('is_customer', user.isCustomer);
  }

  Future<void> login(String username, String password) async {
    try {
      isLoading(true);
      final loggedInUser = await apiService.login(username, password);
      user.value = loggedInUser;
      await _saveUser(loggedInUser);
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> register({required String username, required String password, required String phoneNumber, required String address}) async {
    try {
      isLoading(true);
      final registeredUser = await apiService.register(username:username, password:password, phoneNumber:phoneNumber, address:address);
      user.value = registeredUser;
      await _saveUser(registeredUser);
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // یا فقط توکن و اطلاعات کاربر رو حذف کن
    user.value = null;
    Get.offAllNamed('/login'); // به صفحه لاگین برگرد
  }

  Future<bool> isAdmin() async {
    if (user.value == null) return false;
    try {
      final profile = await apiService.getUserProfile(user.value!.token);
      return profile['is_admin'] ?? false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to check admin status: $e');
      return false;
    }
  }
}