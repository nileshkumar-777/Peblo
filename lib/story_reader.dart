import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

class StoryReader extends StatefulWidget {
  final String storyText;
  final VoidCallback onClose;
  final VoidCallback onQuiz;

  const StoryReader({
    Key? key,
    required this.storyText,
    required this.onClose,
    required this.onQuiz,
  }) : super(key: key);

  @override
  State<StoryReader> createState() => _StoryReaderState();
}

class _StoryReaderState extends State<StoryReader> {
  late FlutterTts flutterTts;
  bool isPlaying = false;
  int currentWordStart = 0;
  int currentWordEnd = 0;
  final ScrollController _scrollController = ScrollController();
  Timer? _windowsFakeTimer;
  List<RegExpMatch> _wordMatches = [];
  int _currentMatchIndex = 0;
  bool hasFinishedReading = false;

  @override
  void initState() {
    super.initState();
    initTts();
    // Pre-calculate words for the Windows-only fake timer
    if (!kIsWeb && Platform.isWindows) {
      _wordMatches = RegExp(r'\S+').allMatches(widget.storyText).toList();
    }
  }

  Future<void> initTts() async {
    flutterTts = FlutterTts();
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.setLanguage(
      "en-US",
    ); // Enforce English to prevent silent failures

    flutterTts.setStartHandler(() {
      if (mounted) {
        setState(() => isPlaying = true);
      }
    });

    flutterTts.setCompletionHandler(() {
      if (mounted) {
        _windowsFakeTimer?.cancel();
        setState(() {
          isPlaying = false;
          currentWordStart = 0;
          currentWordEnd = 0;
          hasFinishedReading = true; // Unlocks the quiz when the story ends!
        });
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        }
      }
    });

    flutterTts.setCancelHandler(() {
      if (mounted) {
        _windowsFakeTimer?.cancel();
        setState(() {
          isPlaying = false;
          currentWordStart = 0;
          currentWordEnd = 0;
        });
      }
    });

    // This handles tracking the current word and auto-scrolling
    flutterTts.setProgressHandler((
      String text,
      int startOffset,
      int endOffset,
      String word,
    ) {
      if (mounted) {
        setState(() {
          // FIX: Mobile TTS splits long text into sentence chunks.
          // The 'startOffset' and 'endOffset' are relative to the chunk,
          // so we must find where the chunk starts in the main story!
          int chunkIndex = widget.storyText.indexOf(text);

          if (chunkIndex == -1) {
            // Fallback if the TTS engine slightly modified/trimmed the chunk
            chunkIndex = widget.storyText.indexOf(text.trim());
          }

          if (chunkIndex >= 0) {
            currentWordStart = chunkIndex + startOffset;
            currentWordEnd = chunkIndex + endOffset;
          } else {
            // Extreme fallback
            currentWordStart = startOffset;
            currentWordEnd = endOffset;
          }
        });

        if (_scrollController.hasClients) {
          // Use the middle of the word for true centering
          final double progress =
              (currentWordStart + currentWordEnd) / 2 / widget.storyText.length;
          _scrollToCurrentWord(progress);
        }
      }
    });
  }

  @override
  void dispose() {
    _windowsFakeTimer?.cancel();
    flutterTts.stop();
    _scrollController.dispose();
    super.dispose();
  }

  // Helper to elegantly center the current word on the screen instead of pushing it to the top
  void _scrollToCurrentWord(double progress) {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final double viewportHeight = position.viewportDimension;
    final double totalHeight = position.maxScrollExtent + viewportHeight;

    // Approximate pixel position of the word being spoken
    final double wordPixelPosition = totalHeight * progress;

    // Subtract half of the viewport height to keep the text perfectly centered!
    final double targetScroll = wordPixelPosition - (viewportHeight / 2);

    _scrollController.animateTo(
      targetScroll.clamp(0.0, position.maxScrollExtent),
      duration: const Duration(
        milliseconds: 250,
      ), // Keeps the scroll tightly synced with the words
      curve: Curves
          .linear, // Linear is required for continuous scrolling so it doesn't "stutter" on every word
    );
  }

  Future<void> _speak() async {
    setState(() => isPlaying = true); // Instantly update UI on tap
    await flutterTts.setVolume(1.0); // Force maximum volume
    await flutterTts.setSpeechRate(0.45); // Kid-friendly speed
    await flutterTts.setPitch(1.1);

    // FAKE TIMER FOR WINDOWS (Native Windows TTS does not fire progress events)
    if (!kIsWeb && Platform.isWindows) {
      _windowsFakeTimer?.cancel();
      _currentMatchIndex = 0;
      _windowsFakeTimer = Timer.periodic(const Duration(milliseconds: 350), (
        timer,
      ) {
        if (!mounted || !isPlaying) {
          timer.cancel();
          return;
        }
        if (_currentMatchIndex < _wordMatches.length) {
          setState(() {
            currentWordStart = _wordMatches[_currentMatchIndex].start;
            currentWordEnd = _wordMatches[_currentMatchIndex].end;
          });

          if (_scrollController.hasClients) {
            // Use the middle of the word for true centering
            final double progress =
                (currentWordStart + currentWordEnd) /
                2 /
                widget.storyText.length;
            _scrollToCurrentWord(progress);
          }
          _currentMatchIndex++;
        } else {
          timer.cancel();
          if (mounted) {
            setState(() {
              isPlaying = false;
              currentWordStart = 0;
              currentWordEnd = 0;
              hasFinishedReading =
                  true; // Unlocks the quiz for the Windows fake timer
            });
          }
        }
      });
    }

    await flutterTts.speak(widget.storyText);
  }

  Future<void> _stop() async {
    _windowsFakeTimer?.cancel();
    await flutterTts.stop();
    if (mounted) {
      setState(() {
        isPlaying = false;
        currentWordStart = 0;
        currentWordEnd = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int start = currentWordStart.clamp(0, widget.storyText.length);
    int end = currentWordEnd.clamp(0, widget.storyText.length);
    if (start > end) {
      int temp = start;
      start = end;
      end = temp;
    }

    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.quicksand(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text: widget.storyText.substring(0, start),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                      ), // Softly fades out text that has already been read
                    ),
                    TextSpan(
                      text: widget.storyText.substring(start, end),
                      style: const TextStyle(
                        color: Color(
                          0xFFFFF176,
                        ), // Bright, magical pastel yellow
                        shadows: [
                          // Outer magical glow
                          Shadow(color: Color(0xFFFF9100), blurRadius: 15),
                          // Subtle 3D depth instead of an ugly background box
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    TextSpan(
                      text: widget.storyText.substring(end),
                      style: const TextStyle(
                        color: Colors.white,
                      ), // Keeps unread text bright white
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              if (!hasFinishedReading) ...[
                // Play/Stop Button
                GestureDetector(
                  onTap: isPlaying ? _stop : _speak,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isPlaying
                          ? Colors.pinkAccent.withOpacity(0.8)
                          : Colors.greenAccent.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.6),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPlaying
                              ? Icons.stop_rounded
                              : Icons.volume_up_rounded,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isPlaying ? "Stop" : "Read",
                          style: GoogleFonts.fredoka(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Small Skip Button
                GestureDetector(
                  onTap: () {
                    _stop();
                    widget.onQuiz();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.skip_next_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ] else
                // Quiz Button
                GestureDetector(
                  onTap: () {
                    _stop();
                    widget.onQuiz();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.6),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.help_outline_rounded,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Quiz Time!",
                          style: GoogleFonts.fredoka(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Close Button
              GestureDetector(
                onTap: () {
                  _stop();
                  widget.onClose();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
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
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
