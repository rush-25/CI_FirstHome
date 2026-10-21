import 'package:flutter/foundation.dart';
import '../../models/user_model.dart';
import '../../models/verification_model.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  VerificationStateModel? _verificationState;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  VerificationStateModel? get verificationState => _verificationState;

  bool get isCustomer => _currentUser?.isCustomer ?? false;
  bool get isProvider => _currentUser?.isProvider ?? false;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await StorageService.getToken();
      if (token != null && token.isNotEmpty) {
        _currentUser = await _api.getMe();
        if (_currentUser != null) {
          await loadVerificationState();
        }
      }
    } catch (_) {
      await StorageService.clearSession();
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _api.login(email: email, password: password);
      _currentUser = res.user;
      await StorageService.saveSession(res.token, res.user);
      await loadVerificationState();
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Login failed: unable to connect to server.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String role,
    String? state,
    String? city,
    String? contactPreference,
    required bool consent,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _api.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        role: role,
        state: state,
        city: city,
        contactPreference: contactPreference,
        consent: consent,
      );
      _currentUser = res.user;
      await StorageService.saveSession(res.token, res.user);
      await loadVerificationState();
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Registration failed: unable to connect to server.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    required String phone,
    String? state,
    String? city,
    String? contactPreference,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _api.updateMe(
        fullName: fullName,
        phone: phone,
        state: state,
        city: city,
        contactPreference: contactPreference,
      );
      final token = await StorageService.getToken();
      if (token != null && _currentUser != null) {
        await StorageService.saveSession(token, _currentUser!);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Failed to update profile.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadVerificationState() async {
    if (_currentUser == null || _currentUser!.isAdmin) return;
    try {
      _verificationState = await _api.getMyVerification();
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> consentMockVerification() async {
    _isLoading = true;
    notifyListeners();
    try {
      _verificationState = await _api.consentVerification();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await StorageService.clearSession();
    _currentUser = null;
    _verificationState = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
