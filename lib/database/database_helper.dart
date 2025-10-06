import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/asset.dart';

/// DatabaseHelper - Manages SQLite database operations
/// This is a Singleton class (only one instance exists)
class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static bool _factoryInitialized = false;

  DatabaseHelper._init();

  /// Initialize database factory for desktop platforms
  /// Must be called before any database operations on desktop
  static void initializeDatabaseFactory() {
    if (!_factoryInitialized) {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      _factoryInitialized = true;
    }
  }

  /// Get database instance (creates if doesn't exist)
  Future<Database> get database async {
    // Initialize factory first (for desktop platforms)
    initializeDatabaseFactory();

    if (_database != null) return _database!;
    _database = await _initDB('assets.db');
    return _database!;
  }

  /// Initialize database
  /// Creates the database file in the app's documents directory
  Future<Database> _initDB(String filePath) async {
    // Get the correct path for the platform
    String dbPath;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // For desktop platforms, use application documents directory
      final directory = await getApplicationDocumentsDirectory();
      dbPath = directory.path;
    } else {
      // For mobile platforms (Android/iOS), use default database path
      dbPath = await getDatabasesPath();
    }

    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Create database tables
  /// This runs only once when the database is first created
  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';

    await db.execute('''
      CREATE TABLE assets (
        id $idType,
        name $textType,
        assetId $textType,
        category $textType,
        location $textType,
        status $textType,
        purchaseDate $textType,
        lastMaintenance $textTypeNullable,
        nextMaintenance $textTypeNullable,
        notes $textTypeNullable,
        createdAt $textType,
        updatedAt $textType
      )
    ''');

    // Create indexes for faster searches
    await db.execute('CREATE INDEX idx_assetId ON assets(assetId)');
    await db.execute('CREATE INDEX idx_status ON assets(status)');
    await db.execute('CREATE INDEX idx_category ON assets(category)');
  }

  /// INSERT: Add new asset to database
  Future<int> insertAsset(Asset asset) async {
    final db = await instance.database;

    final data = asset.toJson();
    data['createdAt'] = DateTime.now().toIso8601String();
    data['updatedAt'] = DateTime.now().toIso8601String();

    return await db.insert(
      'assets',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// READ: Get all assets from database
  Future<List<Asset>> getAllAssets() async {
    final db = await instance.database;

    final result = await db.query(
      'assets',
      orderBy: 'createdAt DESC', // Newest first
    );

    return result.map((json) {
      try {
        return Asset.fromJson(json);
      } catch (e) {
        print('Error parsing asset: $e');
        print('Problematic data: $json');
        rethrow;
      }
    }).toList();
  }

  /// READ: Get single asset by ID
  Future<Asset?> getAssetById(String id) async {
    final db = await instance.database;

    final maps = await db.query(
      'assets',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Asset.fromJson(maps.first);
    } else {
      return null;
    }
  }

  /// READ: Get asset by assetId (QR code)
  Future<Asset?> getAssetByAssetId(String assetId) async {
    final db = await instance.database;

    final maps = await db.query(
      'assets',
      where: 'assetId = ?',
      whereArgs: [assetId],
    );

    if (maps.isNotEmpty) {
      return Asset.fromJson(maps.first);
    } else {
      return null;
    }
  }

  /// READ: Search assets by name, assetId, or location
  Future<List<Asset>> searchAssets(String query) async {
    final db = await instance.database;

    final result = await db.query(
      'assets',
      where: 'name LIKE ? OR assetId LIKE ? OR location LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );

    return result.map((json) => Asset.fromJson(json)).toList();
  }

  /// READ: Filter assets by status
  Future<List<Asset>> getAssetsByStatus(String status) async {
    final db = await instance.database;

    final result = await db.query(
      'assets',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'createdAt DESC',
    );

    return result.map((json) => Asset.fromJson(json)).toList();
  }

  /// READ: Get assets by category
  Future<List<Asset>> getAssetsByCategory(String category) async {
    final db = await instance.database;

    final result = await db.query(
      'assets',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'createdAt DESC',
    );

    return result.map((json) => Asset.fromJson(json)).toList();
  }

  /// UPDATE: Update existing asset
  Future<int> updateAsset(Asset asset) async {
    final db = await instance.database;

    final data = asset.toJson();
    data['updatedAt'] = DateTime.now().toIso8601String();

    return await db.update(
      'assets',
      data,
      where: 'id = ?',
      whereArgs: [asset.id],
    );
  }

  /// DELETE: Remove asset from database
  Future<int> deleteAsset(String id) async {
    final db = await instance.database;

    return await db.delete(
      'assets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// DELETE: Remove all assets (for testing)
  Future<int> deleteAllAssets() async {
    final db = await instance.database;
    return await db.delete('assets');
  }

  /// UTILITY: Get total count of assets
  Future<int> getAssetCount() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM assets');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// UTILITY: Get count by status
  Future<Map<String, int>> getAssetCountByStatus() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT status, COUNT(*) as count FROM assets GROUP BY status'
    );

    final Map<String, int> statusCounts = {};
    for (var row in result) {
      statusCounts[row['status'] as String] = row['count'] as int;
    }

    return statusCounts;
  }

  /// Close database connection
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
