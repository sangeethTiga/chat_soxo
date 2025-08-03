class AuthUtils {
  AuthUtils._();
  static AuthUtils? _instance;
  static final AuthUtils instance = (_instance ??= AuthUtils._());

  // Future<void> writeUserData(VerifyResponse user) async {
  //   await _writePreference('user', jsonEncode(user.toJson()));
  // }

  // Future<void> writeStoreData(FavStoreResponse data) async {
  //   await _writePreference('store', jsonEncode(data.toJson()));
  // }

  // Future<FavStoreResponse?> readStoreData() async {
  //   final String? storeData = await _readPreference('store');
  //   if (storeData != null) {
  //     final Map<String, dynamic> storeMap = jsonDecode(storeData);
  //     return FavStoreResponse.fromJson(storeMap);
  //   }
  //   return null;
  // }

  // Future<VerifyResponse?> readUserData() async {
  //   final String? userData = await _readPreference('user');
  //   if (userData != null) {
  //     final Map<String, dynamic> userMap = jsonDecode(userData);
  //     return VerifyResponse.fromJson(userMap);
  //   }
  //   return null;
  // }

  // Future<void> clearUserData() async {
  //   await _clearPreference('user');
  // }

  // Future<void> _clearPreference(String key) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.remove(key);
  // }

  // Future<void> writeAccessTokens(String token) async {
  //   await _writePreference('token', token);
  // }

  // Future<String?> get readAccessToken async {
  //   return await _readPreference('token');
  // }

  // Future<void> writeRefreshTokens(String token) async {
  //   await _writePreference('refresh_token', token);
  // }

  // Future<String?> get readRefreshTokens async {
  //   return await _readPreference('refresh_token');
  // }

  // Future<bool> get isSignedIn async {
  //   final String? token = await _readPreference('token');
  //   return token != null;
  // }

  // Future<void> deleteAll() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.clear();

  //   // Debug: Check if anything left behind
  //   final remainingKeys = prefs.getKeys();
  //   if (remainingKeys.isNotEmpty) {
  //     log(
  //       "SharedPreferences not cleared fully. Keys still present: $remainingKeys",
  //     );
  //   } else {
  //     log("All SharedPreferences successfully cleared.");
  //   }
  // }

  // Future<void> _writePreference(String key, String value) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString(key, value);
  // }

  // Future<String?> _readPreference(String key) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString(key);
  // }

  // Future<void> writeOfferToDate(DateTime offerToDate) async {
  //   await _writePreference('offer_to_date', offerToDate.toIso8601String());
  // }

  // Future<DateTime?> readOfferToDate() async {
  //   final String? dateString = await _readPreference('offer_to_date');
  //   if (dateString != null) {
  //     return DateTime.tryParse(dateString);
  //   }
  //   return null;
  // }

  // Future<void> writeAddress(AddressListResponse address) async {
  //   await _writePreference('address', jsonEncode(address.toJson()));
  // }

  // Future<void> writeQty(ProductList product) async {
  //   await _writePreference('product', jsonEncode(product.toJson()));
  // }

  // static Future<int?> readQty() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getInt('product_qty');
  // }

  // Future<AddressListResponse?> readAddress() async {
  //   final String? addressData = await _readPreference('address');
  //   if (addressData != null) {
  //     final Map<String, dynamic> addressMap = jsonDecode(addressData);
  //     return AddressListResponse.fromJson(addressMap);
  //   }
  //   return null;
  // }

  // Future<void> deleteAddress() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final result = await prefs.remove('address');

  //   // await prefs.remove('address');

  //   log("Address deleted from SharedPreferences: $result");
  // }
}
