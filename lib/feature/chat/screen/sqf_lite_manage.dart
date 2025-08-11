import 'dart:typed_data';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class EnhancedMediaCache {
  static final EnhancedMediaCache _instance = EnhancedMediaCache._internal();
  factory EnhancedMediaCache() => _instance;
  EnhancedMediaCache._internal();

  Database? _database;
  final Map<String, Uint8List> _memoryCache = {};
  final Map<String, String> _filePathCache = {};
  final Set<String> _loadingFiles = {};

  static const int maxMemoryCacheSize = 50;
  static const Duration defaultCacheExpiry = Duration(days: 7);

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'enhanced_media_cache.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE media_cache (
        media_id TEXT PRIMARY KEY,
        media_url TEXT NOT NULL,
        file_type TEXT NOT NULL,
        file_data BLOB NOT NULL,
        file_path TEXT,
        cached_at INTEGER NOT NULL,
        file_size INTEGER NOT NULL,
        expires_at INTEGER
      )
    ''');

    await db.execute('CREATE INDEX idx_media_url ON media_cache(media_url)');
    await db.execute('CREATE INDEX idx_cached_at ON media_cache(cached_at)');
  }

  // Get media file with multi-level caching
  Future<CachedMediaFile?> getMediaFile(String mediaId) async {
    // 1. Check memory cache first
    if (_memoryCache.containsKey(mediaId)) {
      final cachedFile = await _getCachedMediaFile(mediaId);
      if (cachedFile != null) {
        return cachedFile.copyWith(fileData: _memoryCache[mediaId]!);
      }
    }

    // 2. Check SQLite cache
    final cachedFile = await _getCachedMediaFile(mediaId);
    if (cachedFile != null) {
      _addToMemoryCache(mediaId, cachedFile.fileData);
      return cachedFile;
    }

    return null;
  }

  Future<CachedMediaFile?> _getCachedMediaFile(String mediaId) async {
    final db = await database;
    final results = await db.query(
      'media_cache',
      where: 'media_id = ?',
      whereArgs: [mediaId],
      limit: 1,
    );

    if (results.isEmpty) return null;

    final data = results.first;

    // Check if expired
    final expiresAt = data['expires_at'] as int?;
    if (expiresAt != null &&
        DateTime.now().millisecondsSinceEpoch > expiresAt) {
      await _deleteCachedFile(mediaId);
      return null;
    }

    return CachedMediaFile.fromMap(data);
  }

  // Cache media file
  Future<void> cacheMediaFile({
    required String mediaId,
    required String mediaUrl,
    required String fileType,
    required Uint8List fileData,
    String? filePath,
    Duration? expiryDuration,
  }) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiresAt = expiryDuration != null
        ? now + expiryDuration.inMilliseconds
        : null;

    await db.insert('media_cache', {
      'media_id': mediaId,
      'media_url': mediaUrl,
      'file_type': fileType,
      'file_data': fileData,
      'file_path': filePath,
      'cached_at': now,
      'file_size': fileData.length,
      'expires_at': expiresAt,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    // Add to memory cache
    _addToMemoryCache(mediaId, fileData);

    // Store file path if provided
    if (filePath != null) {
      _filePathCache[mediaId] = filePath;
    }
  }

  void _addToMemoryCache(String mediaId, Uint8List data) {
    if (_memoryCache.length >= maxMemoryCacheSize) {
      final firstKey = _memoryCache.keys.first;
      _memoryCache.remove(firstKey);
    }
    _memoryCache[mediaId] = data;
  }

  Future<void> _deleteCachedFile(String mediaId) async {
    final db = await database;
    await db.delete('media_cache', where: 'media_id = ?', whereArgs: [mediaId]);
  }

  // Loading state management
  bool isLoading(String mediaId) => _loadingFiles.contains(mediaId);

  void setLoading(String mediaId) => _loadingFiles.add(mediaId);

  void clearLoading(String mediaId) => _loadingFiles.remove(mediaId);

  // File path management
  String? getFilePath(String mediaId) => _filePathCache[mediaId];

  void setFilePath(String mediaId, String path) {
    _filePathCache[mediaId] = path;
  }

  // Clean up expired and old files
  Future<void> cleanupCache() async {
    final db = await database;

    // Clean expired files
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.delete(
      'media_cache',
      where: 'expires_at IS NOT NULL AND expires_at < ?',
      whereArgs: [now],
    );

    // Clean old files (keep only recent 200 files)
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM media_cache',
    );
    final totalCount = countResult.first['count'] as int;

    if (totalCount > 200) {
      final toDelete = totalCount - 200;
      await db.rawDelete(
        '''
        DELETE FROM media_cache 
        WHERE media_id IN (
          SELECT media_id FROM media_cache 
          ORDER BY cached_at ASC 
          LIMIT ?
        )
      ''',
        [toDelete],
      );
    }
  }

  // Get cache statistics
  Future<CacheStats> getStats() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_files,
        SUM(file_size) as total_size,
        AVG(file_size) as avg_size
      FROM media_cache
    ''');

    final data = result.first;
    return CacheStats(
      totalFiles: data['total_files'] as int,
      totalSize: data['total_size'] as int? ?? 0,
      averageSize: (data['avg_size'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Clear all caches
  Future<void> clearAllCaches() async {
    _memoryCache.clear();
    _filePathCache.clear();
    _loadingFiles.clear();

    final db = await database;
    await db.delete('media_cache');
  }
}

// Data Models
class CachedMediaFile {
  final String mediaId;
  final String mediaUrl;
  final String fileType;
  final Uint8List fileData;
  final String? filePath;
  final DateTime cachedAt;
  final int fileSize;
  final DateTime? expiresAt;

  CachedMediaFile({
    required this.mediaId,
    required this.mediaUrl,
    required this.fileType,
    required this.fileData,
    this.filePath,
    required this.cachedAt,
    required this.fileSize,
    this.expiresAt,
  });

  factory CachedMediaFile.fromMap(Map<String, dynamic> map) {
    return CachedMediaFile(
      mediaId: map['media_id'],
      mediaUrl: map['media_url'],
      fileType: map['file_type'],
      fileData: map['file_data'] as Uint8List,
      filePath: map['file_path'],
      cachedAt: DateTime.fromMillisecondsSinceEpoch(map['cached_at']),
      fileSize: map['file_size'],
      expiresAt: map['expires_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['expires_at'])
          : null,
    );
  }

  CachedMediaFile copyWith({
    String? mediaId,
    String? mediaUrl,
    String? fileType,
    Uint8List? fileData,
    String? filePath,
    DateTime? cachedAt,
    int? fileSize,
    DateTime? expiresAt,
  }) {
    return CachedMediaFile(
      mediaId: mediaId ?? this.mediaId,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      fileType: fileType ?? this.fileType,
      fileData: fileData ?? this.fileData,
      filePath: filePath ?? this.filePath,
      cachedAt: cachedAt ?? this.cachedAt,
      fileSize: fileSize ?? this.fileSize,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

class CacheStats {
  final int totalFiles;
  final int totalSize;
  final double averageSize;

  CacheStats({
    required this.totalFiles,
    required this.totalSize,
    required this.averageSize,
  });

  String get totalSizeFormatted {
    if (totalSize < 1024) return '${totalSize}B';
    if (totalSize < 1024 * 1024)
      return '${(totalSize / 1024).toStringAsFixed(1)}KB';
    return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
