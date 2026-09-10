import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:blurb/features/auth/presentation/cubits/social_auth/social_auth_cubit.dart';
import 'package:blurb/features/auth/presentation/mappers/auth_failure_message_mapper.dart';
import 'package:blurb/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:remixicon/remixicon.dart';

class AuthSocialSignIn extends StatefulWidget {
  const AuthSocialSignIn({super.key});

  @override
  State<AuthSocialSignIn> createState() => _AuthSocialSignInState();
}

class _AuthSocialSignInState extends State<AuthSocialSignIn>
    with WidgetsBindingObserver {
  static const _resumeGracePeriod = Duration(milliseconds: 500);

  late final SocialAuthCubit _socialAuthCubit;
  late final StreamSubscription<Uri> _deepLinkSubscription;
  Timer? _resumeTimer;

  @override
  void initState() {
    super.initState();
    _socialAuthCubit = context.read<SocialAuthCubit>();
    WidgetsBinding.instance.addObserver(this);
    _deepLinkSubscription = AppLinks().uriLinkStream.listen(_handleDeepLink);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;

    _resumeTimer?.cancel();
    _resumeTimer = Timer(
      _resumeGracePeriod,
      _socialAuthCubit.oauthFlowReturnedWithoutRedirect,
    );
  }

  void _handleDeepLink(Uri uri) {
    _resumeTimer?.cancel();

    final parameters = <String, String>{...uri.queryParameters};
    if (uri.fragment.isNotEmpty) {
      parameters.addAll(Uri.splitQueryString(uri.fragment));
    }

    final hasError =
        parameters.containsKey('error') ||
        parameters.containsKey('error_code') ||
        parameters.containsKey('error_description');

    if (hasError) {
      _socialAuthCubit.oauthRedirectFailed();
    } else {
      _socialAuthCubit.oauthRedirectReceived();
    }
  }

  @override
  void dispose() {
    _resumeTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_deepLinkSubscription.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isSubmitting = context.select(
      (SocialAuthCubit cubit) =>
          cubit.state is SocialAuthSubmitting ||
          cubit.state is SocialAuthAwaitingOAuthRedirect,
    );

    return BlocListener<SocialAuthCubit, SocialAuthState>(
      listener: (context, state) {
        if (state is SocialAuthFailure) {
          showFToast(
            context: context,
            title: Text(AuthFailureMessageMapper.forSocialSignIn(state.code)),
            variant: FToastVariant.destructive,
            duration: const Duration(seconds: 3),
          );
        }
      },
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: FDivider()),
              const Gap(AppSpacing.md),
              Text(
                'Or',
                style: theme.typography.body.xs.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const Gap(AppSpacing.md),
              Expanded(child: FDivider()),
            ],
          ),
          const Gap(AppSpacing.xl),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _SocialSignInButton(
                provider: 'Google',
                onPressed: isSubmitting
                    ? null
                    : () => context.read<SocialAuthCubit>().signInWithGoogle(),
                icon: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => const SweepGradient(
                    colors: [
                      Color(0xFF4285F4),
                      Color(0xFF34A853),
                      Color(0xFFFBBC05),
                      Color(0xFFEA4335),
                      Color(0xFF4285F4),
                    ],
                  ).createShader(bounds),
                  child: const Icon(RemixIcons.google_fill),
                ),
              ),
              _SocialSignInButton(
                provider: 'Facebook',
                icon: Icon(
                  RemixIcons.facebook_circle_fill,
                  color: Color(0xFF1877F2),
                ),
                onPressed: isSubmitting
                    ? null
                    : () =>
                          context.read<SocialAuthCubit>().signInWithFacebook(),
              ),
              _SocialSignInButton(
                provider: 'Discord',
                icon: Icon(RemixIcons.discord_fill, color: Color(0xFF5865F2)),
                onPressed: isSubmitting
                    ? null
                    : () => context.read<SocialAuthCubit>().signInWithDiscord(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialSignInButton extends StatelessWidget {
  const _SocialSignInButton({
    required this.provider,
    required this.icon,
    required this.onPressed,
  });

  final String provider;
  final Widget icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return IconButton.outlined(
      tooltip: 'Continue with $provider',
      style: IconButton.styleFrom(
        minimumSize: const Size.square(48),
        padding: const EdgeInsets.all(AppSpacing.md),
        shape: const CircleBorder(),
        side: BorderSide(color: colors.border),
        foregroundColor: colors.foreground,
      ),
      onPressed: onPressed,
      icon: icon,
    );
  }
}
