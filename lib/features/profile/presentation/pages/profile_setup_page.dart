import 'package:blurb/app/session/session_cubit.dart';
import 'package:blurb/features/profile/domain/profile_repository.dart';
import 'package:blurb/features/profile/presentation/cubits/profile/profile_cubit.dart';
import 'package:blurb/features/profile/presentation/profile_failure_message_mapper.dart';
import 'package:blurb/features/profile/presentation/profile_validators.dart';
import 'package:blurb/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

class ProfileSetupPage extends StatelessWidget {
  const ProfileSetupPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        ProfileCubit(profileRepository: context.read<ProfileRepository>()),
    child: const ProfileSetupView(),
  );
}

class ProfileSetupView extends StatefulWidget {
  const ProfileSetupView({super.key});

  @override
  State<ProfileSetupView> createState() => _ProfileSetupViewState();
}

class _ProfileSetupViewState extends State<ProfileSetupView> {
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
    final state = context.watch<ProfileCubit>().state;
    final isSaving = state is ProfileSaving;

    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileSaved) {
          context.read<SessionCubit>().profileSaved(state.profile);
        } else if (state is ProfileFailure) {
          showFToast(
            context: context,
            title: Text(ProfileFailureMessageMapper.forSave(state.code)),
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
                            enabled: !isSaving,
                            label: const Text('Username'),
                            autovalidateMode: AutovalidateMode.onUnfocus,
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
                            enabled: !isSaving,
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
                            onPress: isSaving ? null : _submit,
                            size: .lg,
                            child: Text(isSaving ? 'Saving...' : 'Next'),
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
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final session = context.read<SessionCubit>().state;
    if (session is! SessionNeedsProfile) return;

    FocusScope.of(context).unfocus();
    context.read<ProfileCubit>().save(
      userId: session.user.id,
      username: _usernameController.text,
      fullName: _fullNameController.text,
    );
  }
}
