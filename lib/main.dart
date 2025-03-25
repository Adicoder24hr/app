import 'package:app/Pages/dashboard.page.dart';
import 'package:app/Pages/index.page.dart';
import 'package:app/Pages/login.page.dart';
import 'package:app/Pages/register.page.dart';
import 'package:app/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import "package:go_router/go_router.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final User? _auth = FirebaseAuth.instance.currentUser;

  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: _auth != null ? "/home" : "/",
      routes: [
        GoRoute(
          path: "/",
          builder: (context, state) => Home(),
        ),
        GoRoute(
          path: "/login",
          builder: (context, state) => const Login(),
        ),
        GoRoute(
          path: "/register",
          builder: (context, state) => const Register(),
        ),
        GoRoute(
          path: "/home",
          builder: (context, state) => const Dashboard(),
        ),
        // ShellRoute(
        //   routes: [
        //     GoRoute(
        //       path: "/home",
        //       builder: (context, state) => const Dashboard(),
        //     ),
        //   ],
        //   builder: (BuildContext context, GoRouterState state, Widget child) {
        //     return Scaffold(
        //       appBar: const MyAppBar(),
        //       drawer: const AppDrawer(),
        //       body: Center(
        //         child: child,
        //       ),
        //     );
        //   },
        // )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: "G1 App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.redAccent,
            brightness: Brightness.light,
            contrastLevel: -1),
      ),
    );
  }
}
