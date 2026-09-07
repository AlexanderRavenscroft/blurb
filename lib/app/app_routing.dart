import 'package:blurb/app/main_shell.dart';
import 'package:blurb/features/auth/presentation/pages/login_page.dart';
import 'package:blurb/features/auth/presentation/pages/register_page.dart';
import 'package:blurb/features/auth/presentation/pages/splash_page.dart';
import 'package:blurb/pages/create_post_page.dart';
import 'package:blurb/pages/home_page.dart';
import 'package:blurb/pages/notifications_page.dart';
import 'package:blurb/pages/profile_page.dart';
import 'package:blurb/pages/search_page.dart';
import 'package:go_router/go_router.dart';

enum AppRoute {
  splash,
  login,
  register,
  home,
  search,
  createPost,
  notifications,
  profile,
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
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
