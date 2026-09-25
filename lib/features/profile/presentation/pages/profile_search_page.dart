import 'package:blurb/app/app_routing.dart';
import 'package:blurb/app/session/session_cubit.dart';
import 'package:blurb/features/profile/domain/profile_repository.dart';
import 'package:blurb/features/profile/domain/user_profile.dart';
import 'package:blurb/features/profile/presentation/components/profile_avatar.dart';
import 'package:blurb/features/profile/presentation/cubits/profile_list/profile_list_cubit.dart';
import 'package:blurb/theme/app_radius.dart';
import 'package:blurb/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

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

class ProfileSearchView extends StatefulWidget {
  final String currentUserId;

  const ProfileSearchView({super.key, required this.currentUserId});

  @override
  State<ProfileSearchView> createState() => _ProfileSearchViewState();
}

class _ProfileSearchViewState extends State<ProfileSearchView> {
  String _query = '';

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
      child: Column(
        children: [
          FTextField(
            control: .managed(
              onChange: (value) {
                if (_query == value.text) return;
                setState(() => _query = value.text);
              },
            ),
            hint: 'Search profiles',
            textInputAction: .search,
            autocorrect: false,
            prefixBuilder: (context, style, variants) =>
                FTextField.prefixIconBuilder(
                  context,
                  style,
                  variants,
                  context.theme.icons.search(
                    context,
                    semanticsLabel: 'Search profiles',
                  ),
                ),
            clearable: (value) => value.text.isNotEmpty,
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: BlocBuilder<ProfileListCubit, ProfileListState>(
              builder: (context, state) => switch (state) {
                ProfileListLoading() => const Center(
                  child: FCircularProgress(),
                ),
                ProfileListLoaded(:final profiles) => _ProfileList(
                  profiles: _filterProfiles(profiles),
                  isSearching: _query.trim().isNotEmpty,
                ),
                ProfileListFailure() => _ProfileListFailure(
                  onRetry: () => context.read<ProfileListCubit>().loadProfiles(
                    userId: widget.currentUserId,
                  ),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }

  List<UserProfile> _filterProfiles(List<UserProfile> profiles) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return profiles;

    return profiles
        .where(
          (profile) =>
              profile.fullName.toLowerCase().contains(query) ||
              profile.username.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }
}

class _ProfileList extends StatelessWidget {
  final List<UserProfile> profiles;
  final bool isSearching;

  const _ProfileList({required this.profiles, required this.isSearching});

  @override
  Widget build(BuildContext context) {
    if (profiles.isEmpty) {
      return Center(
        child: Text(
          isSearching ? 'No profiles found.' : 'No other profiles yet.',
          style: context.theme.typography.body.sm.copyWith(
            color: context.theme.colors.mutedForeground,
          ),
        ),
      );
    }

    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
    return FTappable(
      builder: (context, states, child) => Container(
        decoration: BoxDecoration(
          color:
              (states.contains(FTappableVariant.hovered) ||
                  states.contains(FTappableVariant.pressed))
              ? context.theme.colors.secondary
              : context.theme.colors.background,
          borderRadius: .circular(AppRadius.md),
        ),
        child: child!,
      ),
      style: const .delta(motion: FTappableMotion.none),
      onPress: () => context.pushNamed(
        AppRoute.publicProfile.name,
        pathParameters: {'userId': profile.id},
        extra: profile,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ProfileAvatar(
            avatarUrl: profile.avatarUrl,
            size: 50,
            semanticsLabel: '${profile.fullName} profile picture',
          ),
          const Gap(AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1,
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
      ),
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
