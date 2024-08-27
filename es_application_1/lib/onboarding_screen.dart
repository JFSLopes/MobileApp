import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'welcome_screen.dart';

// Some Tests Done

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < 3; i++) {
      list.add(i == _currentPage ? indicator(true) : indicator(false));
    }
    return list;
  }

  Widget indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.grey[300],
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: <Widget>[
                  _createPage(
                    title: "Love Your Planet",
                    description: "Join us in our journey to protect and cherish our home. Every action counts!",
                  ),
                  _createPage(
                    title: "Recycle & Reuse",
                    description: "Learn to make the most of resources and reduce waste. Recycling is a key step towards a sustainable future.",
                  ),
                  _createPage(
                    title: "Green Commuting",
                    description: "Transform your travel by choosing eco-friendly options. Ride a bike, walk, or take public transport for a cleaner world.",
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildPageIndicator(),
            ),
            _currentPage != 2
                ? ElevatedButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.linear,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                foregroundColor: Colors.white,
              ),
              child: const Text('Next'),
            )
                : ElevatedButton(
              onPressed: () async {
                await setOnboardingComplete();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                foregroundColor: Colors.white,
              ),
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createPage({required String title, required String description}) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Aqui podemos adicionar imagenss
          // Image.asset('assets/earth.png'),
          const SizedBox(height: 100.0),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
          const SizedBox(height: 20.0),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18.0),
          ),
        ],
      ),
    );
  }
}
