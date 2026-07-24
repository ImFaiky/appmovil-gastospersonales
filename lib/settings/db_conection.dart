import 'package:sqflite/sqflite.dart'; //llama a la libreria
import 'package:path/path.dart'; //llama a la libreria para manejar rutas

class DbConnection {
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDB();
    await _seedDatabase(_database!);
    return _database!;
  }

  Future<void> _seedDatabase(Database db) async {
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM categorias'));
    if (count == 0) {
      final List<Map<String, String>> defaultCategories = [
        {'nombre': 'Alimentación', 'tipo': 'gasto', 'icono': 'shopping_cart_rounded', 'color': '0xFF60A5FA'},
        {'nombre': 'Transporte', 'tipo': 'gasto', 'icono': 'directions_bus_rounded', 'color': '0xFFFBBF24'},
        {'nombre': 'Salud', 'tipo': 'gasto', 'icono': 'medical_services_rounded', 'color': '0xFFF87171'},
        {'nombre': 'Educación', 'tipo': 'gasto', 'icono': 'menu_book_rounded', 'color': '0xFF22D3EE'},
        {'nombre': 'Entretenimiento', 'tipo': 'gasto', 'icono': 'movie_creation_rounded', 'color': '0xFFC084FC'},
        {'nombre': 'Vivienda', 'tipo': 'gasto', 'icono': 'home_rounded', 'color': '0xFFFB923C'},
        {'nombre': 'Ropa', 'tipo': 'gasto', 'icono': 'checkroom_rounded', 'color': '0xFF34D399'},
        {'nombre': 'Servicios', 'tipo': 'gasto', 'icono': 'lightbulb_rounded', 'color': '0xFFF59E0B'},
        {'nombre': 'Otros', 'tipo': 'gasto', 'icono': 'inventory_2_rounded', 'color': '0xFFA78BFA'},
        
        {'nombre': 'Salario', 'tipo': 'ingreso', 'icono': 'work_rounded', 'color': '0xFFC084FC'},
        {'nombre': 'Freelance', 'tipo': 'ingreso', 'icono': 'laptop_chromebook_rounded', 'color': '0xFF60A5FA'},
        {'nombre': 'Inversiones', 'tipo': 'ingreso', 'icono': 'trending_up_rounded', 'color': '0xFF34D399'},
        {'nombre': 'Otros', 'tipo': 'ingreso', 'icono': 'inventory_2_rounded', 'color': '0xFFFB923C'},
      ];
      for (var cat in defaultCategories) {
        await db.insert('categorias', cat);
      }
    }
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
        fecha DATETIME,
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
        color TEXT
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
