import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBSignTransactionProvider{

  static late Database? _database;
  static final DBSignTransactionProvider dbSignTransactionProvider = DBSignTransactionProvider._();

  DBSignTransactionProvider._();

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await initDB();

    return _database;
  }

  initDB() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentDirectory.path, 'sign_manager.db');

    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute('CREATE TABLE SignT('
              'date TEXT,'
              'text TEXT,'
              'type TEXT'
              ')');
        });
  }

  List SignTList = [];
  getAllSignT() async {

    final db = await database;
    final res = await db?.rawQuery("SELECT * FROM SignT");
    SignTList = res!;

  }

  Future<int?> deleteAllSign() async {
    final db = await database;
    final res = await db?.rawDelete('DELETE FROM SignT');
    return res;
  }

  createSignt(String date,String text,String type) async{
    final db= await database;
    final res = await db?.rawInsert('INSERT INTO SignT(date, text, type) VALUES("$date", "$text", "$type")');
    return res;
  }


}