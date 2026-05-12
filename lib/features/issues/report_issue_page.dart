import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// ---------------------------------------------------------------------------
/// REPORT ISSUE PAGE
/// ---------------------------------------------------------------------------
/// PURPOSE:
/// Allows users to report civic issues by:
/// - Uploading an image
/// - Selecting a category
/// - Writing a description
/// - Using already provided location (privacy-first approach)
///
/// IMPORTANT DESIGN DECISION:
/// Location permission MUST be handled BEFORE navigating to this page.
/// This page only displays and uses the received location.
/// This builds better trust and avoids unnecessary permission prompts.
///
/// FIREBASE INTEGRATION NOTES:
/// - Upload image to Firebase Storage first
/// - Save issue data to Firestore
/// - Attach FirebaseAuth user ID
/// ---------------------------------------------------------------------------

class ReportIssuePage extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String address;

  const ReportIssuePage({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {

  /// -------------------- FORM STATE --------------------

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController descriptionController =
  TextEditingController();

  String? selectedCategory;

  File? selectedImage;

  final ImagePicker _picker = ImagePicker();

  /// Available issue categories
  final List<String> categories = [
    'Road',
    'Garbage',
    'Water',
    'Streetlight',
    'Drainage',
    'Other',
  ];

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  /// ---------------------------------------------------------------------------
  /// IMAGE PICKING
  /// ---------------------------------------------------------------------------
  /// Opens gallery for selecting an image.
  /// You can later:
  /// - Add camera support
  /// - Compress image
  /// - Extract EXIF GPS metadata
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera, //Forcing to take pic with camera so no old pic issue
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Camera didn't worked: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  // Image Upload function in firebase so image gets uploaded in firebase storage
  // and firestore can get url to show the image in app
  Future<String> _uploadImageToFirebase(File imageFile) async {
    try {
      print("File path: ${imageFile.path}");
      print("Exists: ${await imageFile.exists()}");
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('issue_images')
          .child('issue_${DateTime.now().millisecondsSinceEpoch}.jpg');

      UploadTask uploadTask = storageRef.putFile(imageFile);

      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception("Image upload failed: $e");
    }
  }

  /// ---------------------------------------------------------------------------
  /// FORM VALIDATION
  /// ---------------------------------------------------------------------------
  bool _validateForm() {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload an image'),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }

    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }

    if (!_formKey.currentState!.validate()) {
      return false;
    }

    return true;
  }

  /// ---------------------------------------------------------------------------
  /// ISSUE SUBMISSION (MVP VERSION)
  /// ---------------------------------------------------------------------------
  /// Currently:
  /// - Creates local issue object
  /// - Returns it to previous screen
  ///
  /// In production:
  /// - Upload image to Firebase Storage
  /// - Save document in Firestore
  /// - Handle errors properly
  Future<void> _submitIssue() async {
    if (!_validateForm()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {

      String resolvedAddress = await _getAddressFromCoordinates(
        widget.latitude,
        widget.longitude,
      );
      await Future.delayed(const Duration(seconds: 1));

      String imageUrl = await _uploadImageToFirebase(selectedImage!);

      String title = 'Issue reported: ${selectedCategory!.toLowerCase()}';

      Map<String, dynamic> newIssue = {
        'id': 'issue_${DateTime.now().millisecondsSinceEpoch}',
        'title': title,
        'description': descriptionController.text.trim(),
        'category': selectedCategory!,
        'latitude': widget.latitude,
        'longitude': widget.longitude,
        'address': resolvedAddress,
        'imageUrls': [imageUrl],
        'status': 'Reported',
        'upvotes': 0,
        'downvotes': 0,
        'createdAt': DateTime.now().toIso8601String(),
      };

      Navigator.pop(context); // Close loading

      Navigator.pop(context, newIssue); // Return issue to previous screen

    } catch (e) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Submission failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  /// Reverse geocoding to get address from coordinates
  Future<String> _getAddressFromCoordinates(
      double latitude,
      double longitude,
      ) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(latitude, longitude);

      Placemark place = placemarks.first;

      // Keep it SHORT and clean
      return [
        place.name,
        place.subLocality,
        place.locality,
      ]
          .where((element) => element != null && element!.isNotEmpty)
          .map((e) => e!)
          .take(4) // Only show 2 parts
          .join(", ");
    } catch (e) {
      debugPrint("Geocoding failed: $e");
      return "Location unavailable";
    }
  }

  /// ---------------------------------------------------------------------------
  /// UI BUILD
  /// ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report an Issue'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// -------------------- IMAGE SECTION --------------------
              const Text(
                'Upload Photo',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: selectedImage == null
                      ? const Center(
                    child: Text('Tap to Take Photo'),
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// -------------------- LOCATION DISPLAY --------------------
              const Text(
                'Location',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.address.isNotEmpty
                            ? widget.address
                            : 'Lat: ${widget.latitude}, Lng: ${widget.longitude}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// -------------------- CATEGORY --------------------
              const Text(
                'Issue Category',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                validator: (value) =>
                value == null ? 'Please select a category' : null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              /// -------------------- DESCRIPTION --------------------
              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                maxLength: 300,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Describe the issue...',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description required';
                  }
                  if (value.trim().length < 10) {
                    return 'Minimum 10 characters required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              /// -------------------- SUBMIT BUTTON --------------------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitIssue,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Submit Report'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}