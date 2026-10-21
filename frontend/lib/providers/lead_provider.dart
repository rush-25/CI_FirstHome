import 'package:flutter/foundation.dart';
import '../../models/lead_model.dart';
import '../core/services/api_service.dart';

class LeadProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<LeadModel> _myLeads = [];
  int _totalLeads = 0;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  String? _errorMessage;

  String? _statusFilter;
  String _searchQuery = '';

  LeadModel? _activeLead;

  List<LeadModel> get myLeads => _myLeads;
  int get totalLeads => _totalLeads;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get statusFilter => _statusFilter;
  LeadModel? get activeLead => _activeLead;

  // Computed metrics for customer dashboard
  int get newCount => _myLeads.where((l) => l.status == 'New').length;
  int get contactedCount => _myLeads.where((l) => l.status == 'Contacted').length;
  int get qualifiedCount => _myLeads.where((l) => l.status == 'Qualified').length;
  int get closedCount => _myLeads.where((l) => l.status == 'Closed').length;

  Future<void> fetchMyLeads({int page = 1}) async {
    _isLoading = true;
    _errorMessage = null;
    _currentPage = page;
    notifyListeners();

    try {
      final res = await _api.getMyLeads(
        status: _statusFilter,
        q: _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
        page: _currentPage,
        pageSize: 10,
      );
      _myLeads = res.items;
      _totalLeads = res.total;
      _totalPages = res.totalPages;
    } catch (e) {
      _errorMessage = 'Failed to load your enquiries.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setStatusFilter(String? status) {
    _statusFilter = status;
    fetchMyLeads(page: 1);
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    fetchMyLeads(page: 1);
  }

  Future<LeadModel?> createLead({
    required String enquiryType,
    required String title,
    required String description,
    required String state,
    required String city,
    required String preferredContact,
    int? categoryId,
    int? providerId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final lead = await _api.createLead(
        enquiryType: enquiryType,
        title: title,
        description: description,
        state: state,
        city: city,
        preferredContact: preferredContact,
        categoryId: categoryId,
        providerId: providerId,
      );
      await fetchMyLeads(page: 1);
      _isLoading = false;
      notifyListeners();
      return lead;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> fetchLeadDetails(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      _activeLead = await _api.getLead(id);
    } catch (e) {
      _errorMessage = 'Failed to load enquiry details.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearActiveLead() {
    _activeLead = null;
    notifyListeners();
  }
}
