import 'dart:io';
import 'package:jost_pay_wallet/Models/AccountAddress.dart';
import 'package:jost_pay_wallet/Models/ExTransactionModel.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbExTransaction{

  static Database? _database;
  static final DbExTransaction dbExTransaction = DbExTransaction._();

  DbExTransaction._();

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await initDB();

    return _database;
  }

  initDB() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentDirectory.path, 'exTransaction.db');

    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute('CREATE TABLE ExTransaction('
              'status TEXT,'
              'payinAddress TEXT,'
              'payoutAddress TEXT,'
              'fromCurrency TEXT,'
              'toCurrency TEXT,'
              'validUntil TEXT,'
              'id TEXT,'
              'updatedAt TEXT,'
              'expectedSendAmount REAL,'
              'expectedReceiveAmount REAL,'
              'createdAt TEXT,'
              'accountId TEXT,'
              'isPartner TEXT'
              ')');
        },
    );
  }

  createExTransaction(ExTransactionModel newToken) async{
    // print("object newtoken ${newToken.id}");
    final db= await database;
    final res = await db!.insert('ExTransaction', newToken.toJson());
    // print("data add here $res");
    return res;
  }

  updateExTransaction(ExTransactionModel newToken,tokenId,id) async{
    final db= await database;

    final res = await db!.update('ExTransaction', newToken.toJson(), where: "id = ? AND accountId = ? ",whereArgs: [tokenId,id]);
    getExTransaction(id);
    return res;
  }

  List<ExTransactionModel> exTransactionList = [];
  getExTransaction(String accountId) async {

    final db = await database;
    final res = await db!.rawQuery("SELECT * FROM ExTransaction Where accountId = '$accountId'");

    List<ExTransactionModel> list = res.map((c) {
      return ExTransactionModel.fromJson(
        c,
        accountId,
      );
    }).toList();
    exTransactionList = list;
    return list;
  }


  ExTransactionModel? getTrxStatusData;
  getTrxStatus(String accountId,String id) async {

    final db = await database;
    final res = await db!.rawQuery("SELECT * FROM ExTransaction Where accountId = '$accountId' AND id = '$id'");

    if(res.isNotEmpty) {
      getTrxStatusData = ExTransactionModel.fromJson(
        res[0],
        accountId,
      );
    }
    return getTrxStatusData;
  }

  Future<int> deleteAllExTransaction() async {
    final db = await database;
    final res = await db!.rawDelete('DELETE FROM ExTransaction');
    return res;
  }

  Future<int> deleteExTransaction(String id) async {
    final db = await database;
    final res = await db!.rawDelete("DELETE FROM ExTransaction Where id = $id");
    return res;
  }

}