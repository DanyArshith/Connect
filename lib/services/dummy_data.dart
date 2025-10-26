import '../models/business_model.dart';

class DummyData {
  static List<Business> getSampleBusinesses() {
    return [
      Business(
        id: '1',
        ownerId: 'owner1',
        name: 'Perfect Stitch Tailoring',
        category: 'Tailor',
        location: 'Downtown',
        description:
            'Professional tailoring services for men and women. Custom suits, alterations, and repairs. Over 10 years of experience.',
        contact: '+1234567890',
        imageUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        rating: 4.8,
        reviewCount: 25,
      ),
      Business(
        id: '2',
        ownerId: 'owner2',
        name: 'Math Master Tutoring',
        category: 'Tutor',
        location: 'University District',
        description:
            'Expert math tutoring for high school and college students. Specializing in calculus, algebra, and statistics.',
        contact: '+1234567891',
        imageUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        rating: 4.9,
        reviewCount: 18,
      ),
      Business(
        id: '3',
        ownerId: 'owner3',
        name: 'Grandma\'s Kitchen',
        category: 'Food & Catering',
        location: 'Old Town',
        description:
            'Homemade meals and catering services. Traditional recipes passed down through generations. Fresh ingredients daily.',
        contact: '+1234567892',
        imageUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        rating: 4.7,
        reviewCount: 32,
      ),
      Business(
        id: '4',
        ownerId: 'owner4',
        name: 'Corner Store Essentials',
        category: 'Local Shop',
        location: 'Residential Area',
        description:
            'Your neighborhood convenience store. Fresh groceries, household items, and daily essentials. Open 7 days a week.',
        contact: '+1234567893',
        imageUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        rating: 4.5,
        reviewCount: 15,
      ),
      Business(
        id: '5',
        ownerId: 'owner5',
        name: 'Fix-It-All Repairs',
        category: 'Repair Services',
        location: 'Industrial Zone',
        description:
            'Professional repair services for electronics, appliances, and small machinery. Quick turnaround and fair pricing.',
        contact: '+1234567894',
        imageUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        rating: 4.6,
        reviewCount: 22,
      ),
      Business(
        id: '6',
        ownerId: 'owner6',
        name: 'Beauty & Bliss Salon',
        category: 'Beauty & Wellness',
        location: 'Shopping District',
        description:
            'Full-service beauty salon offering haircuts, styling, coloring, and spa treatments. Licensed professionals.',
        contact: '+1234567895',
        imageUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        rating: 4.8,
        reviewCount: 28,
      ),
      Business(
        id: '7',
        ownerId: 'owner7',
        name: 'Home Helper Services',
        category: 'Home Services',
        location: 'Suburbs',
        description:
            'Complete home maintenance and cleaning services. Plumbing, electrical, cleaning, and general repairs.',
        contact: '+1234567896',
        imageUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        rating: 4.7,
        reviewCount: 19,
      ),
      Business(
        id: '8',
        ownerId: 'owner8',
        name: 'City Taxi Service',
        category: 'Transportation',
        location: 'City Center',
        description:
            'Reliable taxi service for local and long-distance travel. Professional drivers and clean vehicles.',
        contact: '+1234567897',
        imageUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 40)),
        rating: 4.4,
        reviewCount: 35,
      ),
      Business(
        id: '9',
        ownerId: 'owner9',
        name: 'Memory Lane Photography',
        category: 'Photography',
        location: 'Arts Quarter',
        description:
            'Professional photography services for events, portraits, and commercial work. High-quality equipment and editing.',
        contact: '+1234567898',
        imageUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 35)),
        rating: 4.9,
        reviewCount: 24,
      ),
      Business(
        id: '10',
        ownerId: 'owner10',
        name: 'Tech Solutions Hub',
        category: 'Other',
        location: 'Tech Park',
        description:
            'IT consulting and tech support services. Computer repairs, software installation, and network setup.',
        contact: '+1234567899',
        imageUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        rating: 4.6,
        reviewCount: 12,
      ),
    ];
  }

  static List<String> getSampleLocations() {
    return [
      'Downtown',
      'University District',
      'Old Town',
      'Residential Area',
      'Industrial Zone',
      'Shopping District',
      'Suburbs',
      'City Center',
      'Arts Quarter',
      'Tech Park',
    ];
  }

  static Map<String, String> getSampleUserProfiles() {
    return {
      'owner1': 'John Smith',
      'owner2': 'Sarah Johnson',
      'owner3': 'Maria Garcia',
      'owner4': 'Ahmed Hassan',
      'owner5': 'David Wilson',
      'owner6': 'Lisa Chen',
      'owner7': 'Michael Brown',
      'owner8': 'Robert Davis',
      'owner9': 'Emma Taylor',
      'owner10': 'James Miller',
    };
  }
}
