import '../entities/usuarioModel.dart';
import '../settings/db_conection.dart';

class Usuariorepository {
  final String tableName = 'usuario';
  final DbConnection db = DbConnection();

  Future<int> insert(UsuarioModel user) async {
    return await db.insert(tableName, user.toMap());
  }

  Future<int> update(UsuarioModel user) async {
    return await db.update(tableName, user.toMap(), user.id!);
  }

  Future<int> delete(int id) async {
    return await db.delete(tableName, id);
  }

  Future<List<UsuarioModel>> getAll() async {
    List<Map<String, dynamic>> result = await db.getAll(tableName);
    return result.map((map) => UsuarioModel.fromMap(map)).toList();
  }

  //login
  Future<UsuarioModel?> login(String nombre, int pin) async {
    List<UsuarioModel> users = await getAll();
    for (var user in users) {
      if (user.nombre == nombre && user.pin == pin) {
        return user;
      }
    }
    return null;
  }
}
