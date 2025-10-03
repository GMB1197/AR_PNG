import 'dart:async';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR Museum',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ARMuseumPage(),
    );
  }
}

class ARMuseumPage extends StatefulWidget {
  const ARMuseumPage({super.key});

  @override
  State<ARMuseumPage> createState() => _ARMuseumPageState();
}

class _ARMuseumPageState extends State<ARMuseumPage> {
  late ARKitController arkitController;
  String? selectedPaintingKey;
  final Set<String> placedPaintings = {};

  final Map<String, PaintingInfo> paintings = {
    'mona_lisa': PaintingInfo(
      title: 'Mona Lisa',
      artist: 'Leonardo da Vinci',
      year: '1503-1519',
      description: 'La Gioconda è uno dei dipinti più famosi al mondo, '
          'noto per il suo enigmatico sorriso.',
      museum: 'Museo del Louvre, Parigi',
      imagePath: 'images/mona_lisa.jpg',
    ),
    'starry_night': PaintingInfo(
      title: 'Notte Stellata',
      artist: 'Vincent van Gogh',
      year: '1889',
      description: 'Un\'opera iconica del post-impressionismo che raffigura '
          'un cielo notturno vorticoso sopra un villaggio.',
      museum: 'Museum of Modern Art, New York',
      imagePath: 'images/starry_night.jpg',
    ),
    'the_scream': PaintingInfo(
      title: "L'Urlo",
      artist: 'Edvard Munch',
      year: '1893',
      description: 'Un\'opera espressionista che rappresenta l\'ansia '
          'e l\'angoscia esistenziale.',
      museum: 'Galleria Nazionale, Oslo',
      imagePath: 'images/the_scream.jpg',
    ),
    'girl_with_pearl': PaintingInfo(
      title: 'Ragazza con l\'Orecchino di Perla',
      artist: 'Johannes Vermeer',
      year: '1665',
      description: 'Conosciuta come la "Monna Lisa del Nord", '
          'è famosa per lo sguardo diretto della ragazza.',
      museum: 'Mauritshuis, L\'Aia',
      imagePath: 'images/girl_with_pearl.jpg',
    ),
  };

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  void _resetGallery() {
    for (final key in placedPaintings) {
      try {
        arkitController.remove(key);
      } catch (e) {
        debugPrint('Errore rimozione: $e');
      }
    }
    setState(() {
      placedPaintings.clear();
      selectedPaintingKey = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final PaintingInfo? currentPainting = selectedPaintingKey != null
        ? paintings[selectedPaintingKey]
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Museum'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (placedPaintings.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reset galleria',
              onPressed: _resetGallery,
            ),
        ],
      ),
      body: Stack(
        children: [
          if (Theme.of(context).platform == TargetPlatform.iOS)
            ARKitSceneView(
              enableTapRecognizer: true,
              planeDetection: ARPlaneDetection.horizontalAndVertical,
              onARKitViewCreated: onARKitViewCreated,
            )
          else
            Container(
              color: Colors.black,
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'AR disponibile solo su iOS reale',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),

          if (Theme.of(context).platform == TargetPlatform.iOS &&
              placedPaintings.length < 4)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Tocca una superficie per posizionare un quadro\n'
                      '(${placedPaintings.length}/4 posizionati)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          if (currentPainting != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildPaintingInfoCard(currentPainting),
            ),
        ],
      ),
    );
  }

  Widget _buildPaintingInfoCard(PaintingInfo info) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.palette, color: Colors.deepPurple, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  info.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    selectedPaintingKey = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.person, 'Artista', info.artist),
          _buildInfoRow(Icons.calendar_today, 'Anno', info.year),
          _buildInfoRow(Icons.museum, 'Museo', info.museum),
          const SizedBox(height: 12),
          Text(
            info.description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    this.arkitController.onARTap = _onARTap;
    this.arkitController.onNodeTap = _onNodeTap;
  }

  void _onNodeTap(List<String> nodeNames) {
    if (nodeNames.isEmpty) return;

    final tappedNode = nodeNames.first;
    if (paintings.containsKey(tappedNode)) {
      debugPrint('Quadro toccato: $tappedNode');
      setState(() {
        selectedPaintingKey = tappedNode;
      });
    }
  }

  void _onARTap(List<ARKitTestResult> results) {
    if (placedPaintings.length >= 4) {
      debugPrint('Tutti i quadri già posizionati');
      return;
    }

    final filteredResults = results
        .where((r) =>
    r.type == ARKitHitTestResultType.existingPlaneUsingExtent ||
        r.type == ARKitHitTestResultType.existingPlane)
        .toList();

    if (filteredResults.isEmpty) {
      debugPrint('Nessuna superficie rilevata');
      return;
    }

    final hit = filteredResults.first;
    final paintingKeys = paintings.keys.toList();
    final paintingKey = paintingKeys[placedPaintings.length];
    final painting = paintings[paintingKey]!;

    debugPrint('Posiziono quadro: ${painting.title}');

    _addPaintingFrame(
      hit.worldTransform,
      paintingKey,
      painting.imagePath,
    );

    setState(() {
      placedPaintings.add(paintingKey);
    });
  }

  void _addPaintingFrame(
      vector.Matrix4 transform,
      String paintingKey,
      String imagePath,
      ) {
    final position = vector.Vector3(
      transform.getTranslation().x,
      transform.getTranslation().y,
      transform.getTranslation().z,
    );

    final material = ARKitMaterial(
      lightingModelName: ARKitLightingModel.lambert,
      diffuse: ARKitMaterialProperty.image(imagePath),
      doubleSided: true,
    );

    final plane = ARKitPlane(
      width: 0.3,
      height: 0.4,
      materials: [material],
    );

    final node = ARKitNode(
      name: paintingKey,
      geometry: plane,
      position: position,
    );

    arkitController.add(node);
  }
}

class PaintingInfo {
  final String title;
  final String artist;
  final String year;
  final String description;
  final String museum;
  final String imagePath;

  PaintingInfo({
    required this.title,
    required this.artist,
    required this.year,
    required this.description,
    required this.museum,
    required this.imagePath,
  });
}