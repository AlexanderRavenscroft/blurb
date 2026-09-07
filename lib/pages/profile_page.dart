import 'package:blurb/features/auth/presentation/cubits/auth/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: FButton(
      onPress: () => context.read<AuthCubit>().signOut(),
      child: const Text('Sign out'),
    ),
  );
}
