import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
        onCreate: _onCreate, version: 3, onUpgrade: _onUpgrade);
    return myDb;
  }

  _onUpgrade(Database db, int oldVersion, int newVersion) {
    //print("<=== onUpgrade ===>");
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE "products" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "name" VARCHAR(255) NOT NULL,
    "wholesalePrice" DECIMAL(10,2) NOT NULL,
    "salePrice" DECIMAL(10,2) NOT NULL,
    "locked" INTEGER DEFAULT 0,
    "created_at" timestamp DATE DEFAULT (datetime('now','localtime'))
    )
    ''');
    await db.execute('''
    CREATE TABLE sales (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "product_id" INTEGER NOT NULL,
    'sold_price' DECIMAL(10,2) NOT NULL,
    "created_at" timestamp DATE DEFAULT (datetime('now','localtime')),
    FOREIGN KEY (product_id) REFERENCES products(id)
    )
    ''');
    //print("<=== Create Database And Table ===>");
  }

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
}
