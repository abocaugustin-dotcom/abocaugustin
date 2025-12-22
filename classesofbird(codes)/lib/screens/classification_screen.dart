import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/bird_classifier.dart';
import '../services/data_service.dart';
import '../models/bird_class.dart';

class ClassificationScreen extends StatefulWidget {
  const ClassificationScreen({super.key});

  @override
  State<ClassificationScreen> createState() => _ClassificationScreenState();
}

class _ClassificationScreenState extends State<ClassificationScreen> {
  late BirdClassifier _classifier;
  File? _selectedImage;
  Map<String, double>? _predictions;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _classifier = BirdClassifier();
    _initializeClassifier();
  }

  Future<void> _initializeClassifier() async {
    try {
      await _classifier.loadModel();
      await DataService.initialize();
      debugPrint('Model and data service initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize: $e');
      _showErrorDialog('Failed to initialize: $e');
    }
  }

  @override
  void dispose() {
    _classifier.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _predictions = null;
      });
      await _classifyImage();
    }
  }

  Future<void> _captureImage() async {
    try {
      debugPrint('Opening native camera...');
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        debugPrint('Image captured: ${pickedFile.path}');
        setState(() {
          _selectedImage = File(pickedFile.path);
          _predictions = null;
        });
        await _classifyImage();
      } else {
        debugPrint('No image captured');
      }
    } catch (e) {
      debugPrint('Failed to capture image: $e');
      _showErrorDialog('Failed to capture image: $e');
    }
  }

  Future<void> _classifyImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('Starting classification for: ${_selectedImage!.path}');
      final predictions = await _classifier.classifyImage(_selectedImage!.path);
      debugPrint('Classification completed: $predictions');

      final sortedPredictions = Map.fromEntries(
        predictions.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)),
      );

      // Find the top prediction
      final topPrediction = sortedPredictions.entries.first;

      // Save to history
      await DataService.saveClassification(
        imagePath: _selectedImage!.path,
        predictedBird: topPrediction.key,
        confidence: topPrediction.value,
        allPredictions: predictions,
      );

      setState(() {
        _predictions = sortedPredictions;
        _isLoading = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Classified as ${topPrediction.key} with ${(topPrediction.value * 100).toStringAsFixed(1)}% confidence',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Classification failed: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Classification failed: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/img/Gemini_Generated_Image_4h2abv4h2abv4h2a (1).png',
              height: 40,
              width: 40,
            ),
            const SizedBox(width: 10),
            const Text(
              'Bird Classification',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32), // Deep green from logo
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // Background with gradient matching logo colors (same as homepage)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                colors: [
                  const Color(0xFF2E7D32), // Deep green
                  const Color(0xFF1976D2), // Blue
                  const Color(0xFF00ACC1), // Cyan/Teal
                ],
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_selectedImage != null)
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.grey[200],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      ),
                    )
                  else
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.grey[200],
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Tap Camera to take a photo',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _pickImageFromGallery,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Gallery'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF2E7D32,
                            ), // Deep green from logo
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _captureImage,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Camera'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF2E7D32,
                            ), // Deep green from logo
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  if (_isLoading)
                    const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Classifying...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    )
                  else if (_predictions != null && _predictions!.isNotEmpty)
                    _buildPredictionResults()
                  else if (_selectedImage != null)
                    const Center(
                      child: Text(
                        'Tap the Classify button to identify the bird',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Classification Results:',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: _predictions!.entries.map((entry) {
              final birdClass = birdClasses.firstWhere(
                (bird) => bird.name.toLowerCase() == entry.key.toLowerCase(),
                orElse: () => birdClasses[0],
              );

              final confidence = entry.value;
              final confidencePercentage = (confidence * 100).toStringAsFixed(
                1,
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(birdClass.imagePath),
                      radius: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        birdClass.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$confidencePercentage%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: confidence > 0.5
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                        Container(
                          width: 60,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.grey[300],
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: confidence.clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: confidence > 0.5
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
