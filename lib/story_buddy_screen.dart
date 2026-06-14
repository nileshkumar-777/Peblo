import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'story_popup.dart';

class StoryBuddyScreen extends StatelessWidget {
  const StoryBuddyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  StoryPopup.show(
                    context,
                    "Once upon a time in a magical land, a friendly little robot named Pip discovered a glowing book hidden under an ancient tree.\n\nWhen Pip opened the book, the pages fluttered, and magical stories began to fly out like colorful butterflies! Pip invites you to catch one of these stories and embark on a wondrous adventure filled with new friends, exciting challenges, and happy endings.\n\nAre you ready to explore the magic?",
                  );
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
