import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizView extends StatefulWidget {
  final VoidCallback onFinish;

  const QuizView({Key? key, required this.onFinish}) : super(key: key);

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  List<dynamic> questions = [];
  int currentIndex = 0;
  int score = 0;
  bool showResult = false;
  bool loading = true;
  String? selectedOption;
  bool isAnswering = false;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    final String response = await rootBundle.loadString('assets/quiz.json');
    final data = await json.decode(response);
    setState(() {
      questions = data;
      loading = false;
    });
  }

  void _answerQuestion(String selected) async {
    if (isAnswering) return;

    setState(() {
      selectedOption = selected;
      isAnswering = true;
    });

    if (selected == questions[currentIndex]['answer']) {
      score++;
    }

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedOption = null;
        isAnswering = false;
      });
    } else {
      setState(() {
        showResult = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Flexible(
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (showResult) {
      return Flexible(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Quiz Complete!",
                style: GoogleFonts.fredoka(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.yellowAccent,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "You scored $score out of ${questions.length}!",
                style: GoogleFonts.quicksand(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: widget.onFinish,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent,
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    "Back to Story Buddy",
                    style: GoogleFonts.fredoka(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final question = questions[currentIndex];
    final options = List<String>.from(question['options']);

    return Flexible(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Question ${currentIndex + 1}/${questions.length}",
              style: GoogleFonts.quicksand(
                fontSize: 18,
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              question['question'],
              style: GoogleFonts.fredoka(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ...options.map((option) {
              Color bgColor = Colors.white.withOpacity(0.2);
              Color borderColor = Colors.white.withOpacity(0.5);
              Color textColor = Colors.yellowAccent;

              if (isAnswering) {
                if (option == question['answer']) {
                  bgColor = Colors.green.withOpacity(0.8);
                  borderColor = Colors.greenAccent;
                  textColor = Colors.white;
                } else if (option == selectedOption) {
                  bgColor = Colors.red.withOpacity(0.8);
                  borderColor = Colors.redAccent;
                  textColor = Colors.white;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GestureDetector(
                  onTap: () => _answerQuestion(option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor, width: 2),
                    ),
                    child: Text(
                      option,
                      style: GoogleFonts.quicksand(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
