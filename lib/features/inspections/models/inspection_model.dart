enum SyncStatus {
  draft,
  pending,
  synced,
  failed,
}

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

  final SyncStatus syncStatus;
  final String? syncError;

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
  });
}