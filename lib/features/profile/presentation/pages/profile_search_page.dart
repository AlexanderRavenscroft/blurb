import 'package:blurb/app/session/session_cubit.dart';
import 'package:blurb/features/profile/domain/profile_repository.dart';
import 'package:blurb/features/profile/domain/user_profile.dart';
import 'package:blurb/features/profile/presentation/components/profile_avatar.dart';
import 'package:blurb/features/profile/presentation/cubits/profile_list/profile_list_cubit.dart';
import 'package:blurb/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

class ProfileSearchPage extends StatelessWidget {
  const ProfileSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionState = context.watch<SessionCubit>().state;
    if (sessionState is! SessionAuthenticated) {
      return const SizedBox.shrink();
    }

    return BlocProvider(
      create: (_) =>
          ProfileListCubit(profileRepository: context.read<ProfileRepository>())
            ..loadProfiles(userId: sessionState.user.id),
      child: ProfileSearchView(currentUserId: sessionState.user.id),
    );
  }
}

class ProfileSearchView extends StatelessWidget {
  final String currentUserId;

  const ProfileSearchView({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      childPad: false,
      header: FHeader(
        style: const .delta(padding: .value(EdgeInsets.only(bottom: 0))),
        title: Text(
          'Profiles',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.theme.typography.display.xl,
        ),
      ),

      child: BlocBuilder<ProfileListCubit, ProfileListState>(
        builder: (context, state) => switch (state) {
          ProfileListLoading() => const Center(child: FCircularProgress()),
          ProfileListLoaded(:final profiles) => _ProfileList(
            profiles: profiles,
          ),
          ProfileListFailure() => _ProfileListFailure(
            onRetry: () => context.read<ProfileListCubit>().loadProfiles(
              userId: currentUserId,
            ),
          ),
        },
      ),
    );
  }
}

class _ProfileList extends StatelessWidget {
  final List<UserProfile> profiles;

  const _ProfileList({required this.profiles});

  @override
  Widget build(BuildContext context) {
    if (profiles.isEmpty) {
      return Center(
        child: Text(
          'No other profiles yet.',
          style: context.theme.typography.body.sm.copyWith(
            color: context.theme.colors.mutedForeground,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      itemCount: profiles.length,
      separatorBuilder: (_, _) => const Gap(AppSpacing.lg),
      itemBuilder: (context, index) =>
          _ProfileListItem(profile: profiles[index]),
    );
  }
}

class _ProfileListItem extends StatelessWidget {
  final UserProfile profile;

  const _ProfileListItem({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ProfileAvatar(
          avatarUrl: profile.avatarUrl,
          size: 48,
          semanticsLabel: '${profile.fullName} profile picture',
        ),
        const Gap(AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.theme.typography.body.md.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
              Text(
                profile.username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.theme.typography.body.sm.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileListFailure extends StatelessWidget {
  final VoidCallback onRetry;

  const _ProfileListFailure({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Could not load profiles.',
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
