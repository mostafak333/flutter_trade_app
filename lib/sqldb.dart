import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SqlDb {
  static Database? _db;

  Future<Database?> get db async {
    if (_db == null) {
      _db = await initialDb();
      return _db;
    } else {
      return _db;
    }
  }

  initialDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'business.db');
    //print("DB path ==> " + path);
    Database myDb = await openDatabase(path,
        onCreate: _onCreate, version: 1, onUpgrade: _onUpgrade);
    return myDb;
  }

  _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      //  await _updateProductTable(db);
    }

    // Add more migration logic for other versions as needed
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE "projects" (
      "id" INTEGER PRIMARY KEY AUTOINCREMENT,
      "name" VARCHAR(255) NOT NULL,
      "email" VARCHAR(255) UNIQUE NOT NULL,
      "password" VARCHAR(255) NOT NULL,
      "image_path" TEXT,
      "created_at" timestamp DATE DEFAULT (datetime('now','localtime'))
    )
    ''');

    await db.execute('''
    CREATE TABLE "products" (
      "id" INTEGER PRIMARY KEY AUTOINCREMENT,
      "project_id" INTEGER NOT NULL,
      "name" VARCHAR(255) NOT NULL,
      "wholesalePrice" DECIMAL(10,2) NOT NULL,
      "salePrice" DECIMAL(10,2) NOT NULL,
      "locked" INTEGER DEFAULT 0,
      "quantity" INTEGER DEFAULT 0,
      "display_quantity" INTEGER DEFAULT 0,
      "inventory_quantity" INTEGER DEFAULT 0,
      "created_at" timestamp DATE DEFAULT (datetime('now','localtime')),
      FOREIGN KEY (project_id) REFERENCES projects(id)
    )
    ''');

    await db.execute('''
    CREATE TABLE "sales" (
      "id" INTEGER PRIMARY KEY AUTOINCREMENT,
      "project_id" INTEGER NOT NULL,
      "product_id" INTEGER NOT NULL,
      "sold_price" DECIMAL(10,2) NOT NULL,
      "created_at" timestamp DATE DEFAULT (datetime('now','localtime')),
      FOREIGN KEY (project_id) REFERENCES projects(id),
      FOREIGN KEY (product_id) REFERENCES products(id)
    )
    ''');

    //print("<=== Create Database And Tables ===>");
  }

/*  Future<void> _updateProductTable(Database db) async {
    await db.execute('''
    ALTER TABLE "products"
    ADD COLUMN "display_quantity" INTEGER DEFAULT 0;
    ''');

    await db.execute('''
    ALTER TABLE "products"
    ADD COLUMN
    ''');
  }*/

  readData(String sql) async {
    Database? myDb = await db;
    List<Map> response = await myDb!.rawQuery(sql);
    return response;
  }

  insertData(String sql) async {
    Database? myDb = await db;
    int response = await myDb!.rawInsert(sql);
    return response;
  }

  updateData(String sql) async {
    Database? myDb = await db;
    int response = await myDb!.rawUpdate(sql);
    return response;
  }

  deleteData(String sql) async {
    Database? myDb = await db;
    int response = await myDb!.rawDelete(sql);
    return response;
  }

  dropDataBase() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'business.db');
    await deleteDatabase(path);
    //print("<=== Drop Database ===>");
  }

  Future<Map<String, dynamic>?> authenticateProject(
      String name, String password) async {
    var dbClient = await db;
    List<Map> result = await dbClient!.query(
      'projects',
      where: 'name = ? AND password = ?',
      whereArgs: [name, password],
    );
    if (result.isNotEmpty) {
      return result.first as Map<String, dynamic>;
    }
    return null;
  }
  Future<String> exportDatabase() async {
    // Get the path to the current SQLite database
    String dbPath = await getDatabasesPath();
    String fullDbPath = '$dbPath/business.db';

    // Get a temporary directory for the export
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = '${tempDir.path}/backup.db';

    // Copy the database file to the temp directory
    File dbFile = File(fullDbPath);
    await dbFile.copy(tempPath);
    return tempPath;
  }
}
