import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/entities/inspection.dart';

class InspectionsRemoteDataSource {
  final DioClient dioClient;

  const InspectionsRemoteDataSource(
    this.dioClient,
  );

  Future<String> send(
    Inspection inspection,
  ) async {
    final photoFile = File(
      inspection.photoPath,
    );

    final formData = FormData.fromMap({
      'clientId': inspection.clientId,
      'workOrderId': inspection.workOrderId,
      'observation': inspection.observation,
      'condition': inspection.condition,
      'latitude': inspection.latitude,
      'longitude': inspection.longitude,
      'capturedAt': inspection.capturedAt.toIso8601String(),
      'photo': await MultipartFile.fromFile(
        photoFile.path,
        filename: photoFile.uri.pathSegments.last,
      ),
    });

    final response = await dioClient.dio.post(
      '/inspections',
      data: formData,
    );

    return response.data['id'] as String;
  }
}