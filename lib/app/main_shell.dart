import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:remixicon/remixicon.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _contents = [
    const Center(child: Text('Home Placeholder')),
    const Center(child: Text('Search Placeholder')),
    const Center(child: Text('Add Placeholder')),
    const Center(child: Text('Notifications Placeholder')),
    const Center(child: Text('Profile Placeholder')),
  ];

  int _index = 0;

  @override
  Widget build(BuildContext context) => FScaffold(
    footer: SafeArea(
      top: false,
      // Consume the inset before Forui adds its own bottom padding.
      child: FBottomNavigationBar(
        safeAreaBottom: false,
        index: _index,
        onChange: (index) => setState(() => _index = index),
        children: [
          FBottomNavigationBarItem(
            semanticsLabel: 'Home',
            icon: Icon(
              _index == 0 ? RemixIcons.home_fill : RemixIcons.home_line,
              color: context.theme.colors.secondaryForeground,
            ),
          ),
          FBottomNavigationBarItem(
            semanticsLabel: 'Search',
            icon: Icon(
              _index == 1 ? RemixIcons.search_fill : RemixIcons.search_line,
              color: context.theme.colors.secondaryForeground,
            ),
          ),
          FBottomNavigationBarItem(
            semanticsLabel: 'Add',
            icon: SizedBox(
              width: 56,
              child: FButton.icon(
                variant: .primary,
                onPress: () => setState(() => _index = 2),
                child: Icon(RemixIcons.add_large_fill),
              ),
            ),
          ),
          FBottomNavigationBarItem(
            semanticsLabel: 'Notifications',
            icon: Icon(
              _index == 3
                  ? RemixIcons.notification_3_fill
                  : RemixIcons.notification_3_line,
              color: context.theme.colors.secondaryForeground,
            ),
          ),
          FBottomNavigationBarItem(
            semanticsLabel: 'Profile',
            icon: Icon(
              _index == 4 ? RemixIcons.user_3_fill : RemixIcons.user_3_line,
              color: context.theme.colors.secondaryForeground,
            ),
          ),
        ],
      ),
    ),
    child: _contents[_index],
  );
}
