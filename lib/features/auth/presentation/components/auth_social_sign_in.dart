import 'package:blurb/features/auth/presentation/cubits/social_auth/social_auth_cubit.dart';
import 'package:blurb/features/auth/presentation/mappers/auth_failure_message_mapper.dart';
import 'package:blurb/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:remixicon/remixicon.dart';

class AuthSocialSignIn extends StatelessWidget {
  const AuthSocialSignIn({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isSubmitting = context.select(
      (SocialAuthCubit cubit) => cubit.state is SocialAuthSubmitting,
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
                icon: Icon(RemixIcons.discord_fill),
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
