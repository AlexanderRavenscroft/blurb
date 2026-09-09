import 'package:blurb/app/session/session_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<SessionCubit, SessionState>(
    builder: (context, state) => FScaffold(
      child: Center(
        child: state is SessionFailure
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Could not load your profile.',
                    style: context.theme.typography.body.md,
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : FCircularProgress(
                semanticsLabel: 'Loading',
                style: .delta(iconStyle: .delta(size: 48)),
              ),
      ),
    ),
  );
}
