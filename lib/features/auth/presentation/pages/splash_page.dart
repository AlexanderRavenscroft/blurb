import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      child: Center(
        child: FCircularProgress(
          semanticsLabel: 'Loading',
          style: .delta(iconStyle: .delta(size: 48)),
        ),
      ),
    );
  }
}
