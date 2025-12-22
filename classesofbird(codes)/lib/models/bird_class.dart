class BirdClass {
  final int id;
  final String name;
  final String imagePath;
  final String description;

  BirdClass({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.description,
  });
}

final List<BirdClass> birdClasses = [
  BirdClass(
    id: 0,
    name: 'Crow',
    imagePath: 'assets/img/Crow.jpeg',
    description: 'Intelligent black birds known for their problem-solving abilities and distinctive cawing sound.',
  ),
  BirdClass(
    id: 1,
    name: 'Eagle',
    imagePath: 'assets/img/Eagle.jpeg',
    description: 'Powerful birds of prey with excellent vision, symbolizing strength and freedom.',
  ),
  BirdClass(
    id: 2,
    name: 'Hummingbird',
    imagePath: 'assets/img/Hummingbird.jpg',
    description: 'Tiny birds capable of hovering in flight, known for their rapid wing beats and iridescent colors.',
  ),
  BirdClass(
    id: 3,
    name: 'Owl',
    imagePath: 'assets/img/Owl.jpeg',
    description: 'Nocturnal birds of prey with large eyes and the ability to rotate their heads significantly.',
  ),
  BirdClass(
    id: 4,
    name: 'Parrot',
    imagePath: 'assets/img/Parrot.jpeg',
    description: 'Colorful tropical birds known for their intelligence and ability to mimic human speech.',
  ),
  BirdClass(
    id: 5,
    name: 'Peacock',
    imagePath: 'assets/img/Peacock.jpeg',
    description: 'Large pheasants known for the male\'s spectacular tail feathers used in courtship displays.',
  ),
  BirdClass(
    id: 6,
    name: 'Penguin',
    imagePath: 'assets/img/Penguin.jpeg',
    description: 'Flightless aquatic birds adapted for life in the water, known for their distinctive waddle.',
  ),
  BirdClass(
    id: 7,
    name: 'Pigeon',
    imagePath: 'assets/img/Pigeon.jpeg',
    description: 'Common urban birds found worldwide, known for their homing abilities and cooing sounds.',
  ),
  BirdClass(
    id: 8,
    name: 'Sparrow',
    imagePath: 'assets/img/Sparrow.jpeg',
    description: 'Small, plump brown birds commonly found in urban and rural areas worldwide.',
  ),
  BirdClass(
    id: 9,
    name: 'Swan',
    imagePath: 'assets/img/Swan.jpeg',
    description: 'Elegant waterfowl known for their long necks and graceful swimming, symbolizing beauty and grace.',
  ),
];
