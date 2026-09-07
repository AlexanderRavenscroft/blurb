import 'package:blurb/app/app_routing.dart';
import 'package:blurb/features/auth/presentation/components/auth_social_sign_in.dart';
import 'package:blurb/features/auth/presentation/components/auth_switch_prompt.dart';
import 'package:blurb/features/auth/presentation/cubits/auth/auth_cubit.dart';
import 'package:blurb/features/auth/presentation/cubits/login/login_cubit.dart';
import 'package:blurb/features/auth/presentation/validation/auth_validators.dart';
import 'package:blurb/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

//TODO: Show login errors via Snackbars
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => LoginCubit(),
    child: BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          context.read<AuthCubit>().authenticate();
        }
      },
      child: const LoginView(),
    ),
  );
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final state = context.watch<LoginCubit>().state;

    return FScaffold(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                Text(
                  'Welcome Back',
                  style: theme.typography.display.xl3.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Log in to your account to continue',
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(AppSpacing.xxl),
                AutofillGroup(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        FTextFormField.email(
                          label: const Text('Email'),
                          autovalidateMode: AutovalidateMode.onUnfocus,
                          hint: 'you@example.com',
                          validator: AuthValidators.loginEmail,
                          textInputAction: TextInputAction.next,
                        ),
                        const Gap(AppSpacing.xl),
                        FTextFormField.password(
                          label: const Text('Password'),
                          autovalidateMode: AutovalidateMode.onUnfocus,
                          hint: 'Your password',
                          validator: AuthValidators.loginPassword,
                          textInputAction: TextInputAction.done,
                          onSubmit: (_) => _submit(),
                        ),
                        const Gap(AppSpacing.xs),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FButton(
                            mainAxisSize: MainAxisSize.min,
                            variant: FButtonVariant.ghost,
                            onPress: () {},
                            child: Text(
                              'Forgot password?',
                              style: theme.typography.body.xs,
                            ),
                          ),
                        ),
                        const Gap(AppSpacing.lg),
                        FButton(
                          onPress: state is LoginSubmitting ? null : _submit,
                          size: .lg,
                          child: Text(
                            state is LoginSubmitting
                                ? 'Please wait...'
                                : 'Sign in',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(AppSpacing.xxl),
                const AuthSocialSignIn(),
                const Gap(AppSpacing.xxl),
                AuthSwitchPrompt(
                  text: "Don't have an account?",
                  buttonText: 'Sign up here',
                  onPressed: () => context.goNamed(AppRoute.register.name),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<LoginCubit>().logIn();
  }
}
