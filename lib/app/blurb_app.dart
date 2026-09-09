import 'package:blurb/app/app_routing.dart';
import 'package:blurb/app/session/session_cubit.dart';
import 'package:blurb/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:blurb/features/auth/domain/repositories/auth_repository.dart';
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
  late final AuthRepository _authRepository;
  late final SessionCubit _sessionCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepositoryImpl();
    _sessionCubit = SessionCubit(authRepository: _authRepository);
    _router = createAppRouter(_sessionCubit);
  }

  @override
  void dispose() {
    _router.dispose();
    _sessionCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      RepositoryProvider<AuthRepository>.value(
        value: _authRepository,
        child: BlocProvider.value(
          value: _sessionCubit,
          child: BlocListener<SessionCubit, SessionState>(
            listener: (context, state) {
              final location = _router.routeInformationProvider.value.uri.path;
              if (state is SessionAuthenticated &&
                  location == _router.namedLocation(AppRoute.register.name)) {
                _sessionCubit.requireProfileSetup();
                return;
              }
              _router.refresh();
            },
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              theme: lightTheme.toApproximateMaterialTheme(),
              darkTheme: darkTheme.toApproximateMaterialTheme(),
              builder: (context, child) => FTheme(
                data: Theme.brightnessOf(context) == .light
                    ? lightTheme
                    : darkTheme,
                child: FToaster(child: FTooltipGroup(child: child!)),
              ),
              routerConfig: _router,
            ),
          ),
        ),
      );
}
