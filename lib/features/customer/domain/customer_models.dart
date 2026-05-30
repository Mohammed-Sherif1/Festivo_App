class Category {
  final String label;
  final String emoji;
  const Category({required this.label, required this.emoji});
}

class Venue {
  final String id;
  final String name;
  final String location;
  final String category;
  final String emoji;
  final int price;
  final double rating;
  final int reviews;
  final int capacity;
  final String description;
  final List<String> amenities;

  const Venue({
    required this.id,
    required this.name,
    required this.location,
    required this.category,
    required this.emoji,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.capacity,
    required this.description,
    this.amenities = const [],
  });
}

Venue? venueById(String id) {
  for (final v in kVenues) {
    if (v.id == id) return v;
  }
  return null;
}

const kCategories = <Category>[
  Category(label: 'All', emoji: '🌟'),
  Category(label: 'Wedding', emoji: '💍'),
  Category(label: 'Party', emoji: '🎉'),
  Category(label: 'Graduation', emoji: '🎓'),
  Category(label: 'Corporate', emoji: '🏢'),
  Category(label: 'Birthday', emoji: '🎂'),
];

const kVenues = <Venue>[
  Venue(
    id: 'v1',
    name: 'Grand Crystal Ballroom',
    location: 'Zamalek, Cairo',
    category: 'Wedding',
    emoji: '💎',
    price: 45000,
    rating: 4.8,
    reviews: 210,
    capacity: 600,
    description:
        'An exquisite ballroom in the heart of Zamalek with crystal chandeliers, '
        'premium sound, and full catering support for weddings and galas.',
    amenities: [
      '🅿️ Parking',
      '📶 WiFi',
      '❄️ AC',
      '🎤 Sound System',
      '🍽️ Catering',
      '💡 Lighting',
    ],
  ),
  Venue(
    id: 'v2',
    name: 'Sunset Rooftop Lounge',
    location: 'Zamalek',
    category: 'Party',
    emoji: '🌇',
    price: 18000,
    rating: 4.6,
    reviews: 98,
    capacity: 200,
    description:
        'Rooftop lounge with Nile views, ideal for parties and intimate celebrations.',
    amenities: ['📶 WiFi', '❄️ AC', '🎤 Sound System', '💡 Lighting'],
  ),
  Venue(
    id: 'v3',
    name: 'Cairo Corporate Hub',
    location: 'Nasr City',
    category: 'Corporate',
    emoji: '🏛️',
    price: 25000,
    rating: 4.5,
    reviews: 76,
    capacity: 320,
    description:
        'Modern conference and event space for corporate meetings, launches, and seminars.',
    amenities: ['🅿️ Parking', '📶 WiFi', '❄️ AC', '🎤 Sound System'],
  ),
  Venue(
    id: 'v4',
    name: 'Graduation Hall Plus',
    location: 'Nasr City',
    category: 'Graduation',
    emoji: '🎓',
    price: 14000,
    rating: 4.4,
    reviews: 61,
    capacity: 450,
    description:
        'Spacious hall designed for graduation ceremonies and large student events.',
    amenities: ['🅿️ Parking', '❄️ AC', '🍽️ Catering', '💡 Lighting'],
  ),
];
