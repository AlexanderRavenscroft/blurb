import 'package:blurb/app/blurb_app.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://faysmljuicarhlpmudwi.supabase.co',
    publishableKey: 'sb_publishable__j4UEyEKoPWjyxXcHplFfA_Njui_bcd',
  );

  runApp(const BlurbApp());
}
