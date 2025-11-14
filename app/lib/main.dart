import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'engine_api.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AllerVaultApp());
}

class AllerVaultApp extends StatelessWidget {
  const AllerVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AllerVault',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const CameraScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  late Future<void> _initFuture;
  final _engine = EngineApi();

  @override
  void initState() {
    super.initState();
    _initFuture = _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;
    _controller = CameraController(camera, ResolutionPreset.medium, enableAudio: false);
    await _controller!.initialize();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  //On click of "take photo" button
  Future<void> _onSnap() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final file = await _controller!.takePicture();
      if (!mounted) return;
      _showEditor(await _engine.processMealPhoto(file.path));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  //Showing the result you get from engine, ie the name of the meal, ingredients and etc
  void _showEditor(MealAnalysis result) {
    final dishCtrl = TextEditingController(text: result.dish);
    final qtyCtrl = TextEditingController(text: result.quantity);
    final ingCtrl = TextEditingController(text: result.ingredients.join(', '));
    final ingQtyCtrl = TextEditingController(
      text: result.ingredientQuantities
          .map((e) => '${e.name}: ${e.amount} ${e.unit}')
          .join('\n'),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: true,
        initialChildSize: 0.9, // start at 90% of screen height
        minChildSize: 0.5,     // how small it can be dragged
        maxChildSize: 0.95,    // how large it can be dragged
        builder: (_, controller) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: ListView(
            controller: controller,
            children: [
              const Text('Review & Edit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              TextField(decoration: const InputDecoration(labelText: 'Dish'), controller: dishCtrl),
              const SizedBox(height: 8),
              TextField(decoration: const InputDecoration(labelText: 'Quantity'), controller: qtyCtrl),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Ingredients (comma-separated)'),
                controller: ingCtrl,
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Ingredient quantities (one per line: name: amount unit)'),
                controller: ingQtyCtrl,
                maxLines: 5,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  // For now, just dismiss. Later: save to local storage via engine.
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved locally (stub).')),
                  );
                },
                child: const Text('Save'),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AllerVault'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_controller == null || !_controller!.value.isInitialized) {
            return const Center(child: Text('Camera not available'));
          }
          return Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(_controller!),
              if (kIsWeb)
                const Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Web preview requires camera permission in the browser'),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onSnap,
        icon: const Icon(Icons.camera_alt),
        label: const Text('Snap'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

