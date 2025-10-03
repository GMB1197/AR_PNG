import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR Painting',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key}); // <-- key aggiunta

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late ARKitController arkitController;

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('ARKit in Flutter')),
    body: ARKitSceneView(
      enableTapRecognizer: true,
      onARKitViewCreated: onARKitViewCreated,
    ),
  );

  void onARKitViewCreated(ARKitController c) async {
    arkitController = c;

    // Mantieni il rapporto d’aspetto del PNG
    final wh = await _imageAspect('images/painting.png');
    const targetWidth = 0.4; // metri
    final targetHeight = targetWidth * (wh.y / wh.x);

    final node = ARKitNode(
      name: 'painting',
      geometry: ARKitPlane(
        width: targetWidth,
        height: targetHeight,
        materials: [
          ARKitMaterial(
            diffuse: ARKitMaterialProperty.image('images/painting.png'),
            doubleSided: true,
          ),
        ],
      ),
      position: vector.Vector3(0, 0, -0.5),
    );

    arkitController.add(node);
    arkitController.onNodeTap = (nodes) => onNodeTapHandler(nodes);
  }

  // >>> Funzione mancante che calcola w,h dell’immagine asset
  Future<vector.Vector2> _imageAspect(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return vector.Vector2(
      frame.image.width.toDouble(),
      frame.image.height.toDouble(),
    );
  }

  void onNodeTapHandler(List<String> nodesList) {
    final name = nodesList.isNotEmpty ? nodesList.first : 'node';
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(content: Text('You tapped on $name')),
    );
  }
}
