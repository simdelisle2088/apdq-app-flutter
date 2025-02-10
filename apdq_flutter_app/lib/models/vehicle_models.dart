import 'package:equatable/equatable.dart';

class FileBase extends Equatable {
  final String fileName;
  final String filePath;
  final int fileSize;
  final DateTime uploadDate;

  const FileBase({
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.uploadDate,
  });

  @override
  List<Object?> get props => [fileName, filePath, fileSize, uploadDate];

  factory FileBase.fromJson(Map<String, dynamic> json) {
    return FileBase(
      fileName: json['file_name'],
      filePath: json['file_path'],
      fileSize: json['file_size'],
      uploadDate: DateTime.parse(json['upload_date']),
    );
  }
}

// Model for neutral procedure PDF files
class NeutralPDF extends FileBase {
  final int id;
  final int vehicleId;

  const NeutralPDF({
    required this.id,
    required this.vehicleId,
    required super.fileName,
    required super.filePath,
    required super.fileSize,
    required super.uploadDate,
  });

  factory NeutralPDF.fromJson(Map<String, dynamic> json) {
    return NeutralPDF(
      id: json['id'],
      vehicleId: json['vehicle_id'],
      fileName: json['file_name'],
      filePath: json['file_path'],
      fileSize: json['file_size'],
      uploadDate: DateTime.parse(json['upload_date']),
    );
  }

  @override
  List<Object?> get props => [...super.props, id, vehicleId];
}

// Model for deactivation procedure PDF files
class DeactivationPDF extends FileBase {
  final int id;
  final int vehicleId;

  const DeactivationPDF({
    required this.id,
    required this.vehicleId,
    required super.fileName,
    required super.filePath,
    required super.fileSize,
    required super.uploadDate,
  });

  factory DeactivationPDF.fromJson(Map<String, dynamic> json) {
    return DeactivationPDF(
      id: json['id'],
      vehicleId: json['vehicle_id'],
      fileName: json['file_name'],
      filePath: json['file_path'],
      fileSize: json['file_size'],
      uploadDate: DateTime.parse(json['upload_date']),
    );
  }

  @override
  List<Object?> get props => [...super.props, id, vehicleId];
}

// Model for vehicle images
class VehicleImage extends FileBase {
  final int id;
  final int vehicleId;

  const VehicleImage({
    required this.id,
    required this.vehicleId,
    required super.fileName,
    required super.filePath,
    required super.fileSize,
    required super.uploadDate,
  });

  factory VehicleImage.fromJson(Map<String, dynamic> json) {
    return VehicleImage(
      id: json['id'],
      vehicleId: json['vehicle_id'],
      fileName: json['file_name'],
      filePath: json['file_path'],
      fileSize: json['file_size'],
      uploadDate: DateTime.parse(json['upload_date']),
    );
  }

  @override
  List<Object?> get props => [...super.props, id, vehicleId];
}

// Main vehicle model
class Vehicle extends Equatable {
  final int id;
  final String brand;
  final String model;
  final int yearFrom;
  final int? yearTo;
  final int? delayTimeNeutral;
  final int? delayTimeDeactivation;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<NeutralPDF> neutralPdfs;
  final List<DeactivationPDF> deactivationPdfs;
  final List<VehicleImage> images;

  const Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.yearFrom,
    this.yearTo,
    this.delayTimeNeutral,
    this.delayTimeDeactivation,
    required this.createdAt,
    required this.updatedAt,
    this.neutralPdfs = const [],
    this.deactivationPdfs = const [],
    this.images = const [],
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      brand: json['brand'],
      model: json['model'],
      yearFrom: json['year_from'],
      yearTo: json['year_to'],
      delayTimeNeutral: json['delay_time_neutral'],
      delayTimeDeactivation: json['delay_time_deactivation'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      neutralPdfs: (json['neutral_pdfs'] as List?)
              ?.map((pdf) => NeutralPDF.fromJson(pdf))
              .toList() ??
          [],
      deactivationPdfs: (json['deactivation_pdfs'] as List?)
              ?.map((pdf) => DeactivationPDF.fromJson(pdf))
              .toList() ??
          [],
      images: (json['images'] as List?)
              ?.map((image) => VehicleImage.fromJson(image))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
        id,
        brand,
        model,
        yearFrom,
        yearTo,
        delayTimeNeutral,
        delayTimeDeactivation,
        createdAt,
        updatedAt,
        neutralPdfs,
        deactivationPdfs,
        images,
      ];
}
