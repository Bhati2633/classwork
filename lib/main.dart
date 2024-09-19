import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
  ));
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "Your Pet";
  int happinessLevel = 50;
  int hungerLevel = 50;
  Timer? hungerTimer;
  Timer? gameTimer;
  Timer? countdownTimer;
  bool isGameOver = false;
  int countdownTime = 50; // Countdown time in seconds
  TextEditingController _nameController = TextEditingController();
  int gameDuration = 180; // Game duration in seconds

  @override
  void initState() {
    super.initState();
    startGameTimer();
    startCountdownTimer();
    hungerTimer = Timer.periodic(Duration(seconds: 30), (Timer t) {
      setState(() {
        hungerLevel = (hungerLevel + 5).clamp(0, 100);
        _updateHappiness();
        _checkLossCondition();
      });
    });
  }

  void startCountdownTimer() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        if (countdownTime > 0) {
          countdownTime--;
        } else {
          countdownTimer?.cancel();
          endGame();
        }
      });
    });
  }

  void startGameTimer() {
    gameTimer = Timer(Duration(seconds: gameDuration), () {
      endGame();
    });
  }

  void endGame() {
    setState(() {
      isGameOver = true;
    });

    if (happinessLevel > 80) {
      _showGameResultDialog('You Win!');
    } else {
      _showGameResultDialog('Game Over You Loss');
    }
  }

  void _playWithPet() {
    if (!isGameOver) {
      setState(() {
        happinessLevel = (happinessLevel + 10).clamp(0, 100);
        _updateHunger();
        _checkLossCondition();
      });
    }
  }

  void _feedPet() {
    if (!isGameOver) {
      setState(() {
        hungerLevel = (hungerLevel - 10).clamp(0, 100);
        _updateHappiness();
        _checkLossCondition();
      });
    }
  }

  void _updateHappiness() {
    // Happiness decreases as hunger increases
    happinessLevel = (100 - hungerLevel).clamp(0, 100);
  }

  void _updateHunger() {
    // Adjust hunger level based on actions
    hungerLevel = (hungerLevel + 5).clamp(0, 100);
  }

  void _checkLossCondition() {
    if (hungerLevel >= 100 && happinessLevel <= 10) {
      endGame();
    }
  }

  String _getPetMood() {
    if (happinessLevel > 70) {
      return "Happy";
    } else if (happinessLevel >= 30 && happinessLevel <= 70) {
      return "Neutral";
    } else {
      return "Unhappy";
    }
  }

  String _getPetImage() {
    if (happinessLevel > 70) {
      return 'assets/images/pet1.png';
    } else if (happinessLevel >= 30 && happinessLevel <= 70) {
      return 'assets/images/pet2.png';
    } else {
      return 'assets/images/pet3.png';
    }
  }

  Color _getButtonColor() {
    if (happinessLevel > 70) {
      return Colors.green; // Green for Happy
    } else if (happinessLevel >= 30 && happinessLevel <= 70) {
      return Colors.yellow; // Yellow for Neutral
    } else {
      return Colors.red; // Red for Unhappy
    }
  }

  void _showGameResultDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: Text('Restart'),
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      happinessLevel = 50;
      hungerLevel = 50;
      isGameOver = false;
      countdownTime = 50; // Reset countdown timer
      gameTimer?.cancel();
      startGameTimer();
      hungerTimer?.cancel();
      startCountdownTimer();
      hungerTimer = Timer.periodic(Duration(seconds: 30), (Timer t) {
        setState(() {
          hungerLevel = (hungerLevel + 5).clamp(0, 100);
          _updateHappiness();
          _checkLossCondition();
        });
      });
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    hungerTimer?.cancel();
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Pet'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Pet Name Customization
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Enter Pet Name',
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    petName = _nameController.text.isEmpty ? "Your Pet" : _nameController.text;
                  });
                },
                child: Text('Set Pet Name'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // Button background color
                  foregroundColor: Colors.white, // Button text color
                ),
              ),
              SizedBox(height: 16.0),

              // Display Pet Information
              Text(
                'Name: $petName',
                style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.all(20),
                child: Text(
                  'Happiness Level: $happinessLevel',
                  style: TextStyle(fontSize: 22.0, color: Colors.white),
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.all(20),
                child: Text(
                  'Hunger Level: $hungerLevel',
                  style: TextStyle(fontSize: 22.0, color: Colors.white),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Mood: ${_getPetMood()}',
                style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              Text(
                'Countdown: ${countdownTime}s',
                style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.red),
              ),
              SizedBox(height: 32.0),

              // Display Pet Image with Transparency
              Opacity(
                opacity: 0.8, // Adjust opacity here
                child: Image.asset(
                  _getPetImage(), // Use the method to get the image
                  width: 100,
                  height: 100,
                ),
              ),
              SizedBox(height: 32.0),

              // Buttons to interact with pet
              ElevatedButton(
                onPressed: _playWithPet,
                child: Text('Play with Your Pet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getButtonColor(), // Set button color based on mood
                  foregroundColor: Colors.white, // Button text color
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _feedPet,
                child: Text('Feed Your Pet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getButtonColor(), // Set button color based on mood
                  foregroundColor: Colors.white, // Button text color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
