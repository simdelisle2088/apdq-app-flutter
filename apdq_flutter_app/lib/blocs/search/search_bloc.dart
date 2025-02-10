import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apdq_flutter_app/blocs/search/search_event.dart';
import 'package:apdq_flutter_app/blocs/search/search_state.dart';
import 'package:apdq_flutter_app/repositories/vehicle_repository.dart';

class VehicleSearchBloc extends Bloc<VehicleSearchEvent, VehicleSearchState> {
  final VehicleRepository repository;

  VehicleSearchBloc({VehicleRepository? repository})
      : repository = repository ?? VehicleRepository(),
        super(const VehicleSearchState()) {
    on<LoadInitialDataEvent>(_onLoadInitialData);
    on<YearSelectedEvent>(_onYearSelected);
    on<BrandSelectedEvent>(_onBrandSelected);
    on<ModelSelectedEvent>(_onModelSelected);
    on<SearchVehiclesEvent>(_onSearchVehicles);
    on<SearchVehicleDetailsEvent>(_onSearchVehicleDetails);
  }

  Future<void> _onLoadInitialData(
    LoadInitialDataEvent event,
    Emitter<VehicleSearchState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      final years = await repository.getYears(forceRefresh: true);
      emit(state.copyWith(
        availableYears: years,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to load years: ${e.toString()}',
        isLoading: false,
      ));
    }
  }

  Future<void> _onYearSelected(
    YearSelectedEvent event,
    Emitter<VehicleSearchState> emit,
  ) async {
    try {
      // First, immediately emit a state that clears everything except the new year
      // This ensures the UI resets before we even try to load new brands
      emit(VehicleSearchState(
        availableYears: state.availableYears, // Keep the available years
        selectedYear: event.year, // Set the new year
        availableBrands: [], // Reset everything else
        selectedBrand: null,
        availableModels: [],
        selectedModel: null,
        isLoading: true,
      ));

      // Now load the brands for the new year
      final brands = await repository.getBrands(event.year);

      // Emit the final state with the new brands, keeping everything else reset
      emit(VehicleSearchState(
        availableYears: state.availableYears,
        selectedYear: event.year,
        availableBrands: brands,
        selectedBrand: null,
        availableModels: [],
        selectedModel: null,
        isLoading: false,
      ));
    } catch (e) {
      // If there's an error, maintain the year but keep everything else reset
      emit(VehicleSearchState(
        availableYears: state.availableYears,
        selectedYear: event.year,
        availableBrands: [],
        selectedBrand: null,
        availableModels: [],
        selectedModel: null,
        isLoading: false,
        error: 'Failed to load brands: ${e.toString()}',
      ));
    }
  }

  Future<void> _onBrandSelected(
    BrandSelectedEvent event,
    Emitter<VehicleSearchState> emit,
  ) async {
    if (state.selectedYear == null) return;

    try {
      emit(state.copyWith(
        isLoading: true,
        selectedBrand: event.brand,
        selectedModel: null,
        availableModels: [],
        error: null,
      ));

      final models =
          await repository.getModels(state.selectedYear!, event.brand);
      emit(state.copyWith(
        availableModels: models,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to load models: ${e.toString()}',
        isLoading: false,
      ));
    }
  }

  void _onModelSelected(
    ModelSelectedEvent event,
    Emitter<VehicleSearchState> emit,
  ) {
    emit(state.copyWith(
      selectedModel: event.model,
      error: null,
    ));
  }

  Future<void> _onSearchVehicles(
    SearchVehiclesEvent event,
    Emitter<VehicleSearchState> emit,
  ) async {
    if (state.selectedYear == null) return;

    try {
      emit(state.copyWith(isLoading: true, error: null));

      final vehicles = await repository.getVehicles(
        year: state.selectedYear!,
        brand: state.selectedBrand,
        model: state.selectedModel,
      );

      emit(state.copyWith(
        vehicles: vehicles,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'Failed to search vehicles: ${e.toString()}',
        isLoading: false,
      ));
    }
  }

  Future<void> _onSearchVehicleDetails(
    SearchVehicleDetailsEvent event,
    Emitter<VehicleSearchState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      final vehicles = await repository.getVehicleDetails(
        year: event.year,
        brand: event.brand,
        model: event.model,
      );

      if (vehicles.isNotEmpty) {
        emit(state.copyWith(
          selectedVehicle: vehicles.first,
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(
          error: 'Aucun véhicule trouvé',
          isLoading: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        error: 'Erreur: ${e.toString()}',
        isLoading: false,
      ));
    }
  }

  @override
  Future<void> close() {
    repository.dispose();
    return super.close();
  }
}
