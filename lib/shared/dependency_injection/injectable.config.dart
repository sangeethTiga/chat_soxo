// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../feature/chat/cubit/chat_cubit.dart' as _i46;
import '../utils/gloabl_cart_notifier.dart' as _i287;
import '../utils/wish_list_notifier.dart' as _i186;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.factory<_i186.GlobalWishlistNotifier>(
      () => _i186.GlobalWishlistNotifier(),
    );
    gh.factory<_i46.ChatCubit>(() => _i46.ChatCubit());
    gh.singleton<_i287.GlobalCartNotifier>(() => _i287.GlobalCartNotifier());
    return this;
  }
}
