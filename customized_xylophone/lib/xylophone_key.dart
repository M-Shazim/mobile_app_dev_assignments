import 'package:flutter/material.dart';
import 'sound_manager.dart';

class XylophoneKey extends StatefulWidget {
  final Color color;
  final int soundNumber;
  final SoundManager soundManager;

  XylophoneKey({
    required this.color,
    required this.soundNumber,
    required this.soundManager,
  });

  @override
  _XylophoneKeyState createState() => _XylophoneKeyState();
}

class _XylophoneKeyState extends State<XylophoneKey> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize the AnimationController and Animation
    _controller = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _playSound() {
    widget.soundManager.playSound(widget.soundNumber);
    _controller.forward().then((_) {
      // Reset animation after a short delay
      Future.delayed(Duration(milliseconds: 100), () {
        _controller.reverse();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: _playSound,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30), bottom: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Center(
              child: Text(
                'Current Sound: ${widget.soundNumber}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
