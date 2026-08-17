import '../../domain/entities/inspection_sync_status.dart';

enum InspectionFormStatus { initial, saving, success, error }

class InspectionFormState {
  final String observation;
  final String? condition;
  final String? photoPath;
  final double? latitude;
  final double? longitude;
  final bool isGettingLocation;

  final InspectionSyncStatus? syncStatus;

  final InspectionFormStatus status;
  final String? errorMessage;

  const InspectionFormState({
    this.observation = '',
    this.condition,
    this.photoPath,
    this.latitude,
    this.longitude,
    this.syncStatus,
    this.status = InspectionFormStatus.initial,
    this.errorMessage,
    this.isGettingLocation = false,
  });

  InspectionFormState copyWith({
    String? observation,
    String? condition,
    String? photoPath,
    double? latitude,
    double? longitude,
    InspectionSyncStatus? syncStatus,
    InspectionFormStatus? status,
    String? errorMessage,
    bool? isGettingLocation,
  }) {
    return InspectionFormState(
      observation: observation ?? this.observation,
      condition: condition ?? this.condition,
      photoPath: photoPath ?? this.photoPath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      syncStatus: syncStatus ?? this.syncStatus,
      status: status ?? this.status,
      errorMessage: errorMessage,
      isGettingLocation: isGettingLocation ?? this.isGettingLocation,
    );
  }
}
