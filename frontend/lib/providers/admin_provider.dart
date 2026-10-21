import 'package:flutter/foundation.dart';
import '../../models/summary_model.dart';
import '../../models/lead_model.dart';
import '../../models/verification_model.dart';
import '../core/services/api_service.dart';

class AdminProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  SummaryModel? _summary;
  List<CustomerRowModel> _customers = [];
  List<ProviderRowModel> _providers = [];
  List<LeadModel> _leads = [];
  List<VerificationEventModel> _verificationEvents = [];

  int _totalCustomers = 0;
  int _totalProviders = 0;
  int _totalLeads = 0;
  int _totalEvents = 0;

  bool _isLoading = false;
  String? _errorMessage;

  // Filter states
  String _customerSearch = '';
  String _providerSearch = '';
  String _leadSearch = '';
  String? _leadStatusFilter;

  SummaryModel? get summary => _summary;
  List<CustomerRowModel> get customers => _customers;
  List<ProviderRowModel> get providers => _providers;
  List<LeadModel> get leads => _leads;
  List<VerificationEventModel> get verificationEvents => _verificationEvents;

  int get totalCustomers => _totalCustomers;
  int get totalProviders => _totalProviders;
  int get totalLeads => _totalLeads;
  int get totalEvents => _totalEvents;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get leadStatusFilter => _leadStatusFilter;

  Future<void> fetchSummary() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _summary = await _api.getAdminSummary();
    } catch (e) {
      _errorMessage = 'Failed to load dashboard summary.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCustomers({int page = 1}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _api.getAdminCustomers(
        q: _customerSearch.trim().isEmpty ? null : _customerSearch.trim(),
        page: page,
        pageSize: 10,
      );
      _customers = res['items'] as List<CustomerRowModel>;
      _totalCustomers = res['total'] as int;
    } catch (e) {
      _errorMessage = 'Failed to load customers.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchCustomers(String q) {
    _customerSearch = q;
    fetchCustomers(page: 1);
  }

  Future<void> fetchProviders({int page = 1}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _api.getAdminProviders(
        q: _providerSearch.trim().isEmpty ? null : _providerSearch.trim(),
        page: page,
        pageSize: 10,
      );
      _providers = res['items'] as List<ProviderRowModel>;
      _totalProviders = res['total'] as int;
    } catch (e) {
      _errorMessage = 'Failed to load providers.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchProviders(String q) {
    _providerSearch = q;
    fetchProviders(page: 1);
  }

  Future<bool> toggleProviderActive(int id, bool currentActive) async {
    try {
      final updated = await _api.setProviderActive(id, !currentActive);
      final idx = _providers.indexWhere((p) => p.id == id);
      if (idx != -1) {
        _providers[idx] = updated;
      }
      await fetchSummary(); // Update live counter
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update provider status.';
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchLeads({int page = 1}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _api.getAdminLeads(
        status: _leadStatusFilter,
        q: _leadSearch.trim().isEmpty ? null : _leadSearch.trim(),
        page: page,
        pageSize: 10,
      );
      _leads = res.items;
      _totalLeads = res.total;
    } catch (e) {
      _errorMessage = 'Failed to load leads.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterLeadsByStatus(String? status) {
    _leadStatusFilter = status;
    fetchLeads(page: 1);
  }

  void searchLeads(String q) {
    _leadSearch = q;
    fetchLeads(page: 1);
  }

  Future<bool> updateLeadStatus(int id, String newStatus) async {
    try {
      final updated = await _api.updateLeadStatus(id, newStatus);
      final idx = _leads.indexWhere((l) => l.id == id);
      if (idx != -1) {
        _leads[idx] = updated;
      }
      await fetchSummary(); // Live counter update
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchVerificationEvents({int page = 1}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _api.getAdminVerificationEvents(page: page, pageSize: 15);
      _verificationEvents = res['items'] as List<VerificationEventModel>;
      _totalEvents = res['total'] as int;
    } catch (e) {
      _errorMessage = 'Failed to load verification events.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> simulateMockVerification(int userId, String status, String note) async {
    try {
      await _api.simulateMockVerification(userId, status: status, note: note);
      await fetchSummary();
      await fetchVerificationEvents(page: 1);
      await fetchProviders(page: 1);
      await fetchCustomers(page: 1);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
