import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../resources/auth_methods.dart';
import '../resources/firestore_methods.dart';
import '../resources/storage_methods.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/follow_button.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;
  bool isFriendRequestSent = false;
  bool isFriendRequestReceived = false;
  bool isFriend = false; // New variable to check if the user is a friend
  Uint8List? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String requestId = '';

  @override
  void initState() {
    super.initState();
    getData();
    checkFriendRequestStatus();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      postLen = postSnap.docs.length;
      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      isFollowing = userSnap
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);

      // Check if the current user is a friend of the profile user
      isFriend = userSnap
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);

      setState(() {});
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  checkFriendRequestStatus() async {
    // Check if a friend request has been sent
    var requestSnap = await FirebaseFirestore.instance
        .collection('friend_requests')
        .where('senderId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('receiverId', isEqualTo: widget.uid)
        .where('status', isEqualTo: 'pending')
        .get();

    if (requestSnap.docs.isNotEmpty) {
      setState(() {
        isFriendRequestSent = true;
        requestId = requestSnap.docs.first.id;
      });
    }

    // Check if a friend request has been received
    var receivedSnap = await FirebaseFirestore.instance
        .collection('friend_requests')
        .where('receiverId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('senderId', isEqualTo: widget.uid)
        .where('status', isEqualTo: 'pending')
        .get();

    if (receivedSnap.docs.isNotEmpty) {
      setState(() {
        isFriendRequestReceived = true;
        requestId = receivedSnap.docs.first.id;
      });
    }
  }

  Future<void> _selectImage() async {
    XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _imageFile = Uint8List.fromList(File(file.path).readAsBytesSync());
      });
    }
  }

  Future<void> _editProfile() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController _usernameController =
            TextEditingController(text: userData['username']);
        final TextEditingController _bioController =
            TextEditingController(text: userData['bio']);
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_imageFile != null)
                CircleAvatar(
                  backgroundImage: MemoryImage(_imageFile!),
                  radius: 50,
                ),
              TextButton(
                onPressed: _selectImage,
                child: const Text('Change Profile Picture'),
              ),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: 'Bio'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String photoUrl = userData['photoUrl'];
                if (_imageFile != null) {
                  photoUrl = await StorageMethods().uploadImageToStorage(
                    'profile_pics',
                    _imageFile!,
                    false,
                  );
                }
                String res = await FireStoreMethods().updateUserProfile(
                  FirebaseAuth.instance.currentUser!.uid,
                  _usernameController.text,
                  _bioController.text,
                  photoUrl,
                );
                if (res == 'success') {
                  Navigator.pop(context);
                  getData(); // Refresh data
                } else {
                  showSnackBar(context, res);
                }
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendFriendRequest() async {
    String res = await FireStoreMethods().sendFriendRequest(
      FirebaseAuth.instance.currentUser!.uid,
      widget.uid,
    );
    if (res == 'success') {
      setState(() {
        isFriendRequestSent = true;
      });
      showSnackBar(context, 'Friend request sent.');
    } else {
      showSnackBar(context, res);
    }
  }

  Future<void> _acceptFriendRequest() async {
    String res = await FireStoreMethods().acceptFriendRequest(requestId);
    if (res == 'success') {
      setState(() {
        isFriendRequestReceived = false;
        isFriend = true;
        followers++;
      });
      showSnackBar(context, 'Friend request accepted.');
    } else {
      showSnackBar(context, res);
    }
  }

  Future<void> _rejectFriendRequest() async {
    String res = await FireStoreMethods().rejectFriendRequest(requestId);
    if (res == 'success') {
      setState(() {
        isFriendRequestReceived = false;
      });
      showSnackBar(context, 'Friend request rejected.');
    } else {
      showSnackBar(context, res);
    }
  }

  Future<void> _removeFriend() async {
    String res = await FireStoreMethods().removeFriend(
      FirebaseAuth.instance.currentUser!.uid,
      widget.uid,
    );
    if (res == 'success') {
      setState(() {
        isFollowing = false;
        isFriend = false;
        followers--;
      });
      showSnackBar(context, 'Friend removed.');
    } else {
      showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: Text(
                userData['username'],
              ),
              centerTitle: false,
              actions: [
                FirebaseAuth.instance.currentUser!.uid == widget.uid
                    ? IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: _editProfile,
                      )
                    : Container()
              ],
            ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: NetworkImage(
                              userData['photoUrl'],
                            ),
                            radius: 40,
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    buildStatColumn(postLen, "posts"),
                                    buildStatColumn(followers, "followers"),
                                    buildStatColumn(following, "following"),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    FirebaseAuth.instance.currentUser!.uid ==
                                            widget.uid
                                        ? FollowButton(
                                            text: 'Sign Out',
                                            backgroundColor:
                                                mobileBackgroundColor,
                                            textColor: primaryColor,
                                            borderColor: Colors.grey,
                                            function: () async {
                                              await AuthMethods().signOut();
                                              if (context.mounted) {
                                                Navigator.of(context)
                                                    .pushReplacement(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const LoginScreen(),
                                                  ),
                                                );
                                              }
                                            },
                                          )
                                        : isFriendRequestReceived
                                            ? Row(
                                                children: [
                                                  FollowButton(
                                                    text: 'Accept',
                                                    backgroundColor:
                                                        Colors.green,
                                                    textColor: Colors.white,
                                                    borderColor: Colors.green,
                                                    function:
                                                        _acceptFriendRequest,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  FollowButton(
                                                    text: 'Reject',
                                                    backgroundColor: Colors.red,
                                                    textColor: Colors.white,
                                                    borderColor: Colors.red,
                                                    function:
                                                        _rejectFriendRequest,
                                                  ),
                                                ],
                                              )
                                            : isFriendRequestSent
                                                ? FollowButton(
                                                    text: 'Request Sent',
                                                    backgroundColor:
                                                        Colors.grey,
                                                    textColor: Colors.white,
                                                    borderColor: Colors.grey,
                                                    function: () {},
                                                  )
                                                : isFriend
                                                    ? FollowButton(
                                                        text: 'Unfollow',
                                                        backgroundColor:
                                                            Colors.white,
                                                        textColor: Colors.black,
                                                        borderColor:
                                                            Colors.grey,
                                                        function: _removeFriend,
                                                      )
                                                    : FollowButton(
                                                        text: 'Follow',
                                                        backgroundColor:
                                                            Colors.blue,
                                                        textColor: Colors.white,
                                                        borderColor:
                                                            Colors.blue,
                                                        function:
                                                            _sendFriendRequest,
                                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(
                          top: 15,
                        ),
                        child: Text(
                          userData['username'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(
                          top: 1,
                        ),
                        child: Text(
                          userData['bio'],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('posts')
                      .where('uid', isEqualTo: widget.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      itemCount: (snapshot.data! as dynamic).docs.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 1.5,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        DocumentSnapshot snap =
                            (snapshot.data! as dynamic).docs[index];

                        return SizedBox(
                          child: Image(
                            image: NetworkImage(snap['postUrl']),
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    );
                  },
                )
              ],
            ),
          );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
