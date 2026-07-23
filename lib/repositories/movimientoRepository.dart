import '../entities/movimientoModel.dart';
import '../settings/db_conection.dart';

class MovimientoRepository {
  final String tableName = 'movimientos';
  final DbConnection db = DbConnection();

  Future<int> insert(Movimientomodel movimiento) async {
    return await db.insert(tableName, movimiento.toMap());
  }

  Future<int> update(Movimientomodel movimiento) async {
    return await db.update(tableName, movimiento.toMap(), movimiento.id!);
  }

  Future<int> delete(int id) async {
    return await db.delete(tableName, id);
  }

  Future<List<Movimientomodel>> getAll(int cuentaid) async {
    List<Map<String, dynamic>> result = await db.getAll(tableName);
    return result
        .where((map) => map['cuentaId'] == cuentaid)
        .map((map) => Movimientomodel.fromMap(map))
        .toList();
  }

  Future<double> getIngresos(int cuentaId) async {
    List<Movimientomodel> movimientos = await getAll(cuentaId);
    double ingresos = 0;
    for (var movimiento in movimientos) {
      if (movimiento.tipo == 'ingreso') {
        ingresos += movimiento.monto;
      }
    }
    return ingresos;
  }

  Future<double> getGastos(int cuentaId) async {
    List<Movimientomodel> movimientos = await getAll(cuentaId);
    double gastos = 0;
    for (var movimiento in movimientos) {
      if (movimiento.tipo == 'gasto') {
        gastos += movimiento.monto;
      }
    }
    return gastos;
  }

  Future<double> getAhorro(int cuentaId) async {
    double ingresos = await getIngresos(cuentaId);
    double gastos = await getGastos(cuentaId);
    return ingresos - gastos;
  }

  Future<List<Movimientomodel>> getLast(int userId) async {
    // 1. Obtener todas las cuentas del usuario para tener sus IDs
    final cuentasResult = await db.getAll('cuentas');
    final idsCuentasUsuario = cuentasResult
        .where((map) => map['usuarioId'] == userId)
        .map((map) => map['id'] as int)
        .toSet();

    // 2. Obtener todos los movimientos y filtrar los que pertenecen a esas cuentas
    final movimientosResult = await db.getAll(tableName);
    final movimientos = movimientosResult
        .map((map) => Movimientomodel.fromMap(map))
        .where((movimiento) => idsCuentasUsuario.contains(movimiento.cuentaId))
        .toList();

    // 3. Ordenar por fecha desc (más recientes primero) y tomar los primeros 8
    movimientos.sort((a, b) => b.fecha.compareTo(a.fecha));
    return movimientos.take(8).toList();
  }
}
