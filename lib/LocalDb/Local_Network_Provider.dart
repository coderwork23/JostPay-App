import 'dart:io';
import 'package:jost_pay_wallet/Models/NetworkModel.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';


class DbNetwork{

  static Database? _database;
  static final DbNetwork dbNetwork = DbNetwork._();

  DbNetwork._();

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await initDB();

    return _database;
  }

  initDB() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentDirectory.path, 'network.db');

    return await openDatabase(path, version: 1, onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('CREATE TABLE Network('
            'id INTEGER PRIMARY KEY UNIQUE,'
            'name TEXT,'
            'symbol TEXT,'
            'weth TEXT,'
            'logo TEXT,'
            'url TEXT,'
            'chain INTEGER,'
            'note TEXT,'
            'tokenType TEXT,'
            'explorer_url TEXT,'
            'publicKeyName TEXT,'
            'privateKeyName TEXT,'
            'tokenEnable INTEGER,'
            'swapEnable INTEGER,'
            'isTxfees INTEGER,'
            'isEVM INTEGER'
            ')');
      },
    );
  }



  createNetwork(NetworkList networkLists) async{
    final db= await database;
    try {
      final res = await db!.insert("Network",networkLists.toJson());
      return res;
    }catch(e){}
  }


  updateNetwork(NetworkList networkLists) async{
    final db= await database;
    try {
      final res = await db!.update("Network",networkLists.toJson());
      // print("res update network $res");
      return res;
    }catch(e){}
  }

  List<NetworkList> networkList = [];
  List<NetworkList> newNetworkList = [];
  getNetwork() async {
    networkList.clear();
    newNetworkList.clear();

    final db = await database;
    final res = await db!.rawQuery("SELECT * FROM Network");

    List<NetworkList> list = res.map((c) {
      // print(int.parse("${c["isCustom"]}"));
      return NetworkList.fromJson(c);
    }).toList();
    networkList = list;

    if(list.isNotEmpty) {
      int bnbIndex = list.indexWhere((e) => e.id == 2);
      int ethIndex = list.indexWhere((e) => e.id == 1);
      if(list[bnbIndex] != -1 || list[ethIndex] != -1) {
        newNetworkList = [list[bnbIndex], list[ethIndex]];
      }
      newNetworkList.addAll(list.where((item) => item.id != 2 && item.id != 1));

    }
  }


  deleteAllNetwork() async {
    final db = await database;
    final res = await db!.rawQuery("DELETE FROM Network");
    return res;
  }
}