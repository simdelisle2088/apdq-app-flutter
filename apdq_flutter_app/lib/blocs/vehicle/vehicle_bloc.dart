import 'package:apdq_flutter_app/blocs/search/search_api_service.dart';
import 'package:apdq_flutter_app/blocs/vehicle/vehicle_event.dart';
import 'package:apdq_flutter_app/blocs/vehicle/vehicle_state.dart';
import 'package:apdq_flutter_app/config/env_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final VehicleApiService _vehicleApiService;

  VehicleBloc({
    required VehicleApiService vehicleApiService,
  })  : _vehicleApiService = vehicleApiService,
        super(const VehicleState()) {
    on<LoadVehicleDetails>(_onLoadVehicleDetails);
    on<ViewPdf>(_onViewPdf);
  }

  Future<void> _onLoadVehicleDetails(
    LoadVehicleDetails event,
    Emitter<VehicleState> emit,
  ) async {
    emit(state.copyWith(status: VehicleStatus.loading));

    try {
      // Using your existing VehicleApiService method
      final vehicles = await _vehicleApiService.getVehicleDetails(
        year: event.year,
        brand: event.brand,
        model: event.model,
      );

      if (vehicles.isEmpty) {
        emit(state.copyWith(
          status: VehicleStatus.error,
          errorMessage: 'Vehicle not found',
        ));
        return;
      }

      emit(state.copyWith(
        status: VehicleStatus.loaded,
        vehicle: vehicles.first,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: VehicleStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: VehicleStatus.error,
        errorMessage: 'An unexpected error occurred',
      ));
    }
  }

  Future<void> _onViewPdf(
    ViewPdf event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      final url = '${EnvConfig.filesBaseUrl}/${event.filePath}';
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        emit(state.copyWith(
          errorMessage: 'Impossible d\'ouvrir le PDF',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Erreur lors de l\'ouverture du PDF',
      ));
    }
  }
}
