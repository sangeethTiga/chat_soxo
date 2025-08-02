import 'dart:async';

import 'package:injectable/injectable.dart';

class CartUpdateData {
  final int productId;
  final int quantity;
  final String action;
  final DateTime timestamp;
  final String? variantCode;
  final Map<String, dynamic>? metadata;
  final String? source;

  CartUpdateData({
    required this.productId,
    required this.quantity,
    required this.action,
    required this.timestamp,
    this.variantCode,
    this.metadata,
    this.source
  });

  @override
  String toString() {
    return 'CartUpdateData(productId: $productId, quantity: $quantity, action: $action, variantCode: $variantCode , source:$source)';
  }
}

@singleton
class GlobalCartNotifier {
  static final GlobalCartNotifier _instance = GlobalCartNotifier._internal();
  factory GlobalCartNotifier() => _instance;
  GlobalCartNotifier._internal();

  final StreamController<CartUpdateData> _controller =
      StreamController<CartUpdateData>.broadcast();

  Stream<CartUpdateData> get updates => _controller.stream;

  final Map<String, Timer> _debounceTimers = {};
  final Map<String, int> _currentQuantities = {};
  final Map<String, DateTime> _lastUpdateTime = {};
  final Duration _debounceDuration = const Duration(milliseconds: 150);

  String _getKey(int productId, {int? variantId, String? variantCode}) {
    if (variantId != null && variantId != 0) {
      return '${productId}_variant_$variantId';
    } else if (variantCode != null &&
        variantCode.isNotEmpty &&
        variantCode != '0') {
      return '${productId}_variant_code_$variantCode';
    }
    return '${productId}_product';
  }

  void notifyCartUpdated({
    required int productId,
    required int quantity,
    required String action,
    String? variantCode,
    String? source,
    Map<String, dynamic>? metadata,
  }) {
    final key = _getKey(
      productId,
      variantCode: variantCode,
    );
    final now = DateTime.now();
    final lastUpdate = _lastUpdateTime[key];
    if (lastUpdate != null && now.difference(lastUpdate).inMilliseconds < 50) {
      return;
    }
    _currentQuantities[key] = quantity;
    _lastUpdateTime[key] = now;
    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(_debounceDuration, () {
      final currentQty = _currentQuantities[key] ?? 0;
      _controller.add(
        CartUpdateData(
          productId: productId,
          quantity: currentQty,
          action: action,
          timestamp: DateTime.now(),
          variantCode: variantCode,
          metadata: metadata,
          source: source
        ),
      );

      _debounceTimers.remove(key);
    });
  }

  int getCurrentQuantity(int productId, {int? variantId, String? variantCode}) {
    final key = _getKey(
      productId,
      variantId: variantId,
      variantCode: variantCode,
    );
    return _currentQuantities[key] ?? 0;
  }

  int getTotalProductQuantity(int productId) {
    int total = 0;
    for (String key in _currentQuantities.keys) {
      if (key.startsWith('${productId}_')) {
        total += _currentQuantities[key] ?? 0;
      }
    }
    return total;
  }

  void dispose() {
    for (var timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    _currentQuantities.clear();
    _lastUpdateTime.clear();
    _controller.close();
  }
}
