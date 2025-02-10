import 'package:equatable/equatable.dart';

abstract class VehicleEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadVehicleDetails extends VehicleEvent {
  final int year;
  final String brand;
  final String model;

  LoadVehicleDetails({
    required this.year,
    required this.brand,
    required this.model,
  });

  @override
  List<Object?> get props => [year, brand, model];
}

class ViewPdf extends VehicleEvent {
  final String filePath;

  ViewPdf({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}
