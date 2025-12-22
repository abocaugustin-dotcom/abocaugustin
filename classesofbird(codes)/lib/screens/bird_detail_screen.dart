import 'package:flutter/material.dart';
import '../models/bird_class.dart';
import 'classification_screen.dart';

class BirdDetailScreen extends StatelessWidget {
  final BirdClass birdClass;

  const BirdDetailScreen({super.key, required this.birdClass});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(birdClass.imagePath, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          birdClass.name,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Class #${birdClass.id}',
                          style: TextStyle(
                            color: Colors.green[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          birdClass.description,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Quick Facts',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildFactCard(
                    'Classification',
                    'Bird Species',
                    Icons.category,
                    Colors.blue,
                  ),

                  const SizedBox(height: 12),

                  _buildFactCard(
                    'Habitat',
                    _getHabitat(birdClass.name),
                    Icons.home,
                    Colors.orange,
                  ),

                  const SizedBox(height: 12),

                  _buildFactCard(
                    'Diet',
                    _getDiet(birdClass.name),
                    Icons.restaurant,
                    Colors.purple,
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ClassificationScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Try Classification'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getHabitat(String birdName) {
    switch (birdName.toLowerCase()) {
      case 'crow':
        return 'Urban areas, forests, farmlands';
      case 'eagle':
        return 'Mountains, coastal areas, open country';
      case 'hummingbird':
        return 'Gardens, forests, meadows';
      case 'owl':
        return 'Forests, woodlands, urban areas';
      case 'parrot':
        return 'Tropical forests, woodlands';
      case 'peacock':
        return 'Forests, farmlands, villages';
      case 'penguin':
        return 'Antarctic regions, coastal areas';
      case 'pigeon':
        return 'Urban areas, cliffs, buildings';
      case 'sparrow':
        return 'Urban areas, farms, forests';
      case 'swan':
        return 'Lakes, rivers, wetlands';
      default:
        return 'Various habitats';
    }
  }

  String _getDiet(String birdName) {
    switch (birdName.toLowerCase()) {
      case 'crow':
        return 'Omnivore - insects, fruits, small animals';
      case 'eagle':
        return 'Carnivore - fish, small mammals, birds';
      case 'hummingbird':
        return 'Nectarivore - flower nectar, small insects';
      case 'owl':
        return 'Carnivore - small mammals, birds, insects';
      case 'parrot':
        return 'Herbivore - seeds, fruits, nuts';
      case 'peacock':
        return 'Omnivore - seeds, insects, small reptiles';
      case 'penguin':
        return 'Carnivore - fish, krill, squid';
      case 'pigeon':
        return 'Herbivore - seeds, grains, fruits';
      case 'sparrow':
        return 'Omnivore - seeds, insects, crumbs';
      case 'swan':
        return 'Herbivore - aquatic plants, algae';
      default:
        return 'Varied diet';
    }
  }
}
