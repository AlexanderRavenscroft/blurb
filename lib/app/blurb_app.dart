import 'package:blurb/app/main_shell.dart';
import 'package:blurb/theme/theme.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';

class BlurbApp extends StatelessWidget {
  const BlurbApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: lightTheme.toApproximateMaterialTheme(),
    darkTheme: darkTheme.toApproximateMaterialTheme(),
    builder: (context, child) => FTheme(
      data: Theme.brightnessOf(context) == .light ? lightTheme : darkTheme,
      child: FToaster(child: FTooltipGroup(child: child!)),
    ),
    home: const MainShell(),
  );
}
