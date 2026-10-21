import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../models/category_model.dart';
import '../../models/provider_model.dart';
import '../../models/lead_model.dart';
import '../../models/summary_model.dart';
import '../../models/verification_model.dart';
import 'storage_service.dart';

class ApiException implements Exception {
  final int statusCode;
  final String code;
  final String message;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.errors,
  });

  @override
  String toString() {
    if (errors != null && errors!.isNotEmpty) {
      final details = errors!.entries.map((e) => '${e.key}: ${e.value}').join(', ');
      return '$message ($details)';
    }
    return message;
  }
}

class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = AppConstants.apiBaseUrl});

  Future<Map<String, String>> _headers({bool needsAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (needsAuth) {
      final token = await StorageService.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  dynamic _handleResponse(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      return jsonDecode(res.body);
    }

    String message = 'An error occurred (${res.statusCode})';
    String code = 'error';
    Map<String, dynamic>? errors;

    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      message = body['message'] as String? ?? message;
      code = body['code'] as String? ?? code;
      errors = body['errors'] as Map<String, dynamic>?;
    } catch (_) {}

    throw ApiException(
      statusCode: res.statusCode,
      code: code,
      message: message,
      errors: errors,
    );
  }

  // ---------- AUTH ----------
  Future<AuthResponseModel> register({
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
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: await _headers(needsAuth: false),
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
        'state': state,
        'city': city,
        'contactPreference': contactPreference,
        'consent': consent,
      }),
    );
    final data = _handleResponse(res) as Map<String, dynamic>;
    return AuthResponseModel.fromJson(data);
  }

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: await _headers(needsAuth: false),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    final data = _handleResponse(res) as Map<String, dynamic>;
    return AuthResponseModel.fromJson(data);
  }

  Future<UserModel> getMe() async {
    final res = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: await _headers(),
    );
    final data = _handleResponse(res) as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  Future<UserModel> updateMe({
    required String fullName,
    required String phone,
    String? state,
    String? city,
    String? contactPreference,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl/me'),
      headers: await _headers(),
      body: jsonEncode({
        'fullName': fullName,
        'phone': phone,
        'state': state,
        'city': city,
        'contactPreference': contactPreference,
      }),
    );
    final data = _handleResponse(res) as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  Future<VerificationStateModel> getMyVerification() async {
    final res = await http.get(
      Uri.parse('$baseUrl/me/verification'),
      headers: await _headers(),
    );
    final data = _handleResponse(res) as Map<String, dynamic>;
    return VerificationStateModel.fromJson(data);
  }

  Future<VerificationStateModel> consentVerification() async {
    final res = await http.post(
      Uri.parse('$baseUrl/me/verification/consent'),
      headers: await _headers(),
    );
    final data = _handleResponse(res) as Map<String, dynamic>;
    return VerificationStateModel.fromJson(data);
  }

  // ---------- CATEGORIES ----------
  Future<List<CategoryModel>> getCategories() async {
    final res = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: await _headers(needsAuth: false),
    );
    final list = _handleResponse(res) as List<dynamic>;
    return list.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ---------- PROVIDERS ----------
  Future<PagedProviders> getProviders({
    int? category,
    String? state,
    String? city,
    String? q,
    String sort = 'name',
    int page = 1,
    int pageSize = 9,
  }) async {
    final params = <String, String>{
      'sort': sort,
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (category != null) params['category'] = category.toString();
    if (state != null && state.isNotEmpty) params['state'] = state;
    if (city != null && city.isNotEmpty) params['city'] = city;
    if (q != null && q.isNotEmpty) params['q'] = q;

    final uri = Uri.parse('$baseUrl/providers').replace(queryParameters: params);
    final res = await http.get(uri, headers: await _headers(needsAuth: false));
    final data = _handleResponse(res) as Map<String, dynamic>;
    return PagedProviders.fromJson(data);
  }

  Future<ProviderModel> getProvider(int id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/providers/$id'),
      headers: await _headers(needsAuth: false),
    );
    final data = _handleResponse(res) as Map<String, dynamic>;
    return ProviderModel.fromJson(data);
  }

  Future<ProviderModel> getMyProviderProfile() async {
    final res = await http.get(
      Uri.parse('$baseUrl/providers/me'),
      headers: await _headers(),
    );
    final data = _handleResponse(res) as Map<String, dynamic>;
    return ProviderModel.fromJson(data);
  }

  Future<List<LeadModel>> getMyProviderLeads() async {
    final res = await http.get(
      Uri.parse('$baseUrl/providers/me/leads'),
      headers: await _headers(),
    );
    final list = _handleResponse(res) as List<dynamic>;
    return list.map((e) => LeadModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ProviderModel> createProviderProfile({
    required String displayName,
    required String contactEmail,
    required int categoryId,
    required String state,
    required String city,
    required String description,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/providers'),
      headers: await _headers(),
      body: jsonEncode({
        'displayName': displayName,
        'contactEmail': contactEmail,
        'categoryId': categoryId,
        'state': state,
        'city': city,
        'description': description,
      }),
    );
    final data = _handleResponse(res) as Map<String, dynamic>;
    return ProviderModel.fromJson(data);
  }

  Future<ProviderModel> updateProviderProfile(
    int id, {
    required String displayName,
    required String contactEmail,
    required int categoryId,
    required String state,
    required String city,
    required String description,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl/providers/$id'),
      headers: await _headers(),
      body: jsonEncode({
        'displayName': displayName,
        'contactEmail': contactEmail,
        'categoryId': categoryId,
        'state': state,
        'city': city,
        'description': description,
      }),
    );
    final data = _handleResponse(res) as Map<String, dynamic>;
    return ProviderModel.fromJson(data);
  }

  // ---------- LEADS ----------
  Future<LeadModel> createLead({
    required String enquiryType,
    required String title,
    required String description,
    required String state,
    required String city,
    required String preferredContact,
    int? categoryId,
    int? providerId,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/leads'),
      headers: await _headers(),
      body: jsonEncode({
        'enquiryType': enquiryType,
        'title': title,
        'description': description,
        'state': state,
        'city': city,
        'preferredContact': preferredContact,
        'categoryId': categoryId,
        'providerId': providerId,
      }),
    );
    final data = _handleResponse(res) as Map<String, dynamic>;
    return LeadModel.fromJson(data);
  }

  Future<PagedLeads> getMyLeads({
    String? status,
    String? q,
    int page = 1,
    int pageSize = 10,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (q != null && q.isNotEmpty) params['q'] = q;

    final uri = Uri.parse('$baseUrl/leads/mine').replace(queryParameters: params);
    final res = await http.get(uri, headers: await _headers());
    final data = _handleResponse(res) as Map<String, dynamic>;
    return PagedLeads.fromJson(data);
  }

  Future<LeadModel> getLead(int id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/leads/$id'),
      headers: await _headers(),
    );
    final data = _handleResponse(res) as Map<String, dynamic>;
    return LeadModel.fromJson(data);
  }

  // ---------- ADMIN ----------
  Future<SummaryModel> getAdminSummary() async {
    final res = await http.get(
      Uri.parse('$baseUrl/admin/summary'),
      headers: await _headers(),
    );
    final data = _handleResponse(res) as Map<String, dynamic>;
    return SummaryModel.fromJson(data);
  }

  Future<Map<String, dynamic>> getAdminCustomers({
    String? q,
    int page = 1,
    int pageSize = 10,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (q != null && q.isNotEmpty) params['q'] = q;

    final uri = Uri.parse('$baseUrl/admin/customers').replace(queryParameters: params);
    final res = await http.get(uri, headers: await _headers());
    final data = _handleResponse(res) as Map<String, dynamic>;
    final items = (data['items'] as List<dynamic>? ?? [])
        .map((e) => CustomerRowModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return {
      'items': items,
      'total': data['total'] ?? 0,
      'page': data['page'] ?? 1,
      'totalPages': data['totalPages'] ?? 1,
    };
  }

  Future<Map<String, dynamic>> getAdminProviders({
    String? q,
    int? category,
    int page = 1,
    int pageSize = 10,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (q != null && q.isNotEmpty) params['q'] = q;
    if (category != null) params['category'] = category.toString();

    final uri = Uri.parse('$baseUrl/admin/providers').replace(queryParameters: params);
    final res = await http.get(uri, headers: await _headers());
    final data = _handleResponse(res) as Map<String, dynamic>;
    final items = (data['items'] as List<dynamic>? ?? [])
        .map((e) => ProviderRowModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return {
      'items': items,
      'total': data['total'] ?? 0,
      'page': data['page'] ?? 1,
      'totalPages': data['totalPages'] ?? 1,
    };
  }

  Future<ProviderRowModel> setProviderActive(int id, bool isActive) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/admin/providers/$id/active'),
      headers: await _headers(),
      body: jsonEncode({'isActive': isActive}),
    );
    final data = _handleResponse(res) as Map<String, dynamic>;
    return ProviderRowModel.fromJson(data);
  }

  Future<PagedLeads> getAdminLeads({
    String? status,
    String? q,
    int page = 1,
    int pageSize = 10,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (q != null && q.isNotEmpty) params['q'] = q;

    final uri = Uri.parse('$baseUrl/admin/leads').replace(queryParameters: params);
    final res = await http.get(uri, headers: await _headers());
    final data = _handleResponse(res) as Map<String, dynamic>;
    return PagedLeads.fromJson(data);
  }

  Future<LeadModel> updateLeadStatus(int id, String newStatus) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/admin/leads/$id/status'),
      headers: await _headers(),
      body: jsonEncode({'status': newStatus}),
    );
    final data = _handleResponse(res) as Map<String, dynamic>;
    return LeadModel.fromJson(data);
  }

  Future<VerificationEventModel> simulateMockVerification(
    int userId, {
    required String status,
    String? note,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/admin/users/$userId/mock-verification'),
      headers: await _headers(),
      body: jsonEncode({
        'status': status,
        'note': note ?? 'Simulated by admin (MOCK)',
      }),
    );
    final data = _handleResponse(res) as Map<String, dynamic>;
    return VerificationEventModel.fromJson(data);
  }

  Future<Map<String, dynamic>> getAdminVerificationEvents({
    int page = 1,
    int pageSize = 10,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    final uri = Uri.parse('$baseUrl/admin/verification-events').replace(queryParameters: params);
    final res = await http.get(uri, headers: await _headers());
    final data = _handleResponse(res) as Map<String, dynamic>;
    final items = (data['items'] as List<dynamic>? ?? [])
        .map((e) => VerificationEventModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return {
      'items': items,
      'total': data['total'] ?? 0,
      'page': data['page'] ?? 1,
      'totalPages': data['totalPages'] ?? 1,
    };
  }
}
