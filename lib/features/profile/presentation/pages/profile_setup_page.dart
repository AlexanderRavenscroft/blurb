import 'package:blurb/app/session/session_cubit.dart';
import 'package:blurb/features/profile/presentation/validation/profile_validators.dart';
import 'package:blurb/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    super.dispose();
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
                  'Set Up Your Profile',
                  style: theme.typography.display.xl3.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Choose how you appear on blurb.',
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
                      crossAxisAlignment: .stretch,
                      children: [
                        FTextFormField(
                          control: .managed(controller: _usernameController),
                          label: const Text('Username'),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          hint: 'Your username',
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          enableSuggestions: false,
                          validator: ProfileValidators.username,
                          autofillHints: const [AutofillHints.newUsername],
                        ),
                        const Gap(AppSpacing.xl),
                        FTextFormField(
                          control: .managed(controller: _fullNameController),
                          label: const Text('Full name'),
                          autovalidateMode: AutovalidateMode.onUnfocus,
                          hint: 'Your full name',
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.done,
                          autocorrect: false,
                          validator: ProfileValidators.fullName,
                          autofillHints: const [AutofillHints.name],
                          onSubmit: (_) => _submit(),
                        ),
                        const Gap(AppSpacing.xxl),
                        FButton(
                          onPress: _submit,
                          size: .lg,
                          child: const Text('Next'),
                        ),
                      ],
                    ),
                  ),
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
    context.read<SessionCubit>().completeProfileSetup();
  }
}
