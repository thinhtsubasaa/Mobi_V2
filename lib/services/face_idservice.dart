import 'package:local_auth/local_auth.dart';

class FaceAuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Kiểm tra xem thiết bị có hỗ trợ sinh trắc học không
  Future<bool> isBiometricAvailable() async {
    return await _auth.canCheckBiometrics;
  }

  /// Lấy danh sách loại sinh trắc học có sẵn
  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _auth.getAvailableBiometrics();
  }

  /// Xác thực bằng Face ID / vân tay
  Future<bool> authenticateWithBiometrics() async {
    try {
      bool authenticated = await _auth.authenticate(
        localizedReason: "Xác thực để đăng nhập",
        options: const AuthenticationOptions(
          biometricOnly: true, // Chỉ dùng Face ID hoặc vân tay
          stickyAuth: true,
        ),
      );
      return authenticated;
    } catch (e) {
      print("Lỗi xác thực: $e");
      return false;
    }
  }
}
