// lib/models/property.dart
enum PropertyType { apartment, house, condo, townhouse, studio, duplex, other }

enum RentalType { standard, shortStay }

enum PropertyStatus { pending, verified, rejected, rented }

class PropertyModel {
  final String id;
  final String landlordId;
  final String title;
  final String description;
  final double price;
  final String location;
  final PropertyType propertyType;
  final RentalType rentalType;
  final int bedrooms;
  final int bathrooms;
  final List<String> amenities;
  final List<String> imageUrls;
  final String? videoUrl;
  final PropertyStatus status;
  final DateTime listedDate;
  final DateTime? availableFrom;
  final Map<String, int> unitBreakdown; // e.g., {'1-bed': 5, 'studio': 2}

  PropertyModel({
    required this.id,
    required this.landlordId,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.propertyType,
    required this.rentalType,
    required this.bedrooms,
    required this.bathrooms,
    required this.amenities,
    required this.imageUrls,
    this.videoUrl,
    required this.status,
    required this.listedDate,
    this.availableFrom,
    required this.unitBreakdown,
  });

  factory PropertyModel.fromMap(String id, Map<String, dynamic> data) {
    return PropertyModel(
      id: id,
      landlordId: data['landlordId'],
      title: data['title'],
      description: data['description'],
      price: data['price'].toDouble(),
      location: data['location'],
      propertyType: PropertyType.values.firstWhere(
        (e) => e.toString() == 'PropertyType.${data['propertyType']}',
        orElse: () => PropertyType.apartment,
      ),
      rentalType: RentalType.values.firstWhere(
        (e) => e.toString() == 'RentalType.${data['rentalType']}',
        orElse: () => RentalType.standard,
      ),
      bedrooms: data['bedrooms'],
      bathrooms: data['bathrooms'],
      amenities: List<String>.from(data['amenities']),
      imageUrls: List<String>.from(data['imageUrls']),
      videoUrl: data['videoUrl'],
      status: PropertyStatus.values.firstWhere(
        (e) => e.toString() == 'PropertyStatus.${data['status']}',
        orElse: () => PropertyStatus.pending,
      ),
      listedDate: DateTime.parse(data['listedDate']),
      availableFrom:
          data['availableFrom'] != null
              ? DateTime.parse(data['availableFrom'])
              : null,
      unitBreakdown: Map<String, int>.from(data['unitBreakdown']),
    );
  }
}
