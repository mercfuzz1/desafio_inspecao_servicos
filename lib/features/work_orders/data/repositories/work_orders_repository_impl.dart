import '../../domain/entities/work_order.dart';
import '../../domain/repositories/work_orders_repository.dart';
import '../datasources/work_orders_local_data_source.dart';
import '../datasources/work_orders_remote_data_source.dart';

class WorkOrdersRepositoryImpl implements WorkOrdersRepository {
  final WorkOrdersRemoteDataSource remoteDataSource;
  final WorkOrdersLocalDataSource localDataSource;

  WorkOrdersRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<WorkOrder>> getWorkOrders() async {
    try {
      // 1. Tenta buscar as OS atualizadas da API.
      final workOrders = await remoteDataSource.getWorkOrders();

      // 2. Se conseguiu, atualiza o cache local.
      await localDataSource.saveWorkOrders(workOrders);

      // 3. Retorna os dados mais recentes.
      return workOrders;
    } catch (error) {
      // 4. Se a API falhar, tenta utilizar o cache local.
      final localWorkOrders = await localDataSource.getWorkOrders();

      // 5. Se houver dados salvos, utiliza-os.
      if (localWorkOrders.isNotEmpty) {
        return localWorkOrders;
      }

      // 6. Se não houver cache, mantém o comportamento
      // anterior e deixa o erro chegar ao BLoC.
      rethrow;
    }
  }
}