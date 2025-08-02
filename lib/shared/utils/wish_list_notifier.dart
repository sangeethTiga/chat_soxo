import 'dart:async';

import 'package:injectable/injectable.dart';

class WishlistUpdateData {
  final int productId;
  final bool isWishlisted;
  final String source;

  WishlistUpdateData({
    required this.productId,
    required this.isWishlisted,
    required this.source,
  });
}

@injectable
class GlobalWishlistNotifier {
  static final GlobalWishlistNotifier _instance =
      GlobalWishlistNotifier._internal();
  factory GlobalWishlistNotifier() => _instance;
  GlobalWishlistNotifier._internal();

  final StreamController<WishlistUpdateData> _controller =
      StreamController<WishlistUpdateData>.broadcast();

  Stream<WishlistUpdateData> get updates => _controller.stream;

  void notifyWishlistUpdate({
    required int productId,
    required bool isWishlisted,
    required String source,
  }) {
    _controller.add(
      WishlistUpdateData(
        productId: productId,
        isWishlisted: isWishlisted,
        source: source,
      ),
    );
  }

  void dispose() {
    _controller.close();
  }
}
