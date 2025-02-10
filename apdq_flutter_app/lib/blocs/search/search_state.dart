import 'package:apdq_flutter_app/models/vehicle_models.dart';
import 'package:equatable/equatable.dart';

class VehicleSearchState extends Equatable {
  final List<int> availableYears;
  final List<String> availableBrands;
  final List<String> availableModels;
  final int? selectedYear;
  final String? selectedBrand;
  final String? selectedModel;
  final List<Vehicle>? vehicles;
  final bool isLoading;
  final String? error;
  final Vehicle? selectedVehicle;

  const VehicleSearchState({
    this.selectedVehicle,
    this.availableYears = const [],
    this.availableBrands = const [],
    this.availableModels = const [],
    this.selectedYear,
    this.selectedBrand,
    this.selectedModel,
    this.vehicles,
    this.isLoading = false,
    this.error,
  });

  VehicleSearchState copyWith({
    Vehicle? selectedVehicle,
    List<int>? availableYears,
    List<String>? availableBrands,
    List<String>? availableModels,
    int? selectedYear,
    String? selectedBrand,
    String? selectedModel,
    List<Vehicle>? vehicles,
    bool? isLoading,
    String? error,
  }) {
    return VehicleSearchState(
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      availableYears: availableYears ?? this.availableYears,
      availableBrands: availableBrands ?? this.availableBrands,
      availableModels: availableModels ?? this.availableModels,
      selectedYear: selectedYear ?? this.selectedYear,
      selectedBrand: selectedBrand ?? this.selectedBrand,
      selectedModel: selectedModel ?? this.selectedModel,
      vehicles: vehicles ?? this.vehicles,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        availableYears,
        availableBrands,
        availableModels,
        selectedYear,
        selectedBrand,
        selectedModel,
        vehicles,
        isLoading,
        error,
      ];
}
