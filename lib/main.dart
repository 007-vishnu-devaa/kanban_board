import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kanbanboard/firebase_options.dart';
import 'login/presentation/login_page.dart';
import 'core/auth_storage.dart';
import 'core/connectivity_widgets.dart';
import 'kanban_board/home_page.dart';


Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Colors.teal;
    final colorScheme = ColorScheme.fromSeed(seedColor: seed);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kanban Board',
      theme: ThemeData(
        colorScheme: colorScheme,
        primaryColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.primary),
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          iconTheme: IconThemeData(color: colorScheme.onPrimary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.primary,
          ),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: colorScheme.primary,
          selectionColor: colorScheme.primary.withOpacity(0.3),
          selectionHandleColor: colorScheme.primary,
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.0),
            borderSide: BorderSide(color: colorScheme.primary),
          ),
          floatingLabelStyle: TextStyle(color: colorScheme.primary),
          suffixIconColor: colorScheme.primary,
        ),
      ),
      home: FutureBuilder<bool>(
        future: AuthStorage.isLoggedIn(),
        builder: (context, snapshot) {
          final loggedIn = snapshot.data ?? false;
          final child = loggedIn ? const HomePage() : const LoginPage();
          return ConnectivityListener(child: child);
        },
      ),
    );
  }
  
}
