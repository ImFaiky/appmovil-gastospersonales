import '../entities/cuentaModel.dart';
import '../settings/db_conection.dart';

class CuentaRepository {
  final String tableName = 'cuentas';
  final DbConnection db = DbConnection();

  Future<int> insert(Cuentamodel cuenta) async {
    return await db.insert(tableName, cuenta.toMap());
  }

  Future<int> update(Cuentamodel cuenta) async {
    return await db.update(tableName, cuenta.toMap(), cuenta.id!);
  }

  Future<int> delete(int id) async {
    return await db.delete(tableName, id);
  }

  Future<List<Cuentamodel>> getAll(int userId) async {
    List<Map<String, dynamic>> result = await db.getAll(tableName);
    return result
        .where((map) => map['usuarioId'] == userId)
        .map((map) => Cuentamodel.fromMap(map))
        .toList();
  }

  Future<double> getSaldoTotal(int userId) async {
    List<Cuentamodel> cuentas = await getAll(userId);
    double total = 0;
    for (var cuenta in cuentas) {
      total += cuenta.saldo;
    }
    return total;
  }
}
