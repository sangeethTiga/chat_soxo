import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soxo_chat/shared/routes/route_generator.dart';
import 'package:soxo_chat/shared/themes/app_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: '',
          theme: AppTheme.lightTheme,
          themeMode: ThemeMode.light,
          onGenerateRoute: (settings) => RouteGenerator.generateRoute(settings),
        );
      },
    );
  }
}
