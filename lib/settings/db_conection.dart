import 'package:sqflite/sqflite.dart'; //llama a la libreria
import 'package:path/path.dart'; //llama a la libreria para manejar rutas

class DbConnection {
  static Database? _database; // el simbolo ? permite anual un requerido

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    //crear mi archivo sqlite dentro del dispositivo
    String path = join(await getDatabasesPath(), "gastos.db");
    String sqlUsuario = ('''
      CREATE TABLE usuario (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        pin INTEGER
      )
    ''');
    String sqlCuenta = ('''
      CREATE TABLE cuentas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        tipo TEXT,
        saldo REAL,
        color TEXT,
        usuarioId INTEGER,

        FOREIGN KEY (usuarioId) REFERENCES usuario(id)
      )
    ''');
    String sqlMovimientos = ('''
      CREATE TABLE movimientos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT,
        monto REAL,
        descripcion TEXT,
        fecha TEXT,
        cuentaId INTEGER,
        categoriaId INTEGER,

        FOREIGN KEY (cuentaId) REFERENCES cuentas(id),
        FOREIGN KEY (categoriaId) REFERENCES categorias(id)
      )
    ''');
    String sqlCategorias = ('''
      CREATE TABLE categorias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        tipo TEXT,
        icono TEXT,
        color TEXT,
      )
    ''');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(sqlUsuario);
        await db.execute(sqlCuenta);
        await db.execute(sqlMovimientos);
        await db.execute(sqlCategorias);
      },
    );
  }

  //generar mis metodos CRUD
  //insert
  Future<int> insert(String table, Map<String, dynamic> values) async {
    //insertar un dato a la bdd
    final db = await database;
    return await db.insert(table, values);
  }

  //update
  Future<int> update(String table, Map<String, dynamic> values, int id) async {
    //actualizar un dato de la bdd
    final db = await database;
    return await db.update(table, values, where: "id = ?", whereArgs: [id]);
  }

  //delete
  Future<int> delete(String table, int id) async {
    //eliminar un dato de la bdd
    final db = await database;
    return await db.delete(table, where: "id = ?", whereArgs: [id]);
  }

  //select
  Future<List<Map<String, dynamic>>> getAll(String table) async {
    //obtener todos los datos de la bdd
    final db = await database;
    return await db.query(table);
  }
}
