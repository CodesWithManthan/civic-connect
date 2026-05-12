/// ---------------------------------------------------------------------------
/// MOCK DATA - STRUCTURED LIKE FIRESTORE DOCUMENTS
/// ---------------------------------------------------------------------------
/// This data structure mirrors what we'll get from Firebase Firestore later.
/// Each map represents a document with all fields needed for the app.
///
/// FIREBASE MIGRATION NOTES:
/// - Replace this list with: FirebaseFirestore.instance.collection('issues').get()
/// - Each map will become a DocumentSnapshot
/// - Add listeners for real-time updates
/// - Add pagination (limit queries to 20 items at a time)
List<Map<String, dynamic>> issues = [
  {
    "id": "issue_001",
    "title": "Large pothole near main road",
    "description": "Deep pothole causing traffic jams during rush hour. Multiple vehicles have been damaged. The hole is approximately 2 feet wide and 8 inches deep.",
    "category": "Road",
    "latitude": 18.5204,
    "longitude": 73.8567,
    "address": "FC Road, Deccan Gymkhana, Pune",
    "status": "Reported",
    "upvotes": 42,
    "downvotes": 3,
    "imageUrls": [
      "https://media.istockphoto.com/id/95658927/photo/a-large-pot-hole-filled-with-water-on-an-asphalt-road.jpg?s=612x612&w=0&k=20&c=o4V3HZV1HqlopqwJ7DsI8BuwD7k26UKthAZ_FSn8SrY="
    ],
    "createdAt": "2026-01-20T10:30:00Z",
    "reportedBy": "user_123"
  },
  {
    "id": "issue_002",
    "title": "Overflowing garbage bins at park entrance",
    "description": "Garbage bins have not been emptied for over a week. Creating health hazard and bad smell in the area.",
    "category": "Garbage",
    "latitude": 18.5314,
    "longitude": 73.8446,
    "address": "Shivaji Park, Pune",
    "status": "In Progress",
    "upvotes": 28,
    "downvotes": 1,
    "imageUrls": [
      "https://media.istockphoto.com/id/1175874693/photo/huge-garbage-piles-next-to-the-dumpster-after-city-fair-stacks-of-litter-bags-overflow-trash.jpg?s=612x612&w=0&k=20&c=91x9gxN_tT2gdSH0OQMO1q19KTFdhj56B62-dLY8tso="
    ],
    "createdAt": "2026-01-21T14:20:00Z",
    "reportedBy": "user_456"
  },
  {
    "id": "issue_003",
    "title": "Broken streetlight causing safety concerns",
    "description": "Streetlight has been non-functional for 2 weeks. Area becomes very dark at night, causing safety issues for pedestrians.",
    "category": "Electricity",
    "latitude": 18.5362,
    "longitude": 73.8512,
    "address": "Law College Road, Pune",
    "status": "Reported",
    "upvotes": 15,
    "downvotes": 0,
    "imageUrls": [
      "https://media.istockphoto.com/id/1290085267/photo/broken-electricity-wires-hanging-from-a-storm-damaged-suburban-light-pole.jpg?s=612x612&w=0&k=20&c=kYI6OXkWrQwJXmEGQ4MABkZXuIPsaDVkoMqevdh1_l8="
    ],
    "createdAt": "2026-01-22T09:15:00Z",
    "reportedBy": "user_789"
  },
  {
    "id": "issue_004",
    "title": "Water pipeline leak wasting resources",
    "description": "Major water leak from underground pipeline. Water flowing continuously on the road for 3 days.",
    "category": "Water",
    "latitude": 18.5074,
    "longitude": 73.8077,
    "address": "Karve Road, Kothrud, Pune",
    "status": "In Progress",
    "upvotes": 67,
    "downvotes": 2,
    "imageUrls": [
      "https://images.unsplash.com/photo-1542013936693-884638332954?w=800",
      "https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800"
    ],
    "createdAt": "2026-01-19T16:45:00Z",
    "reportedBy": "user_321"
  },
  {
    "id": "issue_005",
    "title": "Illegal dumping in residential area",
    "description": "Construction debris dumped illegally near residential society. Blocking pedestrian pathway.",
    "category": "Garbage",
    "latitude": 18.5435,
    "longitude": 73.8256,
    "address": "Baner Road, Pune",
    "status": "Resolved",
    "upvotes": 34,
    "downvotes": 5,
    "imageUrls": [
      "https://images.unsplash.com/photo-1604187351574-c75ca79f5807?w=400"
    ],
    "createdAt": "2026-01-18T11:00:00Z",
    "reportedBy": "user_654"
  },
];