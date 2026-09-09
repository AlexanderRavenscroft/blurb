import 'package:blurb/app/session/session_cubit.dart';
import 'package:blurb/features/auth/domain/exceptions/auth_exception.dart';
import 'package:blurb/features/auth/presentation/mappers/auth_failure_message_mapper.dart';
import 'package:blurb/theme/app_spacing.dart';
import 'package:blurb/utils/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<SessionCubit, SessionState>(
    builder: (context, state) {
      if (state is! SessionAuthenticated) return const SizedBox.shrink();
      final theme = context.theme;

      return Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: .stretch,
            children: [
              Text(
                'Username: ${state.profile.username}',
                style: theme.typography.body.md,
              ),
              const Gap(AppSpacing.md),
              Text(
                'Full Name: ${state.profile.fullName}',
                style: theme.typography.body.md,
              ),
              const Gap(AppSpacing.xl),
              FButton(
                onPress: () => _signOut(context),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      );
    },
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
