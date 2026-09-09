import 'package:blurb/app/app_routing.dart';
import 'package:blurb/features/auth/domain/repositories/auth_repository.dart';
import 'package:blurb/features/auth/presentation/components/auth_social_sign_in.dart';
import 'package:blurb/features/auth/presentation/components/auth_switch_prompt.dart';
import 'package:blurb/features/auth/presentation/cubits/register/register_cubit.dart';
import 'package:blurb/features/auth/presentation/cubits/social_auth/social_auth_cubit.dart';
import 'package:blurb/features/auth/presentation/mappers/auth_failure_message_mapper.dart';
import 'package:blurb/features/auth/presentation/validation/auth_validators.dart';
import 'package:blurb/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) =>
            RegisterCubit(authRepository: context.read<AuthRepository>()),
      ),
      BlocProvider(
        create: (_) =>
            SocialAuthCubit(authRepository: context.read<AuthRepository>()),
      ),
    ],
    child: const RegisterView(),
  );
}

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final state = context.watch<RegisterCubit>().state;

    return BlocListener<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state is RegisterFailure) {
          showFToast(
            context: context,
            title: Text(AuthFailureMessageMapper.forRegister(state.code)),
            variant: FToastVariant.destructive,
            duration: const Duration(seconds: 3),
          );
        }
      },
      child: FScaffold(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  Text(
                    'Create Account',
                    style: theme.typography.display.xl3.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Join the conversation on blurb.',
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FTextFormField.email(
                            control: .managed(controller: _emailController),
                            label: const Text('Email'),
                            autovalidateMode: AutovalidateMode.onUnfocus,
                            hint: 'you@example.com',
                            textInputAction: TextInputAction.next,
                            validator: AuthValidators.registrationEmail,
                          ),
                          const Gap(AppSpacing.xl),
                          FTextFormField.password(
                            control: .managed(controller: _passwordController),
                            label: const Text('Password'),
                            autovalidateMode: AutovalidateMode.onUnfocus,
                            hint:
                                'At least ${AuthValidators.minimumPasswordLength} characters',
                            validator: AuthValidators.registrationPassword,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.newPassword],
                            onSubmit: (_) => _submit(),
                          ),
                          const Gap(AppSpacing.xxl),
                          FButton(
                            onPress: state is RegisterSubmitting
                                ? null
                                : _submit,
                            size: .lg,
                            child: Text(
                              state is RegisterSubmitting
                                  ? 'Please wait...'
                                  : 'Create account',
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
                    text: 'Already have an account?',
                    buttonText: 'Sign in here',
                    onPressed: state is RegisterSubmitting
                        ? null
                        : () => context.goNamed(AppRoute.login.name),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<RegisterCubit>().register(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }
}
