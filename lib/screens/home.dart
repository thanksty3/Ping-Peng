import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ping_peng/screens/chats.dart';
import 'package:ping_peng/screens/shows.dart';
import 'package:ping_peng/screens/account.dart';
import 'package:ping_peng/utils/database_services.dart';
import 'package:ping_peng/utils/utils.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final DatabaseService _databaseService = DatabaseService();
  List<Map<String, dynamic>> _users = [];
  int _currentUserIndex = 0;
  bool _isLoading = true;
  int _nextButtonCount = 0;

  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadInterstitialAd();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasMoreUsers = _currentUserIndex < _users.length;

    return Scaffold(
      appBar: const HomeNavAppBar(),
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(
              child: Text(
                'Loading Profile...',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          : hasMoreUsers
              ? Account(
                  key: ValueKey(_users[_currentUserIndex]['userId']),
                  userId: _users[_currentUserIndex]['userId'],
                  isHome: true,
                )
              : const Center(
                  child: Text(
                    'No more users!',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
      bottomNavigationBar: const HomeNavBottomNavigationBar(),
    );
  }

  void nextUser() {
    setState(() {
      if (_currentUserIndex < _users.length - 1) {
        _currentUserIndex++;
        _nextButtonCount++;

        if (_nextButtonCount % 10 == 0) {
          _showInterstitialAd();
        }
      } else {
        Center(
          child: Text(
            "No New Pengs to Show",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        );
      }
    });
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-8128309454998324/1143919685',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
          debugPrint('Interstitial Ad Loaded Successfully');
        },
        onAdFailedToLoad: (error) {
          debugPrint('Failed to load interstitial ad: $error');
          _isAdLoaded = false;
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_isAdLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          debugPrint('Failed to show interstitial ad: $error');
          _loadInterstitialAd();
        },
      );

      _interstitialAd!.show();
      _interstitialAd = null;
      _isAdLoaded = false;
    } else {
      debugPrint('Interstitial ad not ready yet');
    }
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = await _databaseService.getCurrentUser();
      if (currentUser == null) throw Exception("No user logged in.");

      final users = await _databaseService.getAllUsersExcept(currentUser.uid);

      final currentUserData =
          await _databaseService.getUserDataForUserId(currentUser.uid);

      if (currentUserData == null) {
        throw Exception("Failed to fetch current user data.");
      }

      final blockedUsers =
          List<String>.from(currentUserData['blockedUsers'] ?? []);

      final filteredUsers = users
          .where(
            (user) => !blockedUsers.contains(user['userId']),
          )
          .toList();

      filteredUsers.shuffle();

      setState(() {
        _users = filteredUsers;
        debugPrint(
            "Loaded users: ${_users.map((user) => user['userId']).toList()}");
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to load users: $e",
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          backgroundColor: Colors.white,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }
}

class HomeNavBottomNavigationBar extends StatelessWidget {
  const HomeNavBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final homeState = context.findAncestorStateOfType<_HomeState>();

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 2,
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.tv, color: Colors.white, size: 40),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Shows()),
              );
            },
          ),
          ElevatedButton(
            onPressed: () {
              homeState?.nextUser();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Next',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.white, size: 40),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Chats()),
              );
            },
          ),
        ],
      ),
    );
  }
}
