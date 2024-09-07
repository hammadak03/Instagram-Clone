import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;
  final String uid;
  final String username;
  final List likes;
  final String postId;
  final DateTime datePublished;
  final String postUrl;
  final String profImage;
  final String mediaType; // Add mediaType field to handle different types

  Post({
    required this.description,
    required this.uid,
    required this.username,
    required this.likes,
    required this.postId,
    required this.datePublished,
    required this.postUrl,
    required this.profImage,
    required this.mediaType, // Initialize mediaType
  });

  // Convert Post to a Map
  Map<String, dynamic> toJson() => {
        'description': description,
        'uid': uid,
        'username': username,
        'likes': likes,
        'postId': postId,
        'datePublished': datePublished,
        'postUrl': postUrl,
        'profImage': profImage,
        'mediaType': mediaType, // Add mediaType to Map
      };

  // Convert a Map to Post
  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Post(
      description: snapshot['description'],
      uid: snapshot['uid'],
      username: snapshot['username'],
      likes: snapshot['likes'],
      postId: snapshot['postId'],
      datePublished: snapshot['datePublished'].toDate(),
      postUrl: snapshot['postUrl'],
      profImage: snapshot['profImage'],
      mediaType: snapshot['mediaType'], // Extract mediaType from Map
    );
  }
}
