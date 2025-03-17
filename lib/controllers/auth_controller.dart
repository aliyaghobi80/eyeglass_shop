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
      final token = prefs.getString('access_token') ?? '';
      final refreshToken = prefs.getString('refresh_token') ?? '';

      print('username SharedPreferences✔️✔️\n is $username');
      print('access_token is: $token');

      // اگر توکن یا نام کاربری وجود نداره، به لاگین برو
      if (token.isEmpty || username.isEmpty) {
        if (Get.currentRoute != '/login') {
          Get.offAllNamed('/login');
        }
        return;
      }

      // چک کردن انقضای توکن و رفرش کردن در صورت نیاز
      String validToken = token;
      if (JwtDecoder.isExpired(token)) {
        print('Access token is expired, attempting to refresh...');
        try {
          validToken = await apiService.refreshAccessToken(refreshToken);
          await prefs.setString('access_token', validToken); // ذخیره توکن جدید
          print('New access_token: $validToken');
        } catch (e) {
          print('Failed to refresh token: $e');
          if (Get.currentRoute != '/login') {
            Get.offAllNamed('/login');
          }
          return;
        }
      }

      // اگر توکن معتبره، اطلاعات کاربر رو بارگذاری کن
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
        accessToken: validToken, // استفاده از توکن معتبر (جدید یا قدیمی)
        refreshToken: refreshToken,
      );
      print('User loaded: ${user.value}');
      if (Get.currentRoute != '/home') {
        Get.offAllNamed('/home'); // انتقال به صفحه هوم
      }
    } catch (e) {
      print('Error in _loadUser: $e');
      Get.snackbar('Error', 'Failed to load user data: $e');
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

    print("Retrieved Access Token: ${prefs.getString('access_token')}");
    print("Retrieved Refresh Token: ${prefs.getString('refresh_token')}");

  }

  Future<void> login(String username, String password) async {
    try {
      isLoading(true);
      final loggedInUser = await apiService.login(username, password);

      if (loggedInUser.accessToken.isEmpty ||
          loggedInUser.refreshToken.isEmpty) {
        throw Exception('Login failed: Tokens are missing');
      }

      user.value = loggedInUser;
      await _saveUser(loggedInUser);

      Get.offAllNamed('/home');
    } catch (e) {
      final errorMsg =
          e.toString().contains('Exception:')
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
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token') ?? '';
      final refreshToken = prefs.getString('refresh_token') ?? '';

      print("Refresh Token before logout: $refreshToken");

      if (accessToken.isNotEmpty && refreshToken.isNotEmpty) {
        String validToken = accessToken;
        if (JwtDecoder.isExpired(accessToken)) { // اضافه کردن jwt_decoder
          validToken = await apiService.refreshAccessToken(refreshToken);
          await prefs.setString('access_token', validToken);
        }
        await apiService.logout(validToken,refreshToken);
      }

      await prefs.clear();
      user.value = null;
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Error', 'Failed to log out: $e');
    }
  }
}
