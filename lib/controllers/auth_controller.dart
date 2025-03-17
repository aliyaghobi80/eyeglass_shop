import 'package:eyewear/models/user.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
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

      final username = prefs.getString('username') ?? '';
      final email = prefs.getString('email') ?? '';
      final firstName = prefs.getString('first_name') ?? '';
      final lastName = prefs.getString('last_name') ?? '';
      final isStaff = prefs.getBool('is_staff') ?? false;
      final isSuperuser = prefs.getBool('is_superuser') ?? false;
      final isActive = prefs.getBool('is_active') ?? true;
      final dateJoined = prefs.getString('date_joined');
      final lastLogin = prefs.getString('last_login');
      final token = prefs.getString('access_token') ?? '';
      final refreshToken = prefs.getString('refresh_token') ?? '';

      if (token.isEmpty || username.isEmpty) {
        if (Get.currentRoute != '/login') {
          Get.offAllNamed('/login');
        }
        return;
      }

      String validToken = token;
      if (JwtDecoder.isExpired(token)) {
        try {
          validToken = await apiService.refreshAccessToken(refreshToken);
          await prefs.setString('access_token', validToken);
        } catch (e) {
          if (Get.currentRoute != '/login') {
            Get.offAllNamed('/login');
          }
          return;
        }
      }

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
        accessToken: validToken,
        refreshToken: refreshToken,
      );

      if (Get.currentRoute != '/home') {
        Get.offAllNamed('/home');
      }
    } catch (e) {
      Get.snackbar('خطا', 'خطا در بارگذاری اطلاعات کاربر: $e');
      if (Get.currentRoute != '/login') {
        Get.offAllNamed('/login');
      }
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
    await prefs.setString(
      'date_joined',
      user.dateJoined?.toIso8601String() ?? '',
    );
    await prefs.setString(
      'last_login',
      user.lastLogin?.toIso8601String() ?? '',
    );
    await prefs.setString('access_token', user.accessToken);
    await prefs.setString('refresh_token', user.refreshToken);
  }

  Future<void> login(String username, String password) async {
    try {
      isLoading(true);
      final loggedInUser = await apiService.login(username, password);

      if (loggedInUser.accessToken.isEmpty ||
          loggedInUser.refreshToken.isEmpty) {
        throw Exception('خطا در ورود: توکن‌ها یافت نشدند');
      }

      user.value = loggedInUser;
      await _saveUser(loggedInUser);

      Get.offAllNamed('/home');
    } catch (e) {
      final errorMsg =
      e.toString().contains('Exception:')
          ? e.toString().replaceFirst('Exception: ', '')
          : 'خطا در ورود به سیستم';
      Get.snackbar('خطا', errorMsg);
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
      Get.snackbar('خطا', e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token') ?? '';
      final refreshToken = prefs.getString('refresh_token') ?? '';

      if (accessToken.isNotEmpty && refreshToken.isNotEmpty) {
        String validToken = accessToken;
        if (JwtDecoder.isExpired(accessToken)) {
          validToken = await apiService.refreshAccessToken(refreshToken);
          await prefs.setString('access_token', validToken);
        }
        await apiService.logout();
      }

      await prefs.clear();
      user.value = null;
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('خطا', 'خطا در خروج از سیستم: $e');
    }
  }
}
