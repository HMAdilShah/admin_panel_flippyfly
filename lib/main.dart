import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';

import 'package:webkit/firebase_options.dart';
import 'package:webkit/helpers/localizations/app_localization_delegate.dart';
import 'package:webkit/helpers/localizations/language.dart';
import 'package:webkit/helpers/services/navigation_service.dart';
import 'package:webkit/helpers/storage/local_storage.dart';
import 'package:webkit/helpers/theme/app_notifier.dart';
import 'package:webkit/helpers/theme/app_style.dart';
import 'package:webkit/helpers/theme/theme_customizer.dart';
import 'package:webkit/routes.dart';

Future<void> main() async {
WidgetsFlutterBinding.ensureInitialized();

await Firebase.initializeApp(
options: DefaultFirebaseOptions.currentPlatform,
);

setPathUrlStrategy();

await LocalStorage.init();
AppStyle.init();
await ThemeCustomizer.init();

runApp(
ChangeNotifierProvider<AppNotifier>(
create: (context) => AppNotifier(),
child: const MyApp(),
),
);
}

class MyApp extends StatelessWidget {
const MyApp({super.key});

@override
Widget build(BuildContext context) {
return Consumer<AppNotifier>(
builder: (_, notifier, ___) {
return GetMaterialApp(
debugShowCheckedModeBanner: false,

/// 🎨 Theme
theme: AppTheme.lightTheme,
darkTheme: AppTheme.darkTheme,
themeMode: ThemeCustomizer.instance.theme,

/// 🌐 Navigation
navigatorKey: NavigationService.navigatorKey,

/// ⚠️ IMPORTANT: route must exist in routes.dart
initialRoute: '/dashboard',

/// 📌 Routes
getPages: getPageRoute(),

builder: (context, child) {
NavigationService.registerContext(context);
return Directionality(
textDirection: AppTheme.textDirection,
child: child ?? const SizedBox(),
);
},

/// 🌍 Localization
localizationsDelegates: [
AppLocalizationsDelegate(context),
GlobalMaterialLocalizations.delegate,
GlobalWidgetsLocalizations.delegate,
GlobalCupertinoLocalizations.delegate,
],

supportedLocales: Language.getLocales(),
);
},
);
}
}
