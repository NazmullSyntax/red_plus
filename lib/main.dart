import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

// Screens
import 'screens/chat_screen.dart';
import 'screens/create_post_screen.dart';
import 'screens/donor_screen.dart';
import 'screens/my_req_screen.dart';
import 'screens/patient_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/send_sos_screen.dart';
import 'screens/sos_noti_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/create_account_screen.dart';
import 'screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Red-Pulse',
      theme: ThemeData(primarySwatch: Colors.red, fontFamily: 'Roboto'),

      // Initial route
      initialRoute: '/',

      // ✅ STATIC ROUTES
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/create': (context) => const CreateAccountScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/dhome': (context) => const DonorScreen(),
        '/cphome': (context) => const CreatePostScreen(),
        '/phome': (context) => const PatientScreen(),
        '/sendsos': (context) => const SendSosScreen(),
        '/myreq': (context) => const MyReqScreen(),
        '/sosnoti': (context) => const SosNotiScreen(),
      },

      // ✅ DYNAMIC ROUTES (ARGUMENT-BASED)
      onGenerateRoute: (settings) {
        if (settings.name == '/chat') {
          final args = settings.arguments as Map<String, dynamic>;

          return MaterialPageRoute(
            builder: (_) => ChatScreen(
              chatId: args['chatId'], // 🔑 NEW
              otherUserId: args['otherUserId'], // 🔑 NEW
            ),
          );
        }

        return null;
      },
    );
  }
}
