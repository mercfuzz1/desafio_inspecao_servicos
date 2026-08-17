import '../../../../core/network/dio_client.dart';
import '../../models/work_order_model.dart';

class WorkOrdersRemoteDataSource {
  final DioClient dioClient;

  WorkOrdersRemoteDataSource(this.dioClient);

  Future<List<WorkOrderModel>> getWorkOrders() async {
    final response = await dioClient.dio.get(
      '/work-orders',
    );

    final data = response.data as List<dynamic>;

    return data
        .map(
          (item) => WorkOrderModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}