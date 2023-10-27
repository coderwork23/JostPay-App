import 'dart:io';
import 'package:jost_pay_wallet/Models/AccountTokenModel.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBDefaultTokenProvider{

  static Database? _database;
  static final DBDefaultTokenProvider dbTokenProvider = DBDefaultTokenProvider._();

  DBDefaultTokenProvider._();

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await initDB();

    return _database;
  }

  initDB() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentDirectory.path, 'defaultToken_manager.db');

    return await openDatabase(path, version: 3, onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute('CREATE TABLE DefaultToken('
              'id INTEGER,'
              'token_id INTEGER,'
              'acc_address TEXT,'
              'network_id INTEGER,'
              'market_id INTEGER,'
              'name TEXT,'
              'type TEXT,'
              'address TEXT,'
              'symbol TEXT,'
              'decimals INTEGER,'
              'logo TEXT,'
              'balance TEXT,'
              'network_name TEXT,'
              'price REAL,'
              'percent_change_24h REAL,'
              'accountId TEXT,'
              'explorer_url TEXT'
              ')');
        },
        onUpgrade: (Database db, int version,int newVersion)async{
          if (version < newVersion) {
            db.execute("ALTER TABLE AccountAddress ADD COLUMN isCustom INTEGER;");
          }
    });
  }

  createToken(AccountTokenList newToken) async{
    final db= await database;
    final res = await db!.insert('DefaultToken', newToken.toJson());
    // print("data add here $res");
    return res;
  }

  updateToken(AccountTokenList newToken,id,acId) async{

    print("token id :---> ${id}");
    print("token name :---> ${newToken.name}");

    final db= await database;
    Map<String, dynamic> data = {
      "id": newToken.id,
      "token_id": newToken.token_id,
      "acc_address": newToken.accAddress,
      "network_id": newToken.networkId,
      "market_id": newToken.marketId,
      "name": newToken.name,
      "type": newToken.type,
      "address": newToken.address,
      "symbol": newToken.symbol,
      "price":newToken.price,
      "decimals": newToken.decimals,
      "logo": newToken.logo,
      "network_name": newToken.networkName,
      "explorer_url": newToken.explorer_url,
      "accountId": newToken.accountId,
    };

    final res = await db!.update('DefaultToken', data, where: "id = ? AND accountId = ? ",whereArgs: [id,acId]);
    print("update res --->  $res");
    getAccountToken(acId);
    return res;
  }




  Future<int> deleteAllToken() async {
    final db = await database;
    final res = await db!.rawDelete('DELETE FROM DefaultToken');
    return res;
  }

  Future<int> deleteToken(String id) async {
    final db = await database;
    final res = await db!.rawDelete("DELETE FROM DefaultToken Where id = $id");
    return res;
  }

  Future<int> deleteAccountToken(String accountId) async {
    final db = await database;
    final res = await db!.rawDelete("DELETE FROM DefaultToken Where accountId = '$accountId'");
    return res;
  }

  List<AccountTokenList> tokenDefaultList = [];
  getAccountToken(String accountId) async {
    tokenDefaultList.clear();
    final db = await database;
    final res = await db!.rawQuery("SELECT * FROM DefaultToken Where accountId = '$accountId'");

    // print("getAccountToken ${res.length}");
    List<AccountTokenList> list = res.map((c) {
      print("c ---> $c");

      return AccountTokenList.fromJson(
          c,
          accountId,
      );
    }).toList();
    tokenDefaultList = list;
    tokenDefaultList.sort((a, b) {
      var aValue = a.name;
      var bValue = b.name;
      return aValue.compareTo(bValue);
    });

     // print("check this value this ${tokenList.length}");
    return list;
  }

  updateTokenPrice(double live_price,double gain_loss,int id) async {

    // print("$live_price,$gain_loss,$symbol");

    List<AccountTokenList> list;

    final db = await database;
    final res = await db!.rawUpdate("UPDATE DefaultToken SET price = $live_price, percent_change_24h = $gain_loss WHERE market_id = '$id'");

    //getAccountToken(address,btcAddress,solAddress,dotAddress);

    return res;
  }

  updateTokenBalance(String balance,String id) async {

    final db = await database;
    final res = await db!.rawUpdate("UPDATE DefaultToken SET balance = $balance WHERE id = '$id'");

    //getAccountToken(address,btcAddress,solAddress,dotAddress);

    return res;
  }

  getTokenUsdPrice (id) async{
    final db = await database;
    final res = await db!.rawQuery("SELECT price FROM DefaultToken Where token_id = '$id'");
    return res;
  }

}