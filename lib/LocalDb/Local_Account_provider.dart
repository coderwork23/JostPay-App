import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../Models/newAccountModel.dart';

class DBAccountProvider {

  static Database? _database;
  static final DBAccountProvider dbAccountProvider = DBAccountProvider._();

  DBAccountProvider._();

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await initDB();

    return _database;
  }

  initDB() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentDirectory.path, 'account_manager.db');

    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute('CREATE TABLE Account('
              'id INTEGER,'
              'device_id TEXT,'
              'name TEXT,'
              'mnemonic TEXT'
              ')');
        });
  }

  //List<AccountList> accountList = [];
  List<NewAccountList> newAccountList = [];
  getAllAccount() async {

    newAccountList.clear();

    final db = await database;
    final res = await db!.rawQuery("SELECT * FROM Account");

    //print("New Account Data : " + res.toString());

/*    var accountListNew = [];
    for(int i=0; i<res.length; i++){

      Map<String, dynamic> data = res[i];

      var addressArray = data["address"].substring(0, data["address"].length - 1);
      var data2 = addressArray.split("-");

      List finalPublicArray = [];
      for(int j=0;j<data2.length;j++){

        var data3 = data2[j].split(":");

        var publicArray = {
          "id" : data3[0],
          "address" : data3[1],
          "keyName" : data3[2],
        };

        finalPublicArray.add(publicArray);
      }

      var privateArray = data["privateKey"].substring(0, data["privateKey"].length - 1);
      var private2 = privateArray.split("-");
      List finalPrivateArray = [];

      for(int j=0;j<private2.length;j++){

        var private3 = private2[j].split(":");
        var privateArray = {
          "id" : private3[0],
          "address" : private3[1],
          "keyName" : private3[2],
        };

        finalPrivateArray.add(privateArray);
      }

      var accountArray = {
        "id" : "${res[i]["id"]}",
        "device_id" : "${res[i]["device_id"]}",
        "name" : "${res[i]["name"]}",
        "mnemonic" : "${res[i]["mnemonic"]}",
        "publicList" : finalPublicArray,
        "privateList" : finalPrivateArray
      };

      //print("New Account Data :" + accountArray.toString());

      accountListNew.add(accountArray);

    }*/

    List<NewAccountList> list = res.map<NewAccountList>((json) => NewAccountList.fromJson(json)).toList();
    newAccountList.addAll(list);


    //print("New Account :" + newAccountList.length.toString());

  }

  createAccount(String id,String deviceId,String name,String mnemonic) async{
    final db= await database;
    final res = await db!.rawInsert('INSERT INTO Account(id, device_id, name, mnemonic) VALUES("$id", "$deviceId", "$name", "$mnemonic")');
    return res;
  }


  Future<int> deleteAllAccount() async {
    final db = await database;
    final res = await db!.rawDelete('DELETE FROM Account');
    return res;
  }

  Future<int> deleteAccount(String id) async {
    final db = await database;
    final res = await db!.rawDelete("DELETE FROM Account Where id = '$id'");
    return res;
  }


  updateAccount(int id,String seedPharse,String privateAddress,String btcPrivateKey,String solPrivateKey,String dotPrivateKey) async {

    final db = await database;
    final res = await db!.rawQuery("UPDATE Account SET mnemonic = '$seedPharse',privateKey = '$privateAddress',btcPrivateKey = '$btcPrivateKey',solPrivateKey = '$solPrivateKey', dotPrivateKey = '$dotPrivateKey' WHERE id = '$id'");

    final res2 = await db.rawQuery("SELECT * FROM Account");
    //print(res2);
    return res;

  }

  updateAccountName(int id,String name) async {

    final db = await database;
    final res = await db!.rawQuery("UPDATE Account SET name = '$name' WHERE id = '$id'");

    final res2 = await db.rawQuery("SELECT * FROM Account");
    //print(res2);
    return res;

  }

}
