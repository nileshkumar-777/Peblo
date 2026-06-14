import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'story_buddy_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const PipsStoryBuddyScreen(),
    );
  }
}

class PipsStoryBuddyScreen extends StatefulWidget {
  const PipsStoryBuddyScreen({super.key});

  @override
  State<PipsStoryBuddyScreen> createState() => _PipsStoryBuddyScreenState();
}

class _PipsStoryBuddyScreenState extends State<PipsStoryBuddyScreen> {
  int _currentActiveStar = -1;
  Timer? _starTimer;

  @override
  void initState() {
    super.initState();

    // Animate the stars lighting up exactly in sync with the 4-second delay
    // (5 stars * 800ms = 4000ms / 4 seconds total)
    _starTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      setState(() {
        if (_currentActiveStar < 4) {
          _currentActiveStar++;
        }
      });
    });

    // Simulate a loading delay of 4 seconds, then navigate to the home screen.
    // If you have actual data to load, you would replace this Future.delayed with your loading logic.
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const StoryBuddyScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _starTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFA07A), // Light Salmon
              Color(0xFFFF69B4), // Hot Pink
              Color(0xFF8A2BE2), // Blue Violet
              Color(0xFF00BFFF), // Deep Sky Blue
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // BACKGROUND PATTERN PLACEHOLDER
              // Wrap this whole Stack in another Stack if you have a full-screen
              // background image with the books, moons, and stars.
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // MAIN TITLE
                  // Note: Use a custom bubbly font in pubspec.yaml for exact match
                  Stack(
                    children: [
                      // Text outline/shadow effect
                      Text(
                        "Pip's\nStory Buddy",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 10
                            ..color = Colors.deepPurple.shade800,
                        ),
                      ),
                      // Solid inner text
                      Text(
                        "Pip's\nStory Buddy",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          color: Colors.yellowAccent,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),

                  // ROBOT CHARACTER PLACEHOLDER
                  // Replace Icon with Image.asset('assets/pip_robot.png')
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.9),
                          blurRadius: 50,
                          spreadRadius: 20,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.4),
                          blurRadius: 100,
                          spreadRadius: 45, // Soft, feathered outer glow
                        ),
                      ],
                    ),
                    clipBehavior:
                        Clip.antiAlias, // Ensures the GIF clips to the circle
                    child: Image.asset('assets/pip.gif.gif', fit: BoxFit.cover),
                  ),

                  const SizedBox(height: 36),

                  // SUBTITLE
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      "Preparing your magical\nstory adventure...",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // STATUS TEXT
                  Text(
                    "Warming up Pip's storytelling circuits...",
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // STAR LOADING BAR
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildGlowingStar(
                          Colors.yellowAccent,
                          _currentActiveStar >= 0,
                        ),
                        _buildGlowingStar(
                          Colors.orangeAccent,
                          _currentActiveStar >= 1,
                        ),
                        _buildGlowingStar(
                          Colors.pinkAccent,
                          _currentActiveStar >= 2,
                        ),
                        _buildGlowingStar(
                          Colors.cyanAccent,
                          _currentActiveStar >= 3,
                        ),
                        _buildGlowingStar(
                          Colors.greenAccent,
                          _currentActiveStar >= 4,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // FOOTER TEXT
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: Text(
                      "Get ready to listen, learn, and play!",
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: Colors.yellowAccent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to create the colored stars in the loading bar
  Widget _buildGlowingStar(Color color, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withOpacity(0.8),
                  blurRadius: 12,
                  spreadRadius: 3,
                ),
              ]
            : [],
      ),
      child: Icon(
        Icons.star_rounded,
        color: isActive ? color : color.withOpacity(0.3),
        size: 28,
      ),
    );
  }
}

// ----------------------------------------------------------------------
// A standard, basic loading screen, provided as requested.
// If you prefer to use this instead, change the 'home:' property in
// MyApp to 'home: const NormalLoadingScreen()'.
// ----------------------------------------------------------------------
class NormalLoadingScreen extends StatelessWidget {
  const NormalLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text(
              "Loading...",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
