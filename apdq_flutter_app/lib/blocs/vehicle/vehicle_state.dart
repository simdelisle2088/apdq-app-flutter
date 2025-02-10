import 'package:equatable/equatable.dart';
import 'package:apdq_flutter_app/models/vehicle_models.dart';

enum VehicleStatus { initial, loading, loaded, error }

class VehicleState extends Equatable {
  final VehicleStatus status;
  final Vehicle? vehicle;
  final String? errorMessage;

  const VehicleState({
    this.status = VehicleStatus.initial,
    this.vehicle,
    this.errorMessage,
  });

  VehicleState copyWith({
    VehicleStatus? status,
    Vehicle? vehicle,
    String? errorMessage,
  }) {
    return VehicleState(
      status: status ?? this.status,
      vehicle: vehicle ?? this.vehicle,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, vehicle, errorMessage];
}
