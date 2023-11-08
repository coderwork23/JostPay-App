import 'dart:io';
import 'package:jost_pay_wallet/Models/AccountAddress.dart';
import 'package:jost_pay_wallet/Models/ExTransactionModel.dart';
import 'package:jost_pay_wallet/Models/SellHistoryModel.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbSellHistory{

  static Database? _database;
  static final DbSellHistory dbSellHistory = DbSellHistory._();

  DbSellHistory._();

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await initDB();

    return _database;
  }

  initDB() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentDirectory.path, 'sellHistory.db');

    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute('CREATE TABLE SellHistory('
              'amount_payable_ngn INTEGER,'
              'invoice TEXT,'
              'order_status TEXT,'
              'invoice_no TEXT,'
              'invoice_url TEXT,'
              'time INTEGER,'
              'type TEXT,'
              'payin_amount TEXT,'
              'payout_amount TEXT,'
              'payout_address TEXT,'
              'payin_url TEXT'
              ')');
        },
    );
  }

  createSellHistory(SellHistoryModel newToken) async{
    // print("object newtoken ${newToken.id}");
    final db= await database;
    final res = await db!.insert('SellHistory', newToken.toJson());
    // print("data add here $res");
    return res;
  }

  updateSellHistory(SellHistoryModel newToken,tokenId,id) async{
    final db= await database;

    final res = await db!.update('SellHistory', newToken.toJson(), where: "id = ? AND accountId = ? ",whereArgs: [tokenId,id]);
    getSellHistory(id);
    return res;
  }

  List<SellHistoryModel> sellHistoryList = [];
  getSellHistory(String accountId) async {

    final db = await database;
    final res = await db!.rawQuery("SELECT * FROM SellHistory Where accountId = '$accountId'");

    List<SellHistoryModel> list = res.map((c) {
      return SellHistoryModel.fromJson(
        c,
        accountId,
      );
    }).toList();
    sellHistoryList = list;
    return list;
  }


  SellHistoryModel? getTrxStatusData;
  getTrxStatus(String accountId,String id) async {

    final db = await database;
    final res = await db!.rawQuery("SELECT * FROM SellHistory Where accountId = '$accountId' AND id = '$id'");

    if(res.isNotEmpty) {
      getTrxStatusData = SellHistoryModel.fromJson(
        res[0],
        accountId,
      );
    }
    return getTrxStatusData;
  }

  Future<int> deleteAllSellHistory() async {
    final db = await database;
    final res = await db!.rawDelete('DELETE FROM SellHistory');
    return res;
  }

  Future<int> deleteSellHistory(String id) async {
    final db = await database;
    final res = await db!.rawDelete("DELETE FROM SellHistory Where id = $id");
    return res;
  }

}