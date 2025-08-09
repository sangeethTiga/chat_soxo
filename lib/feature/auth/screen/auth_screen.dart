import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:soxo_chat/feature/auth/cubit/auth_cubit.dart';
import 'package:soxo_chat/shared/app/enums/api_fetch_status.dart';
import 'package:soxo_chat/shared/routes/routes.dart';
import 'package:soxo_chat/shared/themes/font_palette.dart';
import 'package:soxo_chat/shared/utils/auth/auth_utils.dart';
import 'package:soxo_chat/shared/widgets/buttons/custom_material_button.dart';
import 'package:soxo_chat/shared/widgets/padding/main_padding.dart';
import 'package:soxo_chat/shared/widgets/text_fields/text_field_widget.dart';

class SignInScreen extends StatelessWidget {
  SignInScreen({super.key});
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController(
    text: '4mgXKHeAzWc648PLCCgWU61qnD3CFQP8GQOSmlk1PMk=',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainPadding(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state.isSignIn == ApiFetchStatus.success) {
              AuthUtils.instance.writeAccessTokens(
                state.authResponse!.result?.jwtToken ?? '',
              );
              AuthUtils.instance.readAccessToken.then((value) {
                print('token $value');
                context.push(routeRoot);
              });
              AuthUtils.instance.writeUserData(state.authResponse!);
            }
          },
          builder: (context, state) {
            return Column(
              spacing: 10.h,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/bird_2.jpg'),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Login', style: FontPalette.hW700S16),
                ),
                TextFeildWidget(
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
                TextFeildWidget(
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
                CustomMaterialBtton(
                  isLoading: state.isSignIn == ApiFetchStatus.loading,
                  onPressed: () {
                    context.read<AuthCubit>().authSignIn(
                      userNameController.text,
                      passwordController.text,
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
