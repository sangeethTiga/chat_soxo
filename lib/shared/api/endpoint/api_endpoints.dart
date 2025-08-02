import 'dart:developer';

class ApiEndpoints {
  ApiEndpoints._();
  static String signIn = 'get-signin-otp';
  static String verifyOtp = 'verify-customer-signin';

  static String storeList(String query) =>
      'get_store_fields-v2?query=$query&images=1&business_types=1';

  static String homeProducts(int storeId, int? custId) =>
      'home-page?store_id=$storeId&cust_id=$custId';
  static String cart = 'cart';

  static String catProduct({
    int? storeId,
    int? catId,
    int? custId,
    int? priceTo,
    int? priceFrom,
    bool? newStore,
  }) {
    log("What is here ${newStore}");
    return 'product?store_id=${storeId ?? 0}&cust_id=$custId&category_id=${newStore == true ? '' : catId}&sort=1&brands=0&rating=0&price_from=$priceFrom&price_to=$priceTo${newStore == false ? '' : "&is_new=1"}&page_first_result=0&result_per_page=30';
  }

  static String productsLists({
    int? storeId,
    int? catId,
    int? custId,
    int? priceTo,
    int? priceFrom,
    bool? newStore,
  }) {
    log("What is here ${newStore}");
    return 'product?store_id=${storeId ?? 0}&cust_id=$custId&category_id=$catId&sort=1&brands=0&rating=0&price_from=$priceFrom&price_to=$priceTo${newStore == false ? '' : "&is_new=1"}&page_first_result=0&result_per_page=30';
  }

  static String cartList({int? custId, int? storeId}) =>
      'cart?store_id=$storeId&cust_id=$custId';

  static String categoryLists(int storeId) => "category?store_id=$storeId";
  static String deleteCart = 'delete-cart';
  static String address(int custId) =>
      'customershippingaddress?cust_id=$custId';
  static String newAddress = 'customershippingaddress';
  static String editAddress(int custShippId) =>
      'customershippingaddress/$custShippId';
  static String preOrderCategory(int storeId) =>
      "category?store_id=$storeId&is_pre_order=1";
  static String popularThisWeek(int storeId, int custId) =>
      "popular-this-week?store_id=$storeId&cust_id=$custId&page_first_result=0&result_per_page=10";

  static String subCategory(int storeId, int catId, bool isNew) =>
      "sub-categories?category_id=${isNew == true ? '0' : catId}&store_id=$storeId${isNew == true ? "&is_new=1" : ''}";

  static String searchProucts({int? storeId}) =>
      'product-search?store_id=$storeId&page_first_result=0&results_per_page=10&details=1';

  static String dealOfTheDay(int storeId, int custId) =>
      'product?store_id=$storeId&cust_id=$custId&offerdate=0&result_per_page=20&page_first_result=0';
  static String featureProduct(int storeId) =>
      "deal-product-categories-brands?store_id=$storeId";

  static String relatedProducts(int storeId, int? custId) =>
      'related-product-cart?store_id=$storeId&cust_id=$custId';

  static String clearAll = 'clear-cart';
  static String checkout = 'productorder';
  static String searchProducts(int storeId, int custId) =>
      'product-search?store_id=$storeId&cust_id=$custId&details=1&page_first_result=0&results_per_page=10';

  static String productDetail(int storeId, int? productId, int? custId) =>
      "product?product_id=$productId&store_id=$storeId&cust_id=$custId";

  static String categoryTop(int storeId) => 'main-categories?store_id=$storeId';

  static String order(int storeId, int custId) =>
      "productorder?store_id=$storeId&cust_id=$custId";

  static String orderDetail(int? orderId) => 'productorderitem/$orderId';
  static String wishList(int storeId, int? custId) =>
      'wishlist?cust_id=$custId&store_id=$storeId';

  static String addWish = 'wishlist';
  static String time(String day, int storeId) =>
      'delivery-slots?store_id=$storeId&date=$day';

  static String termsAndCondtion = 'terms-and-conditions';
  static String privacyPolicy = 'privacy-policy';
  static String aboutUs(int storeId) => 'about-us/store_id=$storeId';
  static String returnPolicy = 'return-policy';
  static String bestSeller(int storeId) =>
      'products-grid?store_id=$storeId&page_first_result=0&results_per_page=15&is_best_seller=1';

  static String orderCancel = 'deleteorder';

  static String reorder(int prodId, int storeId, int custId, int status) =>
      're-order?store_id=$storeId&prod_order_id=$prodId&cust_id=$custId&merge_cart=$status';

  static String priceList(int storeId, int catId) =>
      'product-filters?store_id=$storeId&category_id=$catId';

  static String recentTransaction({int? storeId, int? custId}) =>
      'customer-orders?cust_id=$custId&store_id=$storeId&payment_method_id=10&items=0&results_per_page=10&page_offset=0&delivery-date=1&order_status=4';

  static String lastPayment(int storeId) => 'last-payment?store_id=$storeId';
  static String paymentHistory(int storeId) =>
      'credit-payment-history?store_id=$storeId';

  static String faq = 'faq';
  static String storeAdd = 'favorite-stores';
  static String favStore(int custId) => 'favorite-stores?cust_id=$custId';
  static String notificationReg = 'register_notification_device';
  static String profile(int custId) => 'customers?cust_id=$custId';
  static String updateProfile = 'update-profile';
  static String getOtpMobile = 'get-otp';
  static String updateMobile = 'update-mobile';
  static String shippingCharge({
    int? custShipAddressId,
    int? storeId,
    double? grandTotal,
  }) =>
      'calculate-shipping-charge?cust_ship_address_id=$custShipAddressId&store_id=$storeId&grandTotal=$grandTotal';

  static String paymentList(int storeId) =>
      'payment_method?store_id=$storeId&app_type_id=1';

  static String buyAgain(int storeId, int custId) =>
      'previously-ordered-products?store_id=$storeId&cust_id=$custId&result_per_page=15';
}
