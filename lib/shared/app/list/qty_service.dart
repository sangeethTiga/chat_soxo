class QuantityStorage {
  static const _key = 'product_quantities';

  // static Future<void> saveQty({
  //   required int productId,
  //   int? variantId,
  //   required int qty,
  // }) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final raw = prefs.getString(_key);
  //   final Map<String, dynamic> map = raw != null ? jsonDecode(raw) : {};

  //   final key = variantId != null ? 'variant_$variantId' : 'product_$productId';
  //   map[key] = qty;

  //   await prefs.setString(_key, jsonEncode(map));
  // }

  // static Future<int?> getQty({required int productId, int? variantId}) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final raw = prefs.getString(_key);
  //   if (raw == null) return null;

  //   final Map<String, dynamic> map = jsonDecode(raw);
  //   final key = variantId != null ? 'variant_$variantId' : 'product_$productId';
  //   return map[key];
  // }

  // static Future<void> removeQty({required int productId}) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final raw = prefs.getString(_key);
  //   if (raw == null) {
  //     return;
  //   }

  //   final Map<String, dynamic> map = jsonDecode(raw);

  //   final key = 'product_$productId';

  //   if (map.containsKey(key)) {
  //     map.remove(key);
  //   } else {}

  //   await prefs.setString(_key, jsonEncode(map));
  // }

  // static Future<void> clearAllQty() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove(_key);
  // }
}
