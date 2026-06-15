import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'story_reader.dart';
import 'quiz_view.dart';

class StoryPopup extends ConsumerStatefulWidget {
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
  ConsumerState<StoryPopup> createState() => _StoryPopupState();
}

class _StoryPopupState extends ConsumerState<StoryPopup> {
  bool _showQuiz = false;

  @override
  Widget build(BuildContext context) {
    // Blur the entire screen behind the popup
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        backgroundColor:
            Colors.transparent, // Makes the default dialog invisible
        elevation: 0,
        insetPadding: const EdgeInsets.all(
          12,
        ), // Reduced padding to allow a wider box
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // The Story Box
            Padding(
              padding: const EdgeInsets.only(
                bottom: 120.0,
              ), // Space for the character
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    width: double
                        .infinity, // Stretches the box to max available width
                    constraints: const BoxConstraints(
                      minHeight: 450,
                    ), // Ensures a larger minimum height
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white.withOpacity(0.15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          children: [
                            Text(
                              _showQuiz ? "Quiz Time!" : "Pip's Magical Tale",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.fredoka(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 6
                                  ..color = Colors.deepPurple.shade800,
                              ),
                            ),
                            Text(
                              _showQuiz ? "Quiz Time!" : "Pip's Magical Tale",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.fredoka(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                color: Colors.yellowAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _showQuiz
                            ? QuizView(
                                onFinish: () => Navigator.of(context).pop(),
                              )
                            : StoryReader(
                                storyText: widget.storyText,
                                onClose: () => Navigator.of(context).pop(),
                                onQuiz: () => setState(() => _showQuiz = true),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // The character pointing at the story
            Positioned(
              bottom: 0,
              right: -50, // Moved a little to the right
              child: Image.asset(
                'assets/recite.png',
                width: 220, // Adjust size as needed to fit well
              ),
            ),
          ],
        ),
      ),
    );
  }
}
