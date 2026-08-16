import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/inspection.dart';
import '../../domain/entities/inspection_sync_status.dart';
import '../../domain/repositories/inspections_repository.dart';
import 'inspection_form_event.dart';
import 'inspection_form_state.dart';

class InspectionFormBloc
    extends Bloc<InspectionFormEvent, InspectionFormState> {
  final InspectionsRepository repository;
  final String workOrderId;

  InspectionFormBloc({required this.repository, required this.workOrderId})
    : super(const InspectionFormState()) {
    on<InspectionObservationChanged>(_onObservationChanged);

    on<InspectionConditionChanged>(_onConditionChanged);

    on<InspectionPhotoChanged>(_onPhotoChanged);

    on<InspectionLocationChanged>(_onLocationChanged);

    on<SaveInspectionDraft>(_onSaveDraft);

    on<CompleteInspection>(_onComplete);
  }

  void _onObservationChanged(
    InspectionObservationChanged event,
    Emitter<InspectionFormState> emit,
  ) {
    emit(state.copyWith(observation: event.observation));
  }

  void _onConditionChanged(
    InspectionConditionChanged event,
    Emitter<InspectionFormState> emit,
  ) {
    emit(state.copyWith(condition: event.condition));
  }

  void _onPhotoChanged(
    InspectionPhotoChanged event,
    Emitter<InspectionFormState> emit,
  ) {
    emit(state.copyWith(photoPath: event.photoPath));
  }

  void _onLocationChanged(
    InspectionLocationChanged event,
    Emitter<InspectionFormState> emit,
  ) {
    emit(state.copyWith(latitude: event.latitude, longitude: event.longitude));
  }

  Future<void> _onSaveDraft(
    SaveInspectionDraft event,
    Emitter<InspectionFormState> emit,
  ) async {
    await _save(status: InspectionSyncStatus.draft, emit: emit);
  }

  Future<void> _onComplete(
    CompleteInspection event,
    Emitter<InspectionFormState> emit,
  ) async {
    if (state.observation.trim().length < 10) {
      emit(
        state.copyWith(
          status: InspectionFormStatus.error,
          errorMessage: 'A observação deve possuir pelo menos 10 caracteres.',
        ),
      );

      return;
    }

    if (state.photoPath == null) {
      emit(
        state.copyWith(
          status: InspectionFormStatus.error,
          errorMessage: 'Adicione uma foto da inspeção.',
        ),
      );

      return;
    }

    if (state.latitude == null || state.longitude == null) {
      emit(
        state.copyWith(
          status: InspectionFormStatus.error,
          errorMessage: 'Capture a localização da inspeção.',
        ),
      );

      return;
    }

    await _save(status: InspectionSyncStatus.pending, emit: emit);
  }

  Future<void> _save({
    required InspectionSyncStatus status,
    required Emitter<InspectionFormState> emit,
  }) async {
    emit(state.copyWith(status: InspectionFormStatus.saving));

    try {
      final now = DateTime.now();

      final inspection = Inspection(
        clientId: _generateClientId(),
        workOrderId: workOrderId,
        observation: state.observation,
        condition: state.condition,
        photoPath: state.photoPath ?? '',
        latitude: state.latitude ?? 0,
        longitude: state.longitude ?? 0,
        capturedAt: now,
        syncStatus: status,
        createdAt: now,
        updatedAt: now,
      );

      await repository.save(inspection);

      emit(
        state.copyWith(
          status: InspectionFormStatus.success,
          syncStatus: status,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: InspectionFormStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  String _generateClientId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }
}
