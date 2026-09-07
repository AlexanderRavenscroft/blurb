import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class AuthSwitchPrompt extends StatefulWidget {
  const AuthSwitchPrompt({
    super.key,
    required this.text,
    required this.buttonText,
    required this.onPressed,
  });

  final String text;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  State<AuthSwitchPrompt> createState() => _AuthSwitchPromptState();
}

class _AuthSwitchPromptState extends State<AuthSwitchPrompt> {
  late final _linkRecognizer = TapGestureRecognizer()
    ..onTap = () => widget.onPressed();

  @override
  void dispose() {
    _linkRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Text.rich(
      TextSpan(
        text: '${widget.text} ',
        children: [
          TextSpan(
            text: widget.buttonText,
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.primary,
              fontWeight: .w600,
            ),
            recognizer: _linkRecognizer,
            mouseCursor: SystemMouseCursors.click,
          ),
        ],
      ),
      textAlign: TextAlign.center,
      style: theme.typography.body.xs.copyWith(
        color: theme.colors.mutedForeground,
      ),
    );
  }
}
