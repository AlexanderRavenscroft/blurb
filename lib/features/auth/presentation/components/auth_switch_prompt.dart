import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class AuthSwitchPrompt extends StatefulWidget {
  final String text;
  final String buttonText;
  final VoidCallback? onPressed;

  const AuthSwitchPrompt({
    super.key,
    required this.text,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  State<AuthSwitchPrompt> createState() => _AuthSwitchPromptState();
}

class _AuthSwitchPromptState extends State<AuthSwitchPrompt> {
  late final _linkRecognizer = TapGestureRecognizer()
    ..onTap = () => widget.onPressed?.call();

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
              color: widget.onPressed == null
                  ? theme.colors.mutedForeground
                  : theme.colors.primary,
              fontWeight: .w600,
            ),
            recognizer: widget.onPressed == null ? null : _linkRecognizer,
            mouseCursor: widget.onPressed == null
                ? SystemMouseCursors.basic
                : SystemMouseCursors.click,
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
