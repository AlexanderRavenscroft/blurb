import 'package:blurb/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:remixicon/remixicon.dart';

class AuthSocialSignIn extends StatelessWidget {
  const AuthSocialSignIn({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
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
            const _SocialSignInButton(
              provider: 'Apple',
              icon: Icon(RemixIcons.apple_fill),
            ),
            const _SocialSignInButton(
              provider: 'Facebook',
              icon: Icon(
                RemixIcons.facebook_circle_fill,
                color: Color(0xFF1877F2),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialSignInButton extends StatelessWidget {
  const _SocialSignInButton({required this.provider, required this.icon});

  final String provider;
  final Widget icon;

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
      onPressed: () {
        // TODO: Connect provider authentication.
      },
      icon: icon,
    );
  }
}
