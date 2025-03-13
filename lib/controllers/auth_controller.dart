import 'package:eyewear/models/user.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthController extends GetxController {
  final ApiService apiService = ApiService();
  var isLoading = false.obs;
  var user = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    _loadUser();
  }

  Future<bool> isAdmin() async {
    if (user.value == null) {
      return false;
    }
    return user.value!.isSuperuser;
  }

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // بارگیری اطلاعات ذخیره‌شده
      final username = prefs.getString('username') ?? '';
      final email = prefs.getString('email') ?? '';
      final firstName = prefs.getString('first_name') ?? '';
      final lastName = prefs.getString('last_name') ?? '';
      final isStaff = prefs.getBool('is_staff') ?? false;
      final isSuperuser = prefs.getBool('is_superuser') ?? false;
      final isActive = prefs.getBool('is_active') ?? true;
      final dateJoined = prefs.getString('date_joined');
      final lastLogin = prefs.getString('last_login');
      final token = prefs.getString('token') ?? '';
      final refreshToken = prefs.getString('refresh_token') ?? '';

      // اگر توکن وجود ندارد، به صفحه لاگین هدایت شود
      if (token.isEmpty) {
        if (Get.currentRoute != '/login') {
          Get.offAllNamed('/login'); // جلوگیری از هدایت مکرر
        }
        return;
      }

      // اگر توکن موجود است، اطلاعات کاربر را بارگذاری کن
      if (username.isNotEmpty && token.isNotEmpty) {
        user.value = User(
          username: username,
          email: email,
          firstName: firstName,
          lastName: lastName,
          isStaff: isStaff,
          isSuperuser: isSuperuser,
          isActive: isActive,
          dateJoined: dateJoined != null ? DateTime.parse(dateJoined) : null,
          lastLogin: lastLogin != null ? DateTime.parse(lastLogin) : null,
          token: token,
          refreshToken: refreshToken,
        );
      }
    } catch (e) {
      // اگر خطایی رخ دهد، نمایش پیام خطا
      Get.snackbar('Error', 'Failed to load user data: $e');
    }
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', user.username);
    await prefs.setString('email', user.email);
    await prefs.setString('first_name', user.firstName);
    await prefs.setString('last_name', user.lastName);
    await prefs.setBool('is_staff', user.isStaff);
    await prefs.setBool('is_superuser', user.isSuperuser);
    await prefs.setBool('is_active', user.isActive);
    await prefs.setString('date_joined', user.dateJoined?.toIso8601String() ?? '');
    await prefs.setString('last_login', user.lastLogin?.toIso8601String() ?? '');
    await prefs.setString('token', user.token);
    await prefs.setString('refresh_token', user.refreshToken);
  }

  Future<void> login(String username, String password) async {
    try {
      isLoading(true);
      final loggedInUser = await apiService.login(username, password);

      if (loggedInUser.token.isEmpty) {
        throw Exception('Login failed: Token is missing');
      }

      user.value = loggedInUser;
      await _saveUser(loggedInUser);
      Get.offAllNamed('/home');
    } catch (e) {
      final errorMsg = e.toString().contains('Exception:')
          ? e.toString().replaceFirst('Exception: ', '')
          : 'An error occurred while logging in.';
      Get.snackbar('Error', errorMsg);
    } finally {
      isLoading(false);
    }
  }

  Future<void> register({
    required String username,
    required String password,
    required String email,
    String? firstName,
    String? lastName,

  }) async {
    try {
      isLoading(true);
      final registeredUser = await apiService.register(
        username: username,
        password: password,
        email: email,
        firstName: firstName ?? '',
        lastName: lastName ?? '',
      );
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
    await prefs.clear();
    user.value = null;
    Get.offAllNamed('/login');
  }
}