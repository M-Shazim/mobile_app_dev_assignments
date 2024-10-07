import 'package:flutter/material.dart';
import 'dart:async'; // Import this for Timer

import 'quiz_brain.dart';

QuizBrain quizBrain = QuizBrain();

void main() => runApp(QuizApp());

class QuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: QuizPage(),
    );
  }
}

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Icon> scoreKeeper = [];
  int score = 0;
  bool isQuizStarted = false;
  int timer = 10;
  Timer? countdownTimer; // Add a Timer object to control the countdown

  void checkAnswer(bool userPickedAnswer) {
    bool correctAnswer = quizBrain.getAnswer();
    setState(() {
      // Cancel the timer when an answer is checked
      countdownTimer?.cancel();

      if (correctAnswer == userPickedAnswer) {
        scoreKeeper.add(Icon(Icons.check, color: Colors.green));
        score++;
      } else {
        scoreKeeper.add(Icon(Icons.close, color: Colors.red));
      }

      if (quizBrain.isFinished()) {
        showResult();
      } else {
        quizBrain.nextQuestion();
        resetTimer(); // Reset the timer for the next question
      }
    });
  }

  void startQuiz() {
    setState(() {
      isQuizStarted = true;
      resetTimer(); // Start the timer when the quiz starts
    });
  }

  void resetTimer() {
    setState(() {
      timer = 10; // Reset timer to 10 seconds
    });
    countdownTimer?.cancel(); // Cancel any existing timers
    countdownTimer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        if (timer > 0) {
          timer--;
        } else {
          countdownTimer?.cancel();
          checkAnswer(false); // Automatically call checkAnswer with false if time runs out
        }
      });
    });
  }

  void showResult() {
    countdownTimer?.cancel(); // Stop the timer when the quiz ends
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Quiz Completed!"),
          content: Text("Your score is $score/10"),
          actions: [
            TextButton(
              child: Text("Restart"),
              onPressed: () {
                setState(() {
                  quizBrain.reset();
                  scoreKeeper.clear();
                  score = 0;
                  timer = 10;
                  isQuizStarted = false;
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: isQuizStarted
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Time Left: $timer seconds',
              style: TextStyle(fontSize: 20.0),
            ),
            Expanded(
              child: Center(
                child: Text(
                  quizBrain.getQuestion(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25.0),
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      child: Text('True'),
                      onPressed: () {
                        checkAnswer(true);
                      },
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      child: Text('False'),
                      onPressed: () {
                        checkAnswer(false);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: scoreKeeper,
            ),
          ],
        )
            : Center(
          child: ElevatedButton(
            onPressed: startQuiz,
            child: Text('Start Quiz'),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    countdownTimer?.cancel(); // Make sure to cancel the timer when disposing the widget
    super.dispose();
  }
}
