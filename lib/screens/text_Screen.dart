import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Tesseract OCR',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TextRecognitionPage(),
    );
  }
}

class TextRecognitionPage extends StatefulWidget {
  const TextRecognitionPage({Key? key}) : super(key: key);

  @override
  State<TextRecognitionPage> createState() => _TextRecognitionPageState();
}

class _TextRecognitionPageState extends State<TextRecognitionPage> {
  bool _isLoading = false;
  bool _isSpeaking = false;
  XFile? _pickedImage;
  String _recognizedText = '';
  final ImagePicker _picker = ImagePicker();
  String _detectedLanguage = 'eng'; // Default language
  bool _isAutoDetect = true;
  String _selectedLanguage = 'eng';
  late FlutterTts _flutterTts;

  // Language options
  final Map<String, String> _languages = {
    'eng': 'English',
    'fra': 'French',
    'ara': 'Arabic',
    'auto': 'Auto Detect',
  };

  // TTS language codes (different from Tesseract codes)
  final Map<String, String> _ttsLanguages = {
    'eng': 'en-US',
    'fra': 'fr-FR',
    'ara': 'ar',
  };

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _initTts();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage(_ttsLanguages[_detectedLanguage]!);

    _flutterTts.setStartHandler(() {
      setState(() {
        _isSpeaking = true;
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });

    _flutterTts.setErrorHandler((error) {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  Future<void> _speak(String text) async {
    if (text.isEmpty) return;

    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() {
        _isSpeaking = false;
      });
      return;
    }

    // Set the appropriate language for TTS
    await _flutterTts.setLanguage(_ttsLanguages[_detectedLanguage] ?? 'en-US');
    await _flutterTts.speak(text);
  }

  Future<void> _requestPermissions() async {
    // Request camera and storage permissions
    await [Permission.camera, Permission.storage].request();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _pickedImage = pickedFile;
          _recognizedText = '';
          _isLoading = true;
        });
        await _extractText();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  // More robust language detection
  String _detectLanguage(String text) {
    if (text.isEmpty) return 'eng';

    // Normalize text - convert to lowercase and remove punctuation for better analysis
    String normalizedText = text.toLowerCase().replaceAll(
      RegExp(r'[^\w\s]'),
      '',
    );

    // Count characters in different scripts
    int arabicChars = 0;
    int latinChars = 0;

    // Check for Arabic script (which is distinctive)
    for (int i = 0; i < text.length; i++) {
      int code = text.codeUnitAt(i);

      // Arabic Unicode range
      if (code >= 0x0600 && code <= 0x06FF) {
        arabicChars++;
      }
      // Latin script (includes English and French)
      else if ((code >= 0x0041 && code <= 0x005A) ||
          (code >= 0x0061 && code <= 0x007A) ||
          (code >= 0x00C0 && code <= 0x00FF)) {
        // Include extended Latin for accented chars
        latinChars++;
      }
    }

    // If predominantly Arabic characters, return Arabic
    if (arabicChars > latinChars) {
      return 'ara';
    }

    // For Latin script, differentiate between English and French

    // Common French words that don't exist in English
    List<String> frenchWords = [
      'le',
      'la',
      'les',
      'un',
      'une',
      'des',
      'est',
      'et',
      'ou',
      'où',
      'dans',
      'pour',
      'par',
      'sur',
      'avec',
      'sans',
      'mais',
      'donc',
      'alors',
      'voilà',
      'bonjour',
      'merci',
      'au',
      'aux',
      'du',
      'ce',
      'cette',
      'ces',
      'mon',
      'ton',
      'son',
      'notre',
      'votre',
      'leur',
    ];

    // Common English words that don't exist in French
    List<String> englishWords = [
      'the',
      'and',
      'or',
      'if',
      'of',
      'to',
      'in',
      'is',
      'are',
      'am',
      'was',
      'were',
      'been',
      'have',
      'has',
      'had',
      'will',
      'would',
      'shall',
      'should',
      'can',
      'could',
      'may',
      'might',
      'must',
      'this',
      'that',
      'these',
      'those',
      'it',
      'its',
    ];

    // Count occurrences of language-specific words
    int frenchWordCount = 0;
    int englishWordCount = 0;

    // Split text into words
    List<String> words = normalizedText.split(RegExp(r'\s+'));

    for (String word in words) {
      if (frenchWords.contains(word)) {
        frenchWordCount++;
      }
      if (englishWords.contains(word)) {
        englishWordCount++;
      }
    }

    // Check for French-specific characters
    bool hasFrenchChars = text.contains(
      RegExp(r'[éèêëàâäôöùûüçÉÈÊËÀÂÄÔÖÙÛÜÇ]'),
    );

    // Make decision based on word and character analysis
    if (hasFrenchChars || frenchWordCount > englishWordCount) {
      return 'fra';
    } else {
      return 'eng';
    }
  }

  Future<void> _runMultipleOCR() async {
    // This method runs OCR with multiple languages and compares results
    if (_pickedImage == null) return;

    // First try with all languages to get some text
    final String initialText = await FlutterTesseractOcr.extractText(
      _pickedImage!.path,
      language: 'eng+fra+ara',
    );

    // If we got no text, default to English
    if (initialText.trim().isEmpty) {
      setState(() {
        _detectedLanguage = 'eng';
        _recognizedText = "No text detected";
        _isLoading = false;
      });
      return;
    }

    // Get a preliminary language detection from initial text
    String prelimLanguage = _detectLanguage(initialText);

    // If it's Arabic, we're pretty confident (distinct script)
    if (prelimLanguage == 'ara') {
      final String arabicText = await FlutterTesseractOcr.extractText(
        _pickedImage!.path,
        language: 'ara',
      );
      setState(() {
        _detectedLanguage = 'ara';
        _recognizedText = arabicText;
        _isLoading = false;
      });
      return;
    }

    // For Latin script (English/French), try both and choose the one with better results

    // Try English OCR
    final String englishText = await FlutterTesseractOcr.extractText(
      _pickedImage!.path,
      language: 'eng',
    );

    // Try French OCR
    final String frenchText = await FlutterTesseractOcr.extractText(
      _pickedImage!.path,
      language: 'fra',
    );

    // Decide which result is better
    // 1. Compare text lengths - longer is likely better recognition
    // 2. Check for language-specific patterns in the results

    bool useFrench = false;

    // If French text is significantly longer, probably better recognition
    if (frenchText.length > englishText.length * 1.2) {
      useFrench = true;
    }
    // If lengths are similar, check for language markers
    else if (frenchText.length >= englishText.length * 0.8) {
      String frenchLang = _detectLanguage(frenchText);
      String englishLang = _detectLanguage(englishText);

      // Trust detection on the OCR'd text
      useFrench = frenchLang == 'fra';
    }

    setState(() {
      if (useFrench) {
        _detectedLanguage = 'fra';
        _recognizedText = frenchText;
      } else {
        _detectedLanguage = 'eng';
        _recognizedText = englishText;
      }
      _isLoading = false;
    });
  }

  Future<void> _extractText() async {
    try {
      if (_pickedImage != null) {
        if (_isAutoDetect) {
          await _runMultipleOCR();
        } else {
          // User selected a specific language
          final String text = await FlutterTesseractOcr.extractText(
            _pickedImage!.path,
            language: _selectedLanguage,
          );

          setState(() {
            _detectedLanguage = _selectedLanguage;
            _recognizedText = text;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _recognizedText = 'Error recognizing text: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text Recognition')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Language:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _isAutoDetect ? 'auto' : _selectedLanguage,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 0,
                        ),
                      ),
                      items:
                          _languages.entries.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(entry.value),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          if (value == 'auto') {
                            _isAutoDetect = true;
                          } else {
                            _isAutoDetect = false;
                            _selectedLanguage = value!;
                          }

                          // Re-run OCR if an image is already selected
                          if (_pickedImage != null) {
                            _isLoading = true;
                            _extractText();
                          }
                        });
                      },
                    ),
                    if (_isAutoDetect && _recognizedText.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Detected language: ${_languages[_detectedLanguage] ?? "Unknown"}',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_pickedImage != null) ...[
              Center(
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_pickedImage!.path),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_recognizedText.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recognized Text:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(_isSpeaking ? Icons.stop : Icons.volume_up),
                    onPressed: () => _speak(_recognizedText),
                    tooltip: _isSpeaking ? 'Stop TTS' : 'Read Text',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _recognizedText,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
