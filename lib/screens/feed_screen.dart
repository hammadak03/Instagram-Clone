import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/colors.dart';
import '../utils/global_variable.dart';
import '../widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String selectedFilter = 'Discover'; // Dropdown default to Discover

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor:
          width > webScreenSize ? webBackgroundColor : mobileBackgroundColor,
      appBar: width > webScreenSize
          ? null
          : AppBar(
              backgroundColor: mobileBackgroundColor,
              centerTitle: false,
              title: SvgPicture.asset(
                'assets/ic_instagram.svg',
                color: primaryColor,
                height: 32,
              ),
              actions: [
                DropdownButton<String>(
                  value: selectedFilter,
                  items: <String>['Discover', 'My Posts'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedFilter = newValue!;
                    });
                  },
                ),
              ],
            ),
      body: Column(
        children: [
          // StreamBuilder for posts based on the selected filter
          Expanded(
            child: StreamBuilder(
              stream: getFilteredPostsStream(),
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (ctx, index) => Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: width > webScreenSize ? width * 0.3 : 0,
                      vertical: width > webScreenSize ? 15 : 0,
                    ),
                    child: PostCard(
                      snap: snapshot.data!.docs[index].data(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Function to get posts stream based on the selected filter
  Stream<QuerySnapshot<Map<String, dynamic>>> getFilteredPostsStream() {
    if (selectedFilter == 'Discover') {
      // Get all posts (Discover)
      return FirebaseFirestore.instance.collection('posts').snapshots();
    } else {
      // Get only current user's posts (My Posts)
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      return FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: currentUserId)
          .snapshots();
    }
  }
}
