import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'story_popup.dart';
import 'story_data.dart';

class StoryBuddyScreen extends ConsumerWidget {
  const StoryBuddyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),

        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 330),
              const Spacer(flex: 1), // Keeps the image beautifully balanced
              Padding(
                padding: const EdgeInsets.only(
                  right: 0.0,
                  top: 20.0,
                ), // Shifts the image left and down
                child: Image.asset(
                  'assets/story.png',
                  width: 280, // Makes the image slightly bigger
                ),
              ),
              const Spacer(flex: 2), // Pushes the button more toward the bottom
              GestureDetector(
                onTap: () {
                  StoryPopup.show(context, pipsMagicalTale);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  color: Colors
                      .transparent, // Makes the entire padded area clickable
                  child: Text(
                    "Start Story Adventure",
                    style: GoogleFonts.fredoka(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF4A148C),
                      shadows: [
                        Shadow(
                          color: Colors.white.withOpacity(0.9),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 93,
              ), // Adds a safe margin at the very bottom
            ],
          ),
        ),
      ),
    );
  }
}
