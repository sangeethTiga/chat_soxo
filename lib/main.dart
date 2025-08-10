import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:soxo_chat/feature/auth/cubit/auth_cubit.dart';
import 'package:soxo_chat/feature/chat/cubit/chat_cubit.dart';
import 'package:soxo_chat/feature/chat/screen/widgets/chat_card.dart';
import 'package:soxo_chat/feature/person_lists/cubit/person_lists_cubit.dart';
import 'package:soxo_chat/shared/dependency_injection/injectable.dart';
import 'package:soxo_chat/shared/routes/route_generator.dart';
import 'package:soxo_chat/shared/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  // MediaCacheManager.initialize();
  // if (Platform.isAndroid) {
  //   WebView.platform = SurfaceAndroidWebView(); // or AndroidWebView()
  // }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final GoRouter router = RouteGenerator.generateRoute();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => getIt<ChatCubit>(), lazy: false),
            BlocProvider(create: (context) => getIt<PersonListsCubit>()),
            BlocProvider(create: (context) => getIt<AuthCubit>()),
          ],
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: '',
            theme: AppTheme.lightTheme,
            themeMode: ThemeMode.light,
            routerConfig: router,
          ),
        );
      },
    );
  }
}
