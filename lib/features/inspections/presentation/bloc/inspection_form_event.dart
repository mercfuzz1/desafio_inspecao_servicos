import 'package:equatable/equatable.dart';

abstract class InspectionFormEvent extends Equatable {
  const InspectionFormEvent();

  @override
  List<Object?> get props => [];
}

class InspectionObservationChanged extends InspectionFormEvent {
  final String observation;

  const InspectionObservationChanged(
    this.observation,
  );

  @override
  List<Object?> get props => [observation];
}

class InspectionConditionChanged extends InspectionFormEvent {
  final String? condition;

  const InspectionConditionChanged(
    this.condition,
  );

  @override
  List<Object?> get props => [condition];
}

class InspectionPhotoChanged extends InspectionFormEvent {
  final String photoPath;

  const InspectionPhotoChanged(
    this.photoPath,
  );

  @override
  List<Object?> get props => [photoPath];
}

class InspectionLocationChanged extends InspectionFormEvent {
  final double latitude;
  final double longitude;

  const InspectionLocationChanged({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [
        latitude,
        longitude,
      ];
}

class SaveInspectionDraft extends InspectionFormEvent {
  const SaveInspectionDraft();
}

class CompleteInspection extends InspectionFormEvent {
  const CompleteInspection();
}