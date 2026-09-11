import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:remixicon/remixicon.dart';

class ProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final double size;
  final VoidCallback? onPress;
  final String semanticsLabel;

  const ProfileAvatar({
    super.key,
    required this.avatarUrl,
    this.size = 88,
    this.onPress,
    this.semanticsLabel = 'Profile picture',
  });

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl?.trim() ?? '';
    final avatar = url.isEmpty
        ? FAvatar.raw(size: size)
        : FAvatar(
            image: NetworkImage(url),
            size: size,
            fallback: const Icon(RemixIcons.user_3_line),
          );

    final callback = onPress;
    if (callback != null) {
      return FTappable(
        onPress: callback,
        semanticsLabel: semanticsLabel,
        excludeSemantics: true,
        child: avatar,
      );
    }

    return Semantics(
      label: semanticsLabel,
      image: true,
      child: ExcludeSemantics(child: avatar),
    );
  }
}
