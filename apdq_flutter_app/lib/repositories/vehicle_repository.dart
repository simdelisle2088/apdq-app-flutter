import 'package:rxdart/rxdart.dart';
import 'package:apdq_flutter_app/blocs/search/search_api_service.dart';
import 'package:apdq_flutter_app/models/vehicle_models.dart';

class VehicleRepository {
  final VehicleApiService _apiService;

  // Create BehaviorSubject instances for caching
  final BehaviorSubject<List<int>> _yearsCache = BehaviorSubject<List<int>>();
  final BehaviorSubject<Map<int, List<String>>> _brandsCache =
      BehaviorSubject<Map<int, List<String>>>();
  final BehaviorSubject<Map<String, List<String>>> _modelsCache =
      BehaviorSubject<Map<String, List<String>>>();

  VehicleRepository({VehicleApiService? apiService})
      : _apiService = apiService ?? VehicleApiService();

  Future<List<int>> getYears({bool forceRefresh = false}) async {
    // Changed condition to check if value exists
    if (!_yearsCache.hasValue || _yearsCache.value.isEmpty || forceRefresh) {
      try {
        print('Fetching years from API');
        final years = await _apiService.getYears();
        print('API returned years: $years');
        _yearsCache.add(years);
        return years;
      } catch (e) {
        print('Error fetching years: $e');
        if (_yearsCache.hasValue) {
          return _yearsCache.value;
        }
        rethrow;
      }
    }
    return _yearsCache.value;
  }

  Future<List<String>> getBrands(int year, {bool forceRefresh = false}) async {
    if (!_brandsCache.hasValue ||
        !_brandsCache.value.containsKey(year) ||
        forceRefresh) {
      try {
        final brands = await _apiService.getBrands(year);
        // Create a new map with the correct types and copy existing data
        final Map<int, List<String>> newCache = {};
        if (_brandsCache.hasValue) {
          newCache.addAll(_brandsCache.value);
        }
        newCache[year] = brands;
        _brandsCache.add(newCache);
        return brands;
      } catch (e) {
        if (_brandsCache.hasValue && _brandsCache.value.containsKey(year)) {
          return _brandsCache.value[year]!;
        }
        rethrow;
      }
    }
    return _brandsCache.value[year]!;
  }

  Future<List<String>> getModels(int year, String brand,
      {bool forceRefresh = false}) async {
    final cacheKey = '$year-$brand';
    if (!_modelsCache.hasValue ||
        !_modelsCache.value.containsKey(cacheKey) ||
        forceRefresh) {
      try {
        final models = await _apiService.getModels(year, brand);
        // Create a new map with the correct types and copy existing data
        final Map<String, List<String>> newCache = {};
        if (_modelsCache.hasValue) {
          newCache.addAll(_modelsCache.value);
        }
        newCache[cacheKey] = models;
        _modelsCache.add(newCache);
        return models;
      } catch (e) {
        if (_modelsCache.hasValue && _modelsCache.value.containsKey(cacheKey)) {
          return _modelsCache.value[cacheKey]!;
        }
        rethrow;
      }
    }
    return _modelsCache.value[cacheKey]!;
  }

  Future<List<Vehicle>> getVehicleDetails({
    required int year,
    required String brand,
    required String model,
  }) async {
    try {
      return await _apiService.getVehicleDetails(
        year: year,
        brand: brand,
        model: model,
      );
    } catch (e) {
      print('Error in repository getVehicleDetails: $e');
      rethrow;
    }
  }

  Future<List<Vehicle>> getVehicles({
    required int year,
    String? brand,
    String? model,
  }) async {
    return _apiService.getVehicles(
      year: year,
      brand: brand,
      model: model,
    );
  }

  void clearCache() {
    if (!_yearsCache.isClosed) _yearsCache.add([]);
    if (!_brandsCache.isClosed) _brandsCache.add({});
    if (!_modelsCache.isClosed) _modelsCache.add({});
  }

  void dispose() {
    _yearsCache.close();
    _brandsCache.close();
    _modelsCache.close();
  }
}
