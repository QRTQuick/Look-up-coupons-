import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'package:look_up_coupons/models/deal.dart';
import 'package:look_up_coupons/services/seed_data.dart';

class DatabaseService {
  Database? _db;

  Future<void> init() async {
    final path = p.join(await getDatabasesPath(), 'look_up_coupons.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
    await _seedIfNeeded();
  }

  Database get _database {
    final db = _db;
    if (db == null) {
      throw StateError('Database not initialized. Call init() first.');
    }
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE deals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        shopName TEXT NOT NULL,
        imageUrl TEXT,
        expiresAt INTEGER NOT NULL,
        category TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        isUserAdded INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dealId INTEGER,
        shopName TEXT,
        createdAt INTEGER NOT NULL
      )
    ''');
  }

  // Seed a few sample deals on first launch so the app works offline immediately.
  Future<void> _seedIfNeeded() async {
    final count = Sqflite.firstIntValue(
          await _database.rawQuery('SELECT COUNT(*) FROM deals'),
        ) ??
        0;
    if (count > 0) return;

    final batch = _database.batch();
    for (final deal in seedDeals()) {
      batch.insert('deals', deal.toMap()..remove('id'));
    }
    await batch.commit(noResult: true);
  }

  Future<List<Deal>> getDeals() async {
    final maps = await _database.query('deals');
    return maps.map(Deal.fromMap).toList();
  }

  Future<int> insertDeal(Deal deal) async {
    return _database.insert('deals', deal.toMap()..remove('id'));
  }

  Future<void> updateDeal(Deal deal) async {
    if (deal.id == null) return;
    await _database.update(
      'deals',
      deal.toMap(),
      where: 'id = ?',
      whereArgs: [deal.id],
    );
  }

  Future<void> deleteDeal(int id) async {
    await _database.delete('deals', where: 'id = ?', whereArgs: [id]);
    await _database.delete('favorites', where: 'dealId = ?', whereArgs: [id]);
  }

  Future<List<int>> getFavoriteDealIds() async {
    final maps = await _database.query(
      'favorites',
      columns: ['dealId'],
      where: 'dealId IS NOT NULL',
    );
    return maps
        .map((row) => row['dealId'])
        .whereType<int>()
        .toList();
  }

  Future<List<String>> getFavoriteShops() async {
    final maps = await _database.query(
      'favorites',
      columns: ['shopName'],
      where: 'shopName IS NOT NULL',
    );
    return maps
        .map((row) => row['shopName'])
        .whereType<String>()
        .toList();
  }

  Future<void> addFavoriteDeal(int dealId) async {
    await _database.insert('favorites', {
      'dealId': dealId,
      'shopName': null,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> removeFavoriteDeal(int dealId) async {
    await _database.delete(
      'favorites',
      where: 'dealId = ?',
      whereArgs: [dealId],
    );
  }

  Future<void> addFavoriteShop(String shopName) async {
    await _database.insert('favorites', {
      'dealId': null,
      'shopName': shopName,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> removeFavoriteShop(String shopName) async {
    await _database.delete(
      'favorites',
      where: 'shopName = ?',
      whereArgs: [shopName],
    );
  }
}
