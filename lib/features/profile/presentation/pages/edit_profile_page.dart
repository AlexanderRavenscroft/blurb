import 'package:blurb/app/session/session_cubit.dart';
import 'package:blurb/features/profile/domain/profile_exception.dart';
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
import 'package:image_picker/image_picker.dart';
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
  static const _maximumAvatarSizeInBytes = 2 * 1024 * 1024;
  static const _supportedAvatarExtensions = {'jpg', 'jpeg', 'png', 'webp'};

  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  late final TextEditingController _usernameController;
  late final TextEditingController _fullNameController;
  late final TextEditingController _bioController;
  Uint8List? _selectedAvatarBytes;
  String? _selectedAvatarExtension;

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
                      selectedAvatarBytes: _selectedAvatarBytes,
                      onPress: isSaving ? null : _onAvatarPressed,
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

  Future<void> _onAvatarPressed() async {
    final source = await showFSheet<ImageSource>(
      context: context,
      side: .btt,
      useSafeArea: true,
      builder: (_) => const _AvatarSourceSheet(),
    );

    if (source == null || !mounted) return;

    try {
      final image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
        requestFullMetadata: false,
      );

      if (image == null) return;

      final extension = _fileExtension(image.name);
      if (!_supportedAvatarExtensions.contains(extension)) {
        _showProfileFailure(ProfileExceptionCode.unsupportedImageType);
        return;
      }

      final bytes = await image.readAsBytes();
      if (bytes.lengthInBytes > _maximumAvatarSizeInBytes) {
        _showProfileFailure(ProfileExceptionCode.imageTooLarge);
        return;
      }

      if (!mounted) return;

      setState(() {
        _selectedAvatarBytes = bytes;
        _selectedAvatarExtension = extension;
      });
      log.d('Profile avatar selected (${bytes.lengthInBytes} bytes)');
    } on PlatformException catch (error, stackTrace) {
      log.e(
        'Profile avatar selection failed',
        error: error,
        stackTrace: stackTrace,
      );

      final permissionDenied =
          error.code == 'camera_access_denied' ||
          error.code == 'photo_access_denied';
      _showProfileFailure(
        permissionDenied
            ? ProfileExceptionCode.avatarPermissionDenied
            : ProfileExceptionCode.imageSelectionFailed,
      );
    } catch (error, stackTrace) {
      log.e(
        'Profile avatar selection failed',
        error: error,
        stackTrace: stackTrace,
      );
      _showProfileFailure(ProfileExceptionCode.imageSelectionFailed);
    }
  }

  String _fileExtension(String fileName) {
    final separator = fileName.lastIndexOf('.');
    if (separator == -1 || separator == fileName.length - 1) return '';

    return fileName.substring(separator + 1).toLowerCase();
  }

  void _showProfileFailure(ProfileExceptionCode code) {
    if (!mounted) return;

    showFToast(
      context: context,
      title: Text(ProfileFailureMessageMapper.forSave(code)),
      variant: FToastVariant.destructive,
      duration: const Duration(seconds: 3),
    );
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
      avatarBytes: _selectedAvatarBytes,
      avatarExtension: _selectedAvatarExtension,
    );
  }
}

class _EditableProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final Uint8List? selectedAvatarBytes;
  final VoidCallback? onPress;

  const _EditableProfileAvatar({
    required this.avatarUrl,
    required this.selectedAvatarBytes,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    final selectedBytes = selectedAvatarBytes;
    final Widget avatar;

    if (selectedBytes == null) {
      avatar = ProfileAvatar(
        avatarUrl: avatarUrl,
        size: 104,
        onPress: onPress,
        semanticsLabel: 'Change profile picture',
      );
    } else {
      final preview = FAvatar(
        image: MemoryImage(selectedBytes),
        size: 104,
        fallback: const Icon(RemixIcons.user_3_line),
      );
      final callback = onPress;

      avatar = callback == null
          ? Semantics(
              label: 'Selected profile picture',
              image: true,
              child: ExcludeSemantics(child: preview),
            )
          : FTappable(
              onPress: callback,
              semanticsLabel: 'Change profile picture',
              excludeSemantics: true,
              child: preview,
            );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
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
}

class _AvatarSourceSheet extends StatelessWidget {
  const _AvatarSourceSheet();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Change profile picture',
                style: theme.typography.display.xl.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              // const Gap(AppSpacing.sm),
              Text(
                'Choose where you want to get your photo from.',
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const Gap(AppSpacing.xl),
              FTileGroup(
                children: [
                  FTile(
                    prefix: const Icon(RemixIcons.camera_line),
                    title: const Text('Take a photo'),
                    suffix: const Icon(RemixIcons.arrow_right_s_line),
                    onPress: () =>
                        Navigator.of(context).pop(ImageSource.camera),
                  ),
                  FTile(
                    prefix: const Icon(RemixIcons.gallery_line),
                    title: const Text('Choose from gallery'),
                    suffix: const Icon(RemixIcons.arrow_right_s_line),
                    onPress: () =>
                        Navigator.of(context).pop(ImageSource.gallery),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
