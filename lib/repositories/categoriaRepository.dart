import '../entities/categoriaModel.dart';
import '../settings/db_conection.dart';

class CategoriaRepository {
  final DbConnection db = DbConnection();
  final String tableName = "categorias";

  Future<int> insert(CategoriaModel categoria) async {
    return await db.insert(tableName, categoria.toMap());
  }

  Future<int> update(CategoriaModel categoria) async {
    return await db.update(
      tableName,
      categoria.toMap(),
      categoria.id!,
    );
  }

  Future<int> delete(int id) async {
    return await db.delete(tableName, id);
  }

  Future<List<CategoriaModel>> getAll() async {
    List<Map<String, dynamic>> result =
        await db.getAll(tableName);

    return result
        .map((e) => CategoriaModel.fromMap(e))
        .toList();
  }
}