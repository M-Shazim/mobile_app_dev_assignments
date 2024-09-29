import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(DiceApp());

class DiceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dice Roller',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: DiceScreen(),
    );
  }
}

class DiceScreen extends StatefulWidget {
  @override
  _DiceScreenState createState() => _DiceScreenState();
}

class _DiceScreenState extends State<DiceScreen> {
  int _diceNumber1 = 0;
  int totalRounds = 1;
  int currentPlayer = 1;
  int player1Score = 0;
  int player2Score = 0;
  int player3Score = 0;
  int player4Score = 0;
  String winnerMessage = "";

  void _determineWinner() {
    List<int> scores = [player1Score, player2Score, player3Score, player4Score];
    int highestScore = scores.reduce(max);

    int count = scores.where((score) => score == highestScore).length;

    if (count > 1) {
      winnerMessage = "It's a Draw!";
    } else if (highestScore == player1Score) {
      winnerMessage = "Player 1 Wins!";
    } else if (highestScore == player2Score) {
      winnerMessage = "Player 2 Wins!";
    } else if (highestScore == player3Score) {
      winnerMessage = "Player 3 Wins!";
    } else {
      winnerMessage = "Player 4 Wins!";
    }
  }

  void _rollDice() {
    setState(() {
      if (totalRounds > 0) {
        _diceNumber1 = Random().nextInt(6) + 1;

        if (currentPlayer == 1) {
          player1Score += _diceNumber1;
          currentPlayer = 2;
        } else if (currentPlayer == 2) {
          player2Score += _diceNumber1;
          currentPlayer = 3;
        } else if (currentPlayer == 3) {
          player3Score += _diceNumber1;
          currentPlayer = 4;
        } else if (currentPlayer == 4) {
          player4Score += _diceNumber1;
          currentPlayer = 1;
          totalRounds--;
        }
      }

      if (totalRounds == 0) {
        _determineWinner();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dice Roller Game'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDiceSection(),
            SizedBox(height: 30),
            _buildPlayerScores(),
            SizedBox(height: 30),
            _buildWinnerMessage(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiceSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDiceColumn(
          'Remaining Rounds: $totalRounds',
          'Rolled Number: $_diceNumber1',
          'images/dice-$_diceNumber1.png',
          _rollDice,
        ),
        SizedBox(width: 50),
        Column(
          children: [
            Text(
              "Current Player: Player $currentPlayer",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayerScores() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildPlayerCard('Player 1', player1Score),
        _buildPlayerCard('Player 2', player2Score),
        _buildPlayerCard('Player 3', player3Score),
        _buildPlayerCard('Player 4', player4Score),
      ],
    );
  }

  Widget _buildPlayerCard(String playerName, int score) {
    return Column(
      children: [
        Text(
          playerName,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text(
          "$score",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildWinnerMessage() {
    return totalRounds == 0
        ? Text(
      winnerMessage,
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    )
        : Container();
  }

  Widget _buildDiceColumn(
      String text1, String text, String imagePath, VoidCallback onPressed) {
    return Column(
      children: [
        Text(
          text1,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          text,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Image.asset(
          imagePath,
          height: 100,
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: onPressed,
          child: Text('Roll the Dice'),
        ),
      ],
    );
  }
}


