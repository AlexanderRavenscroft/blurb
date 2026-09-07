import 'package:forui/widgets/header.dart';
import 'package:forui/widgets/scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class CreatePostPage extends StatelessWidget {
  const CreatePostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader.nested(
        title: const Text('Appointment'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: const Center(child: Text('Create Post Placeholder')),
    );
  }
}
