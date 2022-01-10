import 'package:flutter/material.dart';
import 'package:number_painter/core/models/db_models/painter_progress_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initDB();
    return _database;
  }

  Future<Database> initDB() async {
    final databasessDirectory = await getDatabasesPath();
    final path = join(databasessDirectory, 'Painters.db');
    return openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE Painters (id TEXT PRIMARY KEY, shapes TEXT, isCompleted INTEGER)');
      },
    );
  }

  Future<int> addNewPainter(PainterProgressModel painter) async {
    final db = await database;
    return db!.insert(PainterProgressModel.table, painter.toMap());
  }

  Future<int> updatePainter(PainterProgressModel painter) async {
    final db = await database;
    return db!.update(PainterProgressModel.table, painter.toMap(), where: 'id = ?', whereArgs: [painter.id]);
  }

  Future<int> deletePainter(String id) async {
    final db = await database;
    return db!.delete(PainterProgressModel.table, where: 'id = ?', whereArgs: [id]);
  }

  Future<PainterProgressModel?> getPainter(String id) async {
    final db = await database;
    final res = await db!.query(PainterProgressModel.table, where: 'id = ?', whereArgs: [id]);
    return res.isNotEmpty ? PainterProgressModel.fromMap(res.first) : null;
  }


}
