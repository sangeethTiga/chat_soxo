import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:soxo_chat/feature/auth/cubit/auth_cubit.dart';
import 'package:soxo_chat/feature/chat/cubit/chat_cubit.dart';
import 'package:soxo_chat/feature/chat/domain/service/signalR_service.dart';
import 'package:soxo_chat/shared/app/enums/api_fetch_status.dart';
import 'package:soxo_chat/shared/routes/routes.dart';
import 'package:soxo_chat/shared/utils/auth/auth_utils.dart';
import 'package:soxo_chat/shared/widgets/buttons/custom_material_button.dart';
import 'package:soxo_chat/shared/widgets/padding/main_padding.dart';
import 'package:soxo_chat/shared/widgets/text_fields/text_field_widget.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with TickerProviderStateMixin {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController(
    text: '4mgXKHeAzWc648PLCCgWU61qnD3CFQP8GQOSmlk1PMk=',
  );

  // Animation Controllers
  late AnimationController _mainController;
  late AnimationController _logoController;
  late AnimationController _formController;
  late AnimationController _buttonController;

  // Animations
  late Animation<double> _logoFadeAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _logoScaleAnimation;

  late Animation<double> _usernameFadeAnimation;
  late Animation<Offset> _usernameSlideAnimation;

  late Animation<double> _passwordFadeAnimation;
  late Animation<Offset> _passwordSlideAnimation;

  late Animation<double> _buttonFadeAnimation;
  late Animation<Offset> _buttonSlideAnimation;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Main controller for overall timing
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Logo animations - smoother curves
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutQuart),
      ),
    );

    _logoSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _logoController,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
          ),
        );

    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
      ),
    );

    // Form animations - better timing
    _formController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _usernameFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _formController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _usernameSlideAnimation =
        Tween<Offset>(begin: const Offset(-0.3, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _formController,
            curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
          ),
        );

    _passwordFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _formController,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _passwordSlideAnimation =
        Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _formController,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    // Button animations - bouncy feel
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _buttonSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _buttonController,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
          ),
        );

    _buttonScaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
      ),
    );
  }

  void _startAnimations() {
    // Better staggered timing
    _logoController.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _formController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _buttonController.forward();
    });
  }

  // Smoother success animation
  void _playSuccessAnimation() {
    _buttonController.reverse().then((_) {
      _formController.reverse();
      _logoController.reverse();
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _logoController.dispose();
    _formController.dispose();
    _buttonController.dispose();
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainPadding(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state.isSignIn == ApiFetchStatus.success) {
              _playSuccessAnimation();

              AuthUtils.instance.writeAccessTokens(
                state.authResponse!.result?.jwtToken ?? '',
              );
              context.read<ChatCubit>().getChatList();

              AuthUtils.instance.readAccessToken.then((value) {
                log('token $value');
                ChatSignalRService service = ChatSignalRService();
                service.initializeConnection();

                // Delay navigation to show success animation
                Future.delayed(const Duration(milliseconds: 800), () {
                  if (mounted) context.push(routeChat);
                });
              });
              AuthUtils.instance.writeUserData(state.authResponse!);
            }
          },
          builder: (context, state) {
            return Column(
              spacing: 13.h,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Animated Logo
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _logoSlideAnimation,
                      child: FadeTransition(
                        opacity: _logoFadeAnimation,
                        child: ScaleTransition(
                          scale: _logoScaleAnimation,
                          child: SvgPicture.asset(
                            'assets/images/Group 616.svg',
                          ),
                        ),
                      ),
                    );
                  },
                ),

                35.verticalSpace,

                // Animated Username Field
                AnimatedBuilder(
                  animation: _formController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _usernameSlideAnimation,
                      child: FadeTransition(
                        opacity: _usernameFadeAnimation,
                        child: TextFeildWidget(
                          controller: userNameController,
                          labelText: 'User Name',
                          inputBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: const BorderSide(
                              color: Color(0xffCACACA),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Animated Password Field
                AnimatedBuilder(
                  animation: _formController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _passwordSlideAnimation,
                      child: FadeTransition(
                        opacity: _passwordFadeAnimation,
                        child: TextFeildWidget(
                          obscureText: true,
                          controller: passwordController,
                          labelText: 'Password',
                          inputBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: const BorderSide(
                              color: Color(0xffCACACA),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Animated Button
                AnimatedBuilder(
                  animation: _buttonController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _buttonSlideAnimation,
                      child: FadeTransition(
                        opacity: _buttonFadeAnimation,
                        child: ScaleTransition(
                          scale: _buttonScaleAnimation,
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 150),
                            tween: Tween<double>(
                              begin: 1.0,
                              end: state.isSignIn == ApiFetchStatus.loading
                                  ? 0.96
                                  : 1.0,
                            ),
                            builder: (context, scale, child) {
                              return Transform.scale(
                                scale: scale,
                                child: CustomMaterialBtton(
                                  isLoading:
                                      state.isSignIn == ApiFetchStatus.loading,
                                  onPressed: () {
                                    context.read<AuthCubit>().authSignIn(
                                      userNameController.text,
                                      passwordController.text,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
