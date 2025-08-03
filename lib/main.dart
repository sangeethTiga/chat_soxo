import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:soxo_chat/feature/chat/cubit/chat_cubit.dart';
import 'package:soxo_chat/shared/dependency_injection/injectable.dart';
import 'package:soxo_chat/shared/routes/route_generator.dart';
import 'package:soxo_chat/shared/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();

  try {
    await rootBundle.load('assets/fonts/Manrope-Regular.ttf');
    print("Font file loaded successfully!");
  } catch (e) {
    print("Font file missing or invalid path!");
  }
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
        return MultiBlocProvider(
          providers: [BlocProvider(create: (context) => getIt<ChatCubit>())],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: '',
            theme: AppTheme.lightTheme,
            themeMode: ThemeMode.light,
            onGenerateRoute: (settings) =>
                RouteGenerator.generateRoute(settings),
          ),
        );
      },
    );
  }
}
