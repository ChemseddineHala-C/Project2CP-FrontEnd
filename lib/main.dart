//import './picheur/notificationph.dart';
import './signin/cubit/authcubit.dart';
import './signin/cubit/themecubit.dart';
import './signin/signup/splage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import './vitirinaire/dashboardVet.dart';
//import './admin/userMan.dart';
import 'package:app_links/app_links.dart';
import './signin/signup/setPassword.dart';

void main() async {
  /// ch
  WidgetsFlutterBinding.ensureInitialized();
  /// ch
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => ThemeCubit()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //const _MyApp({super.key});

  /// ch
  final _appLinks = AppLinks();
  final _navKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    _appLinks.uriLinkStream.listen((uri) {
      if (uri.scheme == 'bahrfresh' && uri.host == 'reset-password') {
        final token = uri.queryParameters['token'];
        final email = uri.queryParameters['email'];

        if (token != null && email != null) {
          _navKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => ResetPasswordPage(token: token, email: email),
            ),
          );
        }
      }
    });
  }
  /// ch

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp(
          /// ch
          navigatorKey: _navKey,
          /// ch
          debugShowCheckedModeBanner: false,
          title: "Let's Fishing",
          themeMode: themeMode,
          // --- THÈME CLAIR ---
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF5F7F9),
            primaryColor: const Color(0xFF013D73),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black),
              titleTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            cardTheme: CardThemeData(
              // Correction: CardThemeData au lieu de CardTheme
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          // --- THÈME SOMBRE ---
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            primaryColor: const Color(0xFF01A896),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            cardTheme: CardThemeData(
              // Correction: CardThemeData au lieu de CardTheme
              color: const Color(0xFF1E1E1E),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white70),
            ),
            dividerTheme: const DividerThemeData(color: Colors.white12),
          ),
          home: const SplashPage(),
        );
      },
    );
  }
}



