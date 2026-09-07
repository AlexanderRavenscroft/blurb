import 'package:blurb/app/app_routing.dart';
import 'package:blurb/features/auth/presentation/cubits/auth/auth_cubit.dart';
import 'package:blurb/theme/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class BlurbApp extends StatefulWidget {
  const BlurbApp({super.key});

  @override
  State<BlurbApp> createState() => _BlurbAppState();
}

class _BlurbAppState extends State<BlurbApp> {
  late final AuthCubit _authCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit();
    _router = createAppRouter(_authCubit);
  }

  @override
  void dispose() {
    _router.dispose();
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: _authCubit,
    child: BlocListener<AuthCubit, AuthState>(
      listener: (context, state) => _router.refresh(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: lightTheme.toApproximateMaterialTheme(),
        darkTheme: darkTheme.toApproximateMaterialTheme(),
        builder: (context, child) => FTheme(
          data: Theme.brightnessOf(context) == .light ? lightTheme : darkTheme,
          child: FToaster(child: FTooltipGroup(child: child!)),
        ),
        routerConfig: _router,
      ),
    ),
  );
}
