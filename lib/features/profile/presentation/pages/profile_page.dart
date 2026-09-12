import 'package:blurb/app/app_routing.dart';
import 'package:blurb/app/session/session_cubit.dart';
import 'package:blurb/features/profile/domain/user_profile.dart';
import 'package:blurb/features/profile/presentation/components/profile_avatar.dart';
import 'package:blurb/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<SessionCubit, SessionState>(
    builder: (context, state) {
      if (state is! SessionAuthenticated) return const SizedBox.shrink();

      return _ProfileView(profile: state.profile);
    },
  );
}

class _ProfileView extends StatelessWidget {
  final UserProfile profile;

  const _ProfileView({required this.profile});

  @override
  Widget build(BuildContext context) {
    final bio = profile.bio.trim();

    return Column(
      crossAxisAlignment: .stretch,
      children: [
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
                Align(
                  alignment: Alignment.centerRight,
                  child: FButton(
                    onPress: () => context.pushNamed(AppRoute.editProfile.name),
                    variant: .secondary,
                    size: .sm,
                    mainAxisSize: MainAxisSize.min,
                    child: const Text('Edit profile'),
                  ),
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
