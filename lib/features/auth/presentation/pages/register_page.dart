import 'package:blurb/app/app_routing.dart';
import 'package:blurb/features/auth/presentation/components/auth_social_sign_in.dart';
import 'package:blurb/features/auth/presentation/components/auth_switch_prompt.dart';
import 'package:blurb/features/auth/presentation/validation/auth_validators.dart';
import 'package:blurb/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    // TODO: Connect registration when authentication is implemented.
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return FScaffold(
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
                        FTextFormField(
                          label: const Text('Username'),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          hint: 'Your username',
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          enableSuggestions: false,
                          validator: AuthValidators.username,
                          autofillHints: const [AutofillHints.newUsername],
                        ),
                        const Gap(AppSpacing.xl),
                        FTextFormField.email(
                          label: const Text('Email'),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          hint: 'you@example.com',
                          textInputAction: TextInputAction.next,
                          validator: AuthValidators.registrationEmail,
                        ),
                        const Gap(AppSpacing.xl),
                        FTextFormField.password(
                          label: const Text('Password'),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          hint:
                              'At least ${AuthValidators.minimumPasswordLength} characters',
                          validator: AuthValidators.registrationPassword,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.newPassword],
                          onSubmit: (_) => _submit(),
                        ),
                        const Gap(AppSpacing.xxl),
                        FButton(
                          onPress: _submit,
                          size: .lg,
                          child: const Text('Create account'),
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
                  onPressed: () => context.goNamed(AppRoute.login.name),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
