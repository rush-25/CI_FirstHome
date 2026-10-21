import 'package:flutter/foundation.dart';
import '../../models/category_model.dart';
import '../../models/provider_model.dart';
import '../core/services/api_service.dart';

class DirectoryProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<CategoryModel> _categories = [];
  List<ProviderModel> _providers = [];
  int _totalProviders = 0;
  int _currentPage = 1;
  int _totalPages = 1;

  bool _isLoading = false;
  String? _errorMessage;

  // Filters
  int? _selectedCategoryId;
  String? _selectedState;
  String? _selectedCity;
  String _searchQuery = '';
  String _sortBy = 'name';

  List<CategoryModel> get categories => _categories;
  List<ProviderModel> get providers => _providers;
  int get totalProviders => _totalProviders;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int? get selectedCategoryId => _selectedCategoryId;
  String? get selectedState => _selectedState;
  String? get selectedCity => _selectedCity;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;

  Future<void> loadCategories() async {
    try {
      _categories = await _api.getCategories();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchProviders({int page = 1}) async {
    _isLoading = true;
    _errorMessage = null;
    _currentPage = page;
    notifyListeners();

    try {
      final res = await _api.getProviders(
        category: _selectedCategoryId,
        state: _selectedState,
        city: _selectedCity,
        q: _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
        sort: _sortBy,
        page: _currentPage,
        pageSize: 9,
      );
      _providers = res.items;
      _totalProviders = res.total;
      _totalPages = res.totalPages;
    } catch (e) {
      _errorMessage = 'Failed to load service providers.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategoryFilter(int? categoryId) {
    _selectedCategoryId = categoryId;
    fetchProviders(page: 1);
  }

  void setLocationFilter(String? state, String? city) {
    _selectedState = state;
    _selectedCity = city;
    fetchProviders(page: 1);
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    fetchProviders(page: 1);
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    fetchProviders(page: 1);
  }

  void clearFilters() {
    _selectedCategoryId = null;
    _selectedState = null;
    _selectedCity = null;
    _searchQuery = '';
    _sortBy = 'name';
    fetchProviders(page: 1);
  }

  Future<ProviderModel?> getProviderDetail(int id) async {
    try {
      return await _api.getProvider(id);
    } catch (_) {
      return null;
    }
  }
}
