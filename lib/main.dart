import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ping_peng/screens/login.dart';
import 'package:ping_peng/screens/home.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Initialize Google Mobile Ads
  MobileAds.instance.initialize();

  // 2) Initialize Firebase
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This was your existing ad initialization.
  // We leave it as-is (in case you need it for other ad formats).
  NativeAd nativeAd = NativeAd(
    adUnitId: "ca-app-pub-8128309454998324/1174906941",
    listener: NativeAdListener(
      onAdLoaded: (Ad ad) {
        print('Ad loaded');
      },
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        print('Failed to load Ad: $error');
        ad.dispose();
      },
      onAdOpened: (Ad ad) {
        print('Ad opened');
      },
    ),
    request: const AdRequest(),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const Login(),
        '/home': (context) => const Home(),
      },
      theme: ThemeData(
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            color: Colors.orange,
          ),
          displayMedium: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w900,
            color: Colors.orange,
          ),
        ),
      ),
    );
  }
}

// Existing SplashScreen remains untouched
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Keep your splash timer logic as is
    Timer(const Duration(seconds: 3), () async {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('assets/images/P!ngPeng.png'),
      ),
    );
  }
}

class MyNativeAd extends StatefulWidget {
  const MyNativeAd({Key? key}) : super(key: key);

  @override
  State<MyNativeAd> createState() => _MyNativeAdState();
}

class _MyNativeAdState extends State<MyNativeAd> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadNativeAd();
  }

  void _loadNativeAd() {
    _nativeAd = NativeAd(
      adUnitId: "ca-app-pub-8128309454998324/1174906941",
      // The factoryId must match the ID you registered in the native code
      factoryId: "myNativeAdFactory",
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _isAdLoaded = true;
          });
          print("Native advanced ad loaded");
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print("Native advanced ad failed to load: $error");
          ad.dispose();
        },
      ),
      request: const AdRequest(),
    )..load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _nativeAd == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 400,
      child: AdWidget(ad: _nativeAd!),
    );
  }
}
