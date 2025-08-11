import 'dart:typed_data';

class MediaCache {
  static final Map<String, Uint8List> _imageCache = {};
  static final Map<String, String> _filePathCache = {};
  static final Set<String> _loadingItems = {};
  static final Set<String> _failedItems = {};

  static Uint8List? getImage(String key) => _imageCache[key];
  static void setImage(String key, Uint8List data) {
    _imageCache[key] = data;
    _failedItems.remove(key);
  }

  static void clearFilePath(String mediaId) {
    _failedItems.remove(mediaId);
  }

  static void clearAll() {
    _failedItems.clear();
    _imageCache.clear();
    _filePathCache.clear();
    _loadingItems.clear();
  }

  static String? getFilePath(String key) => _filePathCache[key];
  static void setFilePath(String key, String path) {
    _filePathCache[key] = path;
    _failedItems.remove(key);
  }

  static bool isLoading(String key) => _loadingItems.contains(key);
  static void setLoading(String key) {
    _loadingItems.add(key);
    _failedItems.remove(key);
  }

  static void clearLoading(String key) => _loadingItems.remove(key);

  static bool hasFailed(String key) => _failedItems.contains(key);
  static void setFailed(String key) {
    _failedItems.add(key);
    _loadingItems.remove(key);
  }

  static void clearFailed(String key) => _failedItems.remove(key);

  static void clear() {
    _imageCache.clear();
    _filePathCache.clear();
    _loadingItems.clear();
    _failedItems.clear();
  }

  static void clearForMedia(String key) {
    _imageCache.remove(key);
    _filePathCache.remove(key);
    _loadingItems.remove(key);
    _failedItems.remove(key);
  }
}
