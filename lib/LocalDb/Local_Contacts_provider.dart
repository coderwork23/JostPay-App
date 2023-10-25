import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBContactsProvider {

  static late Database _database;
  static final DBContactsProvider dbContactsProvider = DBContactsProvider._();

  DBContactsProvider._();

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();

    return _database;
  }

  initDB() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentDirectory.path, 'contact_manager.db');

    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute('CREATE TABLE Contacts('
              'image TEXT,'
              'name TEXT,'
              'address TEXT'
              ')');
        });
  }

  late List contactList;
  getAllContacts() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM Contacts");
    contactList = res;
  }

  createContacts(String image,String name,String address) async{
    final db= await database;
    final res = await db.rawInsert('INSERT INTO Contacts(image, name, address) VALUES("$image", "$name", "$address")');
    return res;
  }

  Future<int> deleteAllContacts() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM Contacts');
    return res;
  }

  Future<int> deleteContact(String id) async {
    final db = await database;
    final res = await db.rawDelete("DELETE FROM Contacts Where name = '$id'");
    return res;
  }

}
