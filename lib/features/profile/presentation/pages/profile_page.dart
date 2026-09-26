import 'package:blurb/app/app_routing.dart';
import 'package:blurb/app/session/session_cubit.dart';
import 'package:blurb/features/profile/domain/profile_repository.dart';
import 'package:blurb/features/profile/domain/user_profile.dart';
import 'package:blurb/features/profile/presentation/components/profile_avatar.dart';
import 'package:blurb/features/profile/presentation/cubits/profile_page/profile_page_cubit.dart';
import 'package:blurb/features/profile/presentation/profile_failure_message_mapper.dart';
import 'package:blurb/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';

class ProfilePage extends StatelessWidget {
  final UserProfile? profile;

  const ProfilePage({super.key, this.profile});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) {
        if (state is! SessionAuthenticated) {
          return const SizedBox.shrink();
        }

        final displayedProfile = profile ?? state.profile;
        final isOwnProfile = displayedProfile.id == state.user.id;

        return BlocProvider(
          create: (context) => ProfilePageCubit(
            profileRepository: context.read<ProfileRepository>(),
          )..load(profileId: displayedProfile.id, isOwnProfile: isOwnProfile),
          child: BlocConsumer<ProfilePageCubit, ProfilePageState>(
            listenWhen: (previous, current) =>
                current is ProfilePageLoaded && current.followErrorCode != null,
            listener: (context, state) {
              if (state is! ProfilePageLoaded) return;
              showFToast(
                context: context,
                title: Text(
                  ProfileFailureMessageMapper.forFollow(state.followErrorCode!),
                ),
                variant: FToastVariant.destructive,
                duration: const Duration(seconds: 3),
              );
            },
            builder: (context, state) => switch (state) {
              ProfilePageLoading() => const Center(child: FCircularProgress()),
              ProfilePageFailure() => _ProfileLoadFailure(
                message: ProfileFailureMessageMapper.forLoad(state.code),
                onRetry: () => context.read<ProfilePageCubit>().load(
                  profileId: displayedProfile.id,
                  isOwnProfile: isOwnProfile,
                ),
              ),
              ProfilePageLoaded() => ProfileView(
                profile: state.profile,
                isOwnProfile: isOwnProfile,
                isFollowing: state.isFollowing,
                isUpdatingFollow: state.isUpdatingFollow,
              ),
            },
          ),
        );
      },
    );
  }
}

class ProfileView extends StatelessWidget {
  final UserProfile profile;
  final bool isOwnProfile;
  final bool isFollowing;
  final bool isUpdatingFollow;

  const ProfileView({
    super.key,
    required this.profile,
    required this.isOwnProfile,
    required this.isFollowing,
    required this.isUpdatingFollow,
  });

  @override
  Widget build(BuildContext context) {
    final bio = profile.bio.trim();

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        if (isOwnProfile)
          FHeader(
            style: const .delta(padding: .value(EdgeInsets.only(bottom: 0))),
            title: Text(
              profile.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.theme.typography.display.xl,
            ),
            suffixes: [
              FHeaderAction(
                onPress: () => context.pushNamed(AppRoute.profileSettings.name),
                semanticsLabel: 'Profile settings',
                icon: const Icon(RemixIcons.settings_3_line),
              ),
            ],
          ),
        if (!isOwnProfile)
          FHeader.nested(
            style: const .delta(padding: .value(EdgeInsets.only(bottom: 0))),
            title: Text(
              profile.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.theme.typography.display.xl,
            ),
            prefixes: [FHeaderAction.back(onPress: () => context.pop())],
          ),

        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(top: AppSpacing.md),
            child: Column(
              crossAxisAlignment: .stretch,
              children: [
                _ProfileSummary(profile: profile),
                if (bio.isNotEmpty) ...[
                  const Gap(AppSpacing.lg),
                  Text(
                    bio,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: context.theme.typography.body.sm,
                  ),
                ],
                Gap(bio.isNotEmpty ? AppSpacing.sm : AppSpacing.xl),
                Row(
                  mainAxisAlignment: isOwnProfile
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end,
                  children: [
                    if (!isOwnProfile)
                      FButton(
                        onPress: isUpdatingFollow
                            ? null
                            : context.read<ProfilePageCubit>().toggleFollow,
                        variant: isFollowing
                            ? FButtonVariant.secondary
                            : FButtonVariant.primary,
                        size: .sm,
                        mainAxisSize: MainAxisSize.min,
                        child: Text(isFollowing ? 'Following' : 'Follow'),
                      ),
                    if (isOwnProfile)
                      FButton(
                        onPress: () async {
                          await context.pushNamed(AppRoute.editProfile.name);
                          if (!context.mounted) return;
                          await context.read<ProfilePageCubit>().load(
                            profileId: profile.id,
                            isOwnProfile: isOwnProfile,
                          );
                        },
                        variant: .secondary,
                        size: .sm,
                        mainAxisSize: MainAxisSize.min,
                        child: const Text('Edit profile'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileSummary extends StatelessWidget {
  final UserProfile profile;

  const _ProfileSummary({required this.profile});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      ProfileAvatar(avatarUrl: profile.avatarUrl),
      const Gap(AppSpacing.xl),
      Expanded(
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  profile.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: context.theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Gap(AppSpacing.xs),
            Row(
              children: [
                _ProfileStat(value: profile.postsCount, label: 'posts'),
                _ProfileStat(value: profile.followersCount, label: 'followers'),
                _ProfileStat(value: profile.followingCount, label: 'following'),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

class _ProfileLoadFailure extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ProfileLoadFailure({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          style: context.theme.typography.body.sm.copyWith(
            color: context.theme.colors.mutedForeground,
          ),
        ),
        const Gap(AppSpacing.md),
        FButton(
          onPress: onRetry,
          variant: .secondary,
          size: .sm,
          mainAxisSize: MainAxisSize.min,
          child: const Text('Try again'),
        ),
      ],
    ),
  );
}

class _ProfileStat extends StatelessWidget {
  final int value;
  final String label;

  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$value',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.theme.typography.body.md.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.theme.typography.body.xs.copyWith(
            color: context.theme.colors.mutedForeground,
            height: 0.6,
          ),
        ),
      ],
    ),
  );
}
