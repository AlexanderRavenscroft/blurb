import 'package:blurb/app/app_routing.dart';
import 'package:blurb/theme/theme.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';

class BlurbApp extends StatelessWidget {
  const BlurbApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    debugShowCheckedModeBanner: false,
    theme: lightTheme.toApproximateMaterialTheme(),
    darkTheme: darkTheme.toApproximateMaterialTheme(),
    builder: (context, child) => FTheme(
      data: Theme.brightnessOf(context) == .light ? lightTheme : darkTheme,
      child: FToaster(child: FTooltipGroup(child: child!)),
    ),
    routerConfig: appRouter,
  );
}
