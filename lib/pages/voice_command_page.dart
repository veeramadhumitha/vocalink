import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import '../services/command_handler.dart';

class VoiceCommandPage extends StatefulWidget {
  const VoiceCommandPage({super.key});

  @override
  State<VoiceCommandPage> createState() => _VoiceCommandPageState();
}

class _VoiceCommandPageState extends State<VoiceCommandPage>
    with SingleTickerProviderStateMixin {
  final SpeechService _speechService = SpeechService();
  final TTSService _ttsService = TTSService();
  late CommandHandler _commandHandler;

  bool _isListening = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _commandHandler = CommandHandler(updateUI, _ttsService);
    _initializeApp();
  }

  void updateUI(String newText) {
    setState(() => _lastWords = newText);
  }

  Future<void> _initializeApp() async {
    await _ttsService.init();
    await _ttsService.speak("Welcome to VocaLink. Tap the mic and say a command.");

    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.contacts,
      Permission.phone,
      Permission.camera,
    ].request();

    if (statuses.values.any((status) => status.isDenied)) {
      await _ttsService.speak("Please grant all permissions to use voice commands.");
    }
  }

  void _startListening() async {
    if (_isListening) return;
    bool available = await _speechService.init();
    if (available) {
      setState(() => _isListening = true);
      _speechService.listen((words) {
        setState(() => _lastWords = words);
        _commandHandler.handle(words.toLowerCase());
      });
    } else {
      await _ttsService.speak("Microphone not available or permission denied.");
    }
  }

  void _stopListening() {
    _speechService.stop();
    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff35c5b3), Color(0xff81e424)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'VocaLink',
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn().slideY(begin: -0.5),
              const SizedBox(height: 40),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening ? Colors.red[100] : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: Icon(
                  Icons.mic,
                  size: 80,
                  color: _isListening ? Colors.red : Colors.indigo,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scaleXY(
                begin: 0.9,
                end: 1.1,
                duration: 600.ms,
                curve: Curves.easeInOut,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: size.width * 0.8,
                child: _lastWords.isEmpty
                    ? AnimatedTextKit(
                  repeatForever: false,
                  isRepeatingAnimation: false,
                  animatedTexts: [
                    TyperAnimatedText(
                      'Say a command like “Call Appa”, “Open Camera”, or “What time is it”…',
                      textStyle: const TextStyle(fontSize: 20, color: Colors.white),
                      speed: const Duration(milliseconds: 60),
                    )
                  ],
                )
                    : Text(
                  _lastWords,
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _isListening ? _stopListening : _startListening,
                icon: Icon(_isListening ? Icons.stop : Icons.mic),
                label: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
