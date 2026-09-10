import 'package:blurb/app/session/session_cubit.dart';
import 'package:blurb/features/auth/domain/auth_exception.dart';
import 'package:blurb/features/auth/presentation/auth_failure_message_mapper.dart';
import 'package:blurb/theme/app_spacing.dart';
import 'package:blurb/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) => FScaffold(
    header: FHeader.nested(
      title: const Text('Settings'),
      prefixes: [FHeaderAction.back(onPress: () => context.pop())],
    ),
    child: Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.lg),
        child: FButton(
          onPress: () => _signOut(context),
          variant: .destructive,
          child: const Text('Sign out'),
        ),
      ),
    ),
  );

  Future<void> _signOut(BuildContext context) async {
    try {
      await context.read<SessionCubit>().signOut();
    } on AuthException catch (exception) {
      if (!context.mounted) return;
      _showSignOutFailure(context, exception.code);
    } catch (error, stackTrace) {
      log.e(
        'Unexpected sign-out failure',
        error: error,
        stackTrace: stackTrace,
      );
      if (!context.mounted) return;
      _showSignOutFailure(context, AuthExceptionCode.unknown);
    }
  }

  void _showSignOutFailure(BuildContext context, AuthExceptionCode code) {
    showFToast(
      context: context,
      title: Text(AuthFailureMessageMapper.forSignOut(code)),
      variant: FToastVariant.destructive,
      duration: const Duration(seconds: 3),
    );
  }
}
