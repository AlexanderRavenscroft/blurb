import 'package:blurb/app/app_routing.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:remixicon/remixicon.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _bottomBarIndex(navigationShell.currentIndex);

    return FScaffold(
      footer: SafeArea(
        top: false,
        // Consume the inset before Forui adds its own bottom padding.
        child: FBottomNavigationBar(
          safeAreaBottom: false,
          index: selectedIndex,
          onChange: _selectDestination,
          children: [
            FBottomNavigationBarItem(
              semanticsLabel: 'Home',
              icon: Icon(
                selectedIndex == 0
                    ? RemixIcons.home_fill
                    : RemixIcons.home_line,
                color: context.theme.colors.secondaryForeground,
              ),
            ),
            FBottomNavigationBarItem(
              semanticsLabel: 'Search',
              icon: Icon(
                selectedIndex == 1
                    ? RemixIcons.search_fill
                    : RemixIcons.search_line,
                color: context.theme.colors.secondaryForeground,
              ),
            ),
            FBottomNavigationBarItem(
              semanticsLabel: 'Add',
              icon: SizedBox(
                width: 56,
                child: FButton.icon(
                  variant: .primary,
                  onPress: () => _onCreatePostPressed(context),
                  child: Icon(RemixIcons.add_large_fill),
                ),
              ),
            ),
            FBottomNavigationBarItem(
              semanticsLabel: 'Notifications',
              icon: Icon(
                selectedIndex == 3
                    ? RemixIcons.notification_3_fill
                    : RemixIcons.notification_3_line,
                color: context.theme.colors.secondaryForeground,
              ),
            ),
            FBottomNavigationBarItem(
              semanticsLabel: 'Profile',
              icon: Icon(
                selectedIndex == 4
                    ? RemixIcons.user_3_fill
                    : RemixIcons.user_3_line,
                color: context.theme.colors.secondaryForeground,
              ),
            ),
          ],
        ),
      ),
      child: navigationShell,
    );
  }

  int _bottomBarIndex(int branchIndex) {
    return branchIndex < 2 ? branchIndex : branchIndex + 1;
  }

  void _selectDestination(int index) {
    if (index == 2) {
      return;
    }

    final branchIndex = index < 2 ? index : index - 1;
    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }

  void _onCreatePostPressed(BuildContext context) {
    context.pushNamed(AppRoute.createPost.name);
  }
}
