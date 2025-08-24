import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:soxo_chat/feature/chat/cubit/chat_cubit.dart';
import 'package:soxo_chat/shared/app/extension/helper.dart';
import 'package:soxo_chat/shared/routes/routes.dart';
import 'package:soxo_chat/shared/utils/auth/auth_utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Helper.afterInit(_initialFunction);
    super.initState();
  }

  void _initialFunction() async {
    final ctx = context;
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final bool status = await AuthUtils.instance.isSignedIn;
    if (!mounted) return;

    if (status) {
      ctx.read<ChatCubit>().getChatList();
      ctx.go(routeChat);
    } else {
      ctx.go(routeSignIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(child: SvgPicture.asset('assets/images/Group 616.svg')),
        ],
      ),
    );
  }
}
