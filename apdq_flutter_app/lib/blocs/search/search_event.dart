import 'package:equatable/equatable.dart';

// Events
abstract class VehicleSearchEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Event when the screen is first loaded
class LoadInitialDataEvent extends VehicleSearchEvent {}

// Events for each dropdown selection
class YearSelectedEvent extends VehicleSearchEvent {
  final int year;
  YearSelectedEvent(this.year);

  @override
  List<Object?> get props => [year];
}

class BrandSelectedEvent extends VehicleSearchEvent {
  final String brand;
  BrandSelectedEvent(this.brand);

  @override
  List<Object?> get props => [brand];
}

class ModelSelectedEvent extends VehicleSearchEvent {
  final String model;
  ModelSelectedEvent(this.model);

  @override
  List<Object?> get props => [model];
}

class SearchVehiclesEvent extends VehicleSearchEvent {
  SearchVehiclesEvent();

  @override
  List<Object?> get props => [];
}

class SearchVehicleDetailsEvent extends VehicleSearchEvent {
  final int year;
  final String brand;
  final String model;

  SearchVehicleDetailsEvent({
    required this.year,
    required this.brand,
    required this.model,
  });

  @override
  List<Object?> get props => [year, brand, model];
}
