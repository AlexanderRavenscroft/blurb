import 'package:blurb/app/session/session_cubit.dart';
import 'package:blurb/features/profile/domain/profile_repository.dart';
import 'package:blurb/features/profile/domain/user_profile.dart';
import 'package:blurb/features/profile/presentation/components/profile_avatar.dart';
import 'package:blurb/features/profile/presentation/cubits/profile/profile_cubit.dart';
import 'package:blurb/features/profile/presentation/profile_failure_message_mapper.dart';
import 'package:blurb/features/profile/presentation/profile_validators.dart';
import 'package:blurb/theme/app_spacing.dart';
import 'package:blurb/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionState = context.watch<SessionCubit>().state;
    if (sessionState is! SessionAuthenticated) {
      return const SizedBox.shrink();
    }

    return BlocProvider(
      create: (_) =>
          ProfileCubit(profileRepository: context.read<ProfileRepository>()),
      child: EditProfileView(profile: sessionState.profile),
    );
  }
}

class EditProfileView extends StatefulWidget {
  final UserProfile profile;

  const EditProfileView({super.key, required this.profile});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _fullNameController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.profile.username);
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProfileCubit>().state;
    final isSaving = state is ProfileSaving;

    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileSaved) {
          context.read<SessionCubit>().profileSaved(state.profile);
          context.pop();
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
        header: FHeader.nested(
          title: const Text('Edit profile'),
          prefixes: [
            FHeaderAction.back(onPress: () => isSaving ? null : context.pop()),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.only(
              top: AppSpacing.xl,
              bottom: AppSpacing.xxl,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: _EditableProfileAvatar(
                      avatarUrl: widget.profile.avatarUrl,
                      onPress: _onAvatarPressed,
                    ),
                  ),
                  const Gap(AppSpacing.xxl),
                  FTextFormField(
                    control: .managed(controller: _usernameController),
                    label: const Text('Username'),
                    hint: 'Your username',
                    autovalidateMode: AutovalidateMode.onUnfocus,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    enableSuggestions: false,
                    autofillHints: const [AutofillHints.username],
                    validator: ProfileValidators.username,
                  ),
                  const Gap(AppSpacing.xl),
                  FTextFormField(
                    control: .managed(controller: _fullNameController),
                    label: const Text('Full name'),
                    hint: 'Your full name',
                    autovalidateMode: AutovalidateMode.onUnfocus,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    validator: ProfileValidators.fullName,
                  ),
                  const Gap(AppSpacing.xl),
                  FTextFormField.multiline(
                    control: .managed(controller: _bioController),
                    label: const Text('Bio'),
                    hint: 'Tell people a little about yourself',
                    description: const Text('Shown on your public profile.'),
                    autovalidateMode: AutovalidateMode.onUnfocus,
                    minLines: 4,
                    maxLines: 4,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    maxLength: ProfileValidators.maximumBioLength,
                    validator: ProfileValidators.bio,
                  ),
                  const Gap(AppSpacing.xxl),
                  FButton(
                    onPress: isSaving ? null : _submit,
                    size: .lg,
                    child: Text(isSaving ? 'Saving...' : 'Save changes'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onAvatarPressed() {
    log.d('Edit profile avatar pressed');
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final session = context.read<SessionCubit>().state;
    if (session is! SessionAuthenticated) return;

    FocusScope.of(context).unfocus();
    context.read<ProfileCubit>().save(
      userId: session.user.id,
      username: _usernameController.text,
      fullName: _fullNameController.text,
      bio: _bioController.text,
    );
  }
}

class _EditableProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final VoidCallback onPress;

  const _EditableProfileAvatar({
    required this.avatarUrl,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      ProfileAvatar(
        avatarUrl: avatarUrl,
        size: 104,
        onPress: onPress,
        semanticsLabel: 'Change profile picture',
      ),
      Positioned(
        right: 2,
        bottom: 2,
        child: IgnorePointer(
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.theme.colors.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: context.theme.colors.background,
                width: 2,
              ),
            ),
            child: Icon(
              RemixIcons.camera_line,
              color: context.theme.colors.primaryForeground,
              size: 16,
            ),
          ),
        ),
      ),
    ],
  );
}
