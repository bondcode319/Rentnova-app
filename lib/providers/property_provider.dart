import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class Property {
  final String id;
  final String ownerId;
  final String name;
  final String address;
  final double rent;
  final String? description;
  final List<String> amenities;
  final List<String>? images;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  Property({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    required this.rent,
    this.description,
    required this.amenities,
    this.images,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Property.fromMap(Map<String, dynamic> data, String id) {
    return Property(
      id: id,
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      rent: (data['rent'] ?? 0).toDouble(),
      description: data['description'],
      amenities: List<String>.from(data['amenities'] ?? []),
      images: data['images'] != null ? List<String>.from(data['images']) : null,
      isAvailable: data['isAvailable'] ?? true,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  get status => null;

  String get title => null;

  String get location => null;

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'address': address,
      'rent': rent,
      'description': description,
      'amenities': amenities,
      'images': images,
      'isAvailable': isAvailable,
      'updatedAt': DateTime.now(),
    };
  }
}

class PropertyProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Property> _properties = [];
  bool _isLoading = false;
  String? _error;

  List<Property> get properties => _properties;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void update(UserModel? user) {
    if (user == null) {
      _properties = [];
      notifyListeners();
      return;
    }

    fetchProperties(user);
  }

  Future<void> fetchProperties(UserModel user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      QuerySnapshot snapshot;

      if (user.role == UserRole.admin) {
        // Admin can see all properties
        snapshot = await _firestore.collection('properties').get();
      } else if (user.role == UserRole.landlord) {
        // Landlord can see their own properties
        snapshot =
            await _firestore
                .collection('properties')
                .where('ownerId', isEqualTo: user.id)
                .get();
      } else {
        // Tenant can see available properties
        snapshot =
            await _firestore
                .collection('properties')
                .where('isAvailable', isEqualTo: true)
                .get();
      }

      _properties =
          snapshot.docs
              .map(
                (doc) => Property.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProperty(Property property) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection('properties').add(property.toMap());
      await fetchProperties(
        _properties.isNotEmpty
            ? UserModel(
              id: property.ownerId,
              email: '',
              role: UserRole.landlord,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            )
            : null,
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProperty(Property property) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore
          .collection('properties')
          .doc(property.id)
          .update(property.toMap());

      // Update local list
      final index = _properties.indexWhere((p) => p.id == property.id);
      if (index >= 0) {
        _properties[index] = property;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProperty(String propertyId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection('properties').doc(propertyId).delete();

      // Remove from local list
      _properties.removeWhere((p) => p.id == propertyId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
