import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StoryPopup extends StatelessWidget {
  final String storyText;

  const StoryPopup({Key? key, required this.storyText}) : super(key: key);

  // A helper method to easily show the dialog from anywhere
  static void show(BuildContext context, String story) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(
        0.2,
      ), // Subtle dark overlay behind the blur
      builder: (context) => StoryPopup(storyText: story),
    );
  }

  @override
  Widget build(BuildContext context) {
    // BackdropFilter blurs the entire screen behind the popup
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
      child: Dialog(
        backgroundColor:
            Colors.transparent, // Makes the default dialog invisible
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            // Semi-transparent white background for Glassmorphism
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(30),
            // Thin, soft white border
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Pip's Magical Tale",
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    storyText,
                    style: GoogleFonts.quicksand(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.6),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    "Close",
                    style: GoogleFonts.fredoka(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
