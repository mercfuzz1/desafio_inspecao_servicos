import 'inspection_sync_status.dart';

class Inspection {
  final String clientId;
  final String? serverId;

  final String workOrderId;

  final String observation;
  final String? condition;

  final String photoPath;

  final double latitude;
  final double longitude;

  final DateTime capturedAt;

  final InspectionSyncStatus syncStatus;
  final String? syncError;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Inspection({
    required this.clientId,
    this.serverId,
    required this.workOrderId,
    required this.observation,
    this.condition,
    required this.photoPath,
    required this.latitude,
    required this.longitude,
    required this.capturedAt,
    required this.syncStatus,
    this.syncError,
    required this.createdAt,
    required this.updatedAt,
  });
}