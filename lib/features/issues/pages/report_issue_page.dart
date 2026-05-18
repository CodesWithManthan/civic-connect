import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// ---------------------------------------------------------------------------
/// REPORT ISSUE PAGE
/// ---------------------------------------------------------------------------
/// Allows users to report civic issues by capturing a photo and description.
/// Handles binary data (Images) via Firebase Storage and Metadata via Firestore.
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
  final TextEditingController descriptionController = TextEditingController();

  String? selectedCategory;
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();

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
  /// IMAGE PICKING LOGIC
  /// ---------------------------------------------------------------------------
  /// Triggers the native camera.
  /// Note: imageQuality is reduced to 80 to save Firebase bandwidth and storage costs.
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera, // Force camera to ensure live reporting
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
          content: Text("Camera failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// ---------------------------------------------------------------------------
  /// FIREBASE STORAGE UPLOAD
  /// ---------------------------------------------------------------------------
  /// Logic: Firebase Firestore cannot store raw images.
  /// 1. Upload File to Firebase Storage.
  /// 2. Retrieve the public "Download URL".
  /// 3. Return that URL to be saved as a string in the Firestore document.
  Future<String> _uploadImageToFirebase(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('issue_images')
      // Use timestamp to ensure unique filenames
          .child('issue_${DateTime.now().millisecondsSinceEpoch}.jpg');

      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      // Get the URL needed to display this image later in the feed
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception("Image upload failed: $e");
    }
  }

  /// Standard validation for required fields
  bool _validateForm() {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an image'), backgroundColor: Colors.orange),
      );
      return false;
    }

    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category'), backgroundColor: Colors.orange),
      );
      return false;
    }

    return _formKey.currentState!.validate();
  }

  /// ---------------------------------------------------------------------------
  /// SUBMISSION LOGIC (THE "WHOLE PACKAGE")
  /// ---------------------------------------------------------------------------
  Future<void> _submitIssue() async {
    if (!_validateForm()) return;

    // Show persistent loader to prevent double-submission during network lag
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Step 1: Convert GPS into a readable address for the UI
      String resolvedAddress = await _getAddressFromCoordinates(
        widget.latitude,
        widget.longitude,
      );

      // Step 2: Upload image to Storage and get the Link
      String imageUrl = await _uploadImageToFirebase(selectedImage!);

      String title = 'Issue reported: ${selectedCategory!.toLowerCase()}';

      // Step 3: Package the Map for Firestore
      // IMPORTANT: In your IssueService, remember to add 'reportedBy' UID
      // so the "My Reports" query can filter correctly.
      Map<String, dynamic> newIssue = {
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
        'createdAt': DateTime.now().toIso8601String(), // Optional: Override with ServerTimestamp in Service
      };

      Navigator.pop(context); // Dismiss loader
      Navigator.pop(context, newIssue); // Pass the data back to HomePage/MyReportsPage to trigger Firestore Write

    } catch (e) {
      Navigator.pop(context); // Dismiss loader
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  /// ---------------------------------------------------------------------------
  /// GEOCODING LOGIC
  /// ---------------------------------------------------------------------------
  /// Converts lat/lng into a human-friendly location string (e.g., "Street Name, Area").
  Future<String> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks.first;

      return [
        place.name,
        place.subLocality,
        place.locality,
      ]
          .where((element) => element != null && element!.isNotEmpty)
          .map((e) => e!)
          .take(4)
          .join(", ");
    } catch (e) {
      debugPrint("Geocoding failed: $e");
      return "Location unavailable";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report an Issue')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Upload Photo', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              /// Tapping this triggers the native camera via the _pickImage logic
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
                      ? const Center(child: Text('Tap to Take Photo'))
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(selectedImage!, fit: BoxFit.cover),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              /// Displays the address passed from the previous screen (Home/MyReports)
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

              const Text('Issue Category', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories.map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
                onChanged: (value) => setState(() => selectedCategory = value),
                validator: (value) => value == null ? 'Please select a category' : null,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),

              const SizedBox(height: 24),

              const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  if (value == null || value.trim().isEmpty) return 'Description required';
                  if (value.trim().length < 10) return 'Minimum 10 characters required';
                  return null;
                },
              ),

              const SizedBox(height: 32),

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