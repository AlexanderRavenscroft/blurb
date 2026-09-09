import 'package:blurb/app/main_shell.dart';
import 'package:blurb/app/session/session_cubit.dart';
import 'package:blurb/features/auth/presentation/pages/login_page.dart';
import 'package:blurb/features/auth/presentation/pages/register_page.dart';
import 'package:blurb/features/auth/presentation/pages/splash_page.dart';
import 'package:blurb/features/profile/presentation/pages/profile_setup_page.dart';
import 'package:blurb/features/profile/presentation/pages/profile_page.dart';
import 'package:blurb/pages/create_post_page.dart';
import 'package:blurb/pages/home_page.dart';
import 'package:blurb/pages/notifications_page.dart';
import 'package:blurb/pages/search_page.dart';
import 'package:go_router/go_router.dart';

enum AppRoute {
  splash,
  login,
  register,
  profileSetup,
  home,
  search,
  createPost,
  notifications,
  profile,
}

GoRouter createAppRouter(SessionCubit sessionCubit) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final sessionState = sessionCubit.state;
      final location = state.matchedLocation;

      final homeLocation = state.namedLocation(AppRoute.home.name);
      final splashLocation = state.namedLocation(AppRoute.splash.name);
      final loginLocation = state.namedLocation(AppRoute.login.name);
      final registerLocation = state.namedLocation(AppRoute.register.name);
      final profileSetupLocation = state.namedLocation(
        AppRoute.profileSetup.name,
      );

      final isOnSplash = location == splashLocation;
      final isOnLogin = location == loginLocation;
      final isOnRegister = location == registerLocation;
      final isOnProfileSetup = location == profileSetupLocation;
      final isOnAuthPage = isOnLogin || isOnRegister;

			if (sessionState is SessionChecking || sessionState is SessionFailure) {
        return isOnSplash ? null : splashLocation;
      }

      if (sessionState is SessionUnauthenticated) {
        return isOnAuthPage ? null : loginLocation;
      }

      if (sessionState is SessionNeedsProfile) {
        return isOnProfileSetup ? null : profileSetupLocation;
      }

      if (sessionState is SessionAuthenticated) {
        if (isOnSplash || isOnAuthPage || isOnProfileSetup) {
          return homeLocation;
        }

        return null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: AppRoute.splash.name,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: AppRoute.login.name,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: AppRoute.register.name,
        builder: (context, state) => const RegisterPage(),
        routes: [
          GoRoute(
            path: 'setup-profile',
            name: AppRoute.profileSetup.name,
            builder: (context, state) => const ProfileSetupPage(),
          ),
        ],
      ),

      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: AppRoute.home.name,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                name: AppRoute.search.name,
                builder: (context, state) => const SearchPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notifications',
                name: AppRoute.notifications.name,
                builder: (context, state) => const NotificationsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: AppRoute.profile.name,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: '/create-post',
        name: AppRoute.createPost.name,
        builder: (context, state) => const CreatePostPage(),
      ),
    ],
  );
}
