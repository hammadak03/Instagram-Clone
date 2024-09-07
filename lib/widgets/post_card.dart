// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:instagram_clone/models/user.dart' as model;
// import 'package:instagram_clone/widgets/like_animation.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:video_player/video_player.dart'; // For video playback
// import 'package:audioplayers/audioplayers.dart'; // For audio playback
// import '../providers/user_provider.dart';
// import '../resources/firestore_methods.dart';
// import '../screens/comments_screen.dart';
// import '../utils/colors.dart';
// import '../utils/global_variable.dart';
// import '../utils/utils.dart';

// class PostCard extends StatefulWidget {
//   final snap;
//   const PostCard({
//     super.key,
//     required this.snap,
//   });

//   @override
//   State<PostCard> createState() => _PostCardState();
// }

// class _PostCardState extends State<PostCard> {
//   int commentLen = 0;
//   bool isLikeAnimating = false;
//   late VideoPlayerController _videoController;
//   late AudioPlayer _audioPlayer;
//   bool isVideo = false;
//   bool isAudio = false;

//   @override
//   void initState() {
//     super.initState();
//     fetchCommentLen();
//     _initializeMedia();
//   }

//   fetchCommentLen() async {
//     try {
//       QuerySnapshot snap = await FirebaseFirestore.instance
//           .collection('posts')
//           .doc(widget.snap['postId'])
//           .collection('comments')
//           .get();
//       commentLen = snap.docs.length;
//     } catch (err) {
//       showSnackBar(
//         context,
//         err.toString(),
//       );
//     }
//     setState(() {});
//   }

//   _initializeMedia() {
//     String postUrl = widget.snap['postUrl'];

//     // Check if the post is a video or audio based on file extension
//     if (postUrl.endsWith('.mp4')) {
//       isVideo = true;
//       _videoController = VideoPlayerController.network(postUrl)
//         ..initialize().then((_) {
//           setState(() {}); // Rebuild to show the video
//           _videoController.play();
//           _videoController.setLooping(true);
//         });
//     } else if (postUrl.endsWith('.mp3')) {
//       isAudio = true;
//       _audioPlayer = AudioPlayer();
//       _audioPlayer.setSourceUrl(postUrl);
//     }
//   }

//   @override
//   void dispose() {
//     if (isVideo) {
//       _videoController.dispose();
//     }
//     if (isAudio) {
//       _audioPlayer.dispose();
//     }
//     super.dispose();
//   }

//   deletePost(String postId) async {
//     try {
//       await FireStoreMethods().deletePost(postId);
//     } catch (err) {
//       showSnackBar(
//         context,
//         err.toString(),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final model.User user = Provider.of<UserProvider>(context).getUser;
//     final width = MediaQuery.of(context).size.width;

//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(
//           color: width > webScreenSize ? secondaryColor : mobileBackgroundColor,
//         ),
//         color: mobileBackgroundColor,
//       ),
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Column(
//         children: [
//           // HEADER SECTION OF THE POST
//           _buildHeader(context, user),

//           // MEDIA SECTION OF THE POST
//           GestureDetector(
//             onDoubleTap: () {
//               FireStoreMethods().likePost(
//                 widget.snap['postId'].toString(),
//                 user.uid,
//                 widget.snap['likes'],
//               );
//               setState(() {
//                 isLikeAnimating = true;
//               });
//             },
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 SizedBox(
//                   height: MediaQuery.of(context).size.height * 0.35,
//                   width: double.infinity,
//                   child: _buildPostMedia(), // Display image, video, or audio
//                 ),
//                 AnimatedOpacity(
//                   duration: const Duration(milliseconds: 200),
//                   opacity: isLikeAnimating ? 1 : 0,
//                   child: LikeAnimation(
//                     isAnimating: isLikeAnimating,
//                     duration: const Duration(milliseconds: 400),
//                     onEnd: () {
//                       setState(() {
//                         isLikeAnimating = false;
//                       });
//                     },
//                     child: const Icon(
//                       Icons.favorite,
//                       color: Colors.white,
//                       size: 100,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // LIKE, COMMENT SECTION
//           _buildLikeCommentSection(user),

//           // DESCRIPTION AND COMMENT COUNT
//           _buildDescriptionAndComments(context),
//         ],
//       ),
//     );
//   }

//   // HEADER SECTION
//   // Widget _buildHeader(BuildContext context, model.User user) {
//   //   return Container(
//   //     padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16)
//   //         .copyWith(right: 0),
//   //     child: Row(
//   //       children: <Widget>[
//   //         CircleAvatar(
//   //           radius: 16,
//   //           backgroundImage: NetworkImage(widget.snap['profImage'].toString()),
//   //         ),
//   //         Expanded(
//   //           child: Padding(
//   //             padding: const EdgeInsets.only(left: 8),
//   //             child: Column(
//   //               mainAxisSize: MainAxisSize.min,
//   //               crossAxisAlignment: CrossAxisAlignment.start,
//   //               children: <Widget>[
//   //                 Text(
//   //                   widget.snap['username'].toString(),
//   //                   style: const TextStyle(fontWeight: FontWeight.bold),
//   //                 ),
//   //               ],
//   //             ),
//   //           ),
//   //         ),
//   //         widget.snap['uid'].toString() == user.uid
//   //             ? IconButton(
//   //                 onPressed: () {
//   //                   showDialog(
//   //                     useRootNavigator: false,
//   //                     context: context,
//   //                     builder: (context) {
//   //                       return Dialog(
//   //                         child: ListView(
//   //                           padding: const EdgeInsets.symmetric(vertical: 16),
//   //                           shrinkWrap: true,
//   //                           children: [
//   //                             InkWell(
//   //                               child: Container(
//   //                                 padding: const EdgeInsets.symmetric(
//   //                                     vertical: 12, horizontal: 16),
//   //                                 child: Text('Delete'),
//   //                               ),
//   //                               onTap: () {
//   //                                 deletePost(widget.snap['postId'].toString());
//   //                                 Navigator.of(context).pop();
//   //                               },
//   //                             ),
//   //                           ],
//   //                         ),
//   //                       );
//   //                     },
//   //                   );
//   //                 },
//   //                 icon: const Icon(Icons.more_vert),
//   //               )
//   //             : Container(),
//   //       ],
//   //     ),
//   //   );
//   // }
//   Widget _buildHeader(BuildContext context, model.User user) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16)
//           .copyWith(right: 0),
//       child: Row(
//         children: <Widget>[
//           CircleAvatar(
//             radius: 16,
//             backgroundImage: NetworkImage(widget.snap['profImage'].toString()),
//           ),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.only(left: 8),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: <Widget>[
//                   Text(
//                     widget.snap['username'].toString(),
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           widget.snap['uid'].toString() == user.uid
//               ? IconButton(
//                   onPressed: () {
//                     showDialog(
//                       useRootNavigator: false,
//                       context: context,
//                       builder: (context) {
//                         return Dialog(
//                           child: ListView(
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shrinkWrap: true,
//                             children: [
//                               InkWell(
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       vertical: 12, horizontal: 16),
//                                   child: Text('Edit'),
//                                 ),
//                                 onTap: () {
//                                   Navigator.of(context).pop();
//                                   _showEditDialog(context);
//                                 },
//                               ),
//                               InkWell(
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       vertical: 12, horizontal: 16),
//                                   child: Text('Delete'),
//                                 ),
//                                 onTap: () {
//                                   deletePost(widget.snap['postId'].toString());
//                                   Navigator.of(context).pop();
//                                 },
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     );
//                   },
//                   icon: const Icon(Icons.more_vert),
//                 )
//               : Container(),
//         ],
//       ),
//     );
//   }

//   void _showEditDialog(BuildContext context) {
//     final TextEditingController _descriptionController =
//         TextEditingController(text: widget.snap['description']);

//     showDialog(
//       useRootNavigator: false,
//       context: context,
//       builder: (context) {
//         return Dialog(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: _descriptionController,
//                   decoration: const InputDecoration(
//                     labelText: 'Edit Description',
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () async {
//                     String res = await FireStoreMethods().updatePost(
//                       widget.snap['postId'].toString(),
//                       _descriptionController.text,
//                     );
//                     if (res == 'success') {
//                       Navigator.of(context).pop();
//                       setState(() {});
//                     } else {
//                       showSnackBar(context, res);
//                     }
//                   },
//                   child: const Text('Update'),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // MEDIA HANDLING SECTION
//   Widget _buildPostMedia() {
//     String postUrl = widget.snap['postUrl'];

//     // Handle video, audio, or image media
//     if (isVideo && _videoController.value.isInitialized) {
//       return AspectRatio(
//         aspectRatio: _videoController.value.aspectRatio,
//         child: VideoPlayer(_videoController),
//       );
//     } else if (isAudio) {
//       return Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.audiotrack, size: 50, color: Colors.grey[700]),
//           Text('Playing audio...', style: TextStyle(color: Colors.white)),
//           IconButton(
//             icon: Icon(Icons.play_arrow),
//             onPressed: () {
//               _audioPlayer.resume();
//             },
//           ),
//         ],
//       );
//     } else {
//       // If not video or audio, treat it as an image
//       return Image.network(
//         postUrl,
//         fit: BoxFit.cover,
//       );
//     }
//   }

//   // LIKE AND COMMENT SECTION
//   Widget _buildLikeCommentSection(model.User user) {
//     return Row(
//       children: <Widget>[
//         LikeAnimation(
//           isAnimating: widget.snap['likes'].contains(user.uid),
//           smallLike: true,
//           child: IconButton(
//             icon: widget.snap['likes'] != null &&
//                     widget.snap['likes'].contains(user.uid)
//                 ? const Icon(Icons.favorite, color: Colors.red)
//                 : const Icon(Icons.favorite_border),
//             onPressed: () => FireStoreMethods().likePost(
//               widget.snap['postId'].toString(),
//               user.uid,
//               widget.snap['likes'] ?? [],
//             ),
//           ),
//         ),
//         IconButton(
//           icon: const Icon(Icons.comment_outlined),
//           onPressed: () => Navigator.of(context).push(
//             MaterialPageRoute(
//               builder: (context) => CommentsScreen(
//                 postId: widget.snap['postId'].toString(),
//               ),
//             ),
//           ),
//         ),
//         IconButton(
//           icon: const Icon(Icons.send),
//           onPressed: () {},
//         ),
//         Expanded(
//           child: Align(
//             alignment: Alignment.bottomRight,
//             child: IconButton(
//               icon: const Icon(Icons.bookmark_border),
//               onPressed: () {},
//             ),
//           ),
//         )
//       ],
//     );
//   }

//   // DESCRIPTION AND COMMENT COUNT SECTION
//   Widget _buildDescriptionAndComments(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           DefaultTextStyle(
//               style: Theme.of(context)
//                   .textTheme
//                   .titleSmall!
//                   .copyWith(fontWeight: FontWeight.w800),
//               child: Text(
//                 '${widget.snap['likes'].length} likes',
//                 style: Theme.of(context).textTheme.bodyMedium,
//               )),
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.only(top: 8),
//             child: RichText(
//               text: TextSpan(
//                 style: const TextStyle(color: primaryColor),
//                 children: [
//                   TextSpan(
//                     text: widget.snap['username'].toString(),
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   TextSpan(
//                     text: ' ${widget.snap['description']}',
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           InkWell(
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 4),
//               child: Text(
//                 'View all $commentLen comments',
//                 style: const TextStyle(
//                   fontSize: 16,
//                   color: secondaryColor,
//                 ),
//               ),
//             ),
//             onTap: () => Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (context) => CommentsScreen(
//                   postId: widget.snap['postId'].toString(),
//                 ),
//               ),
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(vertical: 4),
//             child: Text(
//               DateFormat.yMMMd().format(widget.snap['datePublished'].toDate()),
//               style: const TextStyle(
//                 color: secondaryColor,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart' as model;
import 'package:instagram_clone/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart'; // For video playback
import 'package:audioplayers/audioplayers.dart'; // For audio playback
import '../providers/user_provider.dart';
import '../resources/firestore_methods.dart';
import '../screens/comments_screen.dart';
import '../utils/colors.dart';
import '../utils/global_variable.dart';
import '../utils/utils.dart';

class PostCard extends StatefulWidget {
  final snap;
  const PostCard({
    super.key,
    required this.snap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int commentLen = 0;
  bool isLikeAnimating = false;
  late VideoPlayerController _videoController;
  late AudioPlayer _audioPlayer;
  bool isVideo = false;
  bool isAudio = false;

  @override
  void initState() {
    super.initState();
    fetchCommentLen();
    _initializeMedia();
  }

  fetchCommentLen() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      commentLen = snap.docs.length;
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
    setState(() {});
  }

  _initializeMedia() {
    String postUrl = widget.snap['postUrl'] ?? '';
    String mediaType = widget.snap['mediaType'] ?? ''; // Fetch mediaType

    if (mediaType == 'video') {
      isVideo = true;
      _videoController = VideoPlayerController.network(postUrl)
        ..initialize().then((_) {
          setState(() {});
          _videoController.play();
          _videoController.setLooping(true);
        });
    } else if (mediaType == 'audio') {
      isAudio = true;
      _audioPlayer = AudioPlayer();
      _audioPlayer.setSourceUrl(postUrl);
    }
  }

  @override
  void dispose() {
    if (isVideo) {
      _videoController.dispose();
    }
    if (isAudio) {
      _audioPlayer.dispose();
    }
    super.dispose();
  }

  deletePost(String postId) async {
    try {
      await FireStoreMethods().deletePost(postId);
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<UserProvider>(context).getUser;
    final width = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: width > webScreenSize ? secondaryColor : mobileBackgroundColor,
        ),
        color: mobileBackgroundColor,
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          // HEADER SECTION OF THE POST
          _buildHeader(context, user),

          // MEDIA SECTION OF THE POST
          GestureDetector(
            onDoubleTap: () {
              FireStoreMethods().likePost(
                widget.snap['postId'].toString(),
                user.uid,
                widget.snap['likes'],
              );
              setState(() {
                isLikeAnimating = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: double.infinity,
                  child: _buildPostMedia(), // Display image, video, or audio
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLikeAnimating ? 1 : 0,
                  child: LikeAnimation(
                    isAnimating: isLikeAnimating,
                    duration: const Duration(milliseconds: 400),
                    onEnd: () {
                      setState(() {
                        isLikeAnimating = false;
                      });
                    },
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 100,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // LIKE, COMMENT SECTION
          _buildLikeCommentSection(user),

          // DESCRIPTION AND COMMENT COUNT
          _buildDescriptionAndComments(context),
        ],
      ),
    );
  }

  // HEADER SECTION
  Widget _buildHeader(BuildContext context, model.User user) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16)
          .copyWith(right: 0),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(widget.snap['profImage'].toString()),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.snap['username'].toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          widget.snap['uid'].toString() == user.uid
              ? IconButton(
                  onPressed: () {
                    showDialog(
                      useRootNavigator: false,
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shrinkWrap: true,
                            children: [
                              InkWell(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  child: const Text('Edit'),
                                ),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  _showEditDialog(context);
                                },
                              ),
                              InkWell(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  child: const Text('Delete'),
                                ),
                                onTap: () {
                                  deletePost(widget.snap['postId'].toString());
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.more_vert),
                )
              : Container(),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final TextEditingController _descriptionController =
        TextEditingController(text: widget.snap['description']);

    showDialog(
      useRootNavigator: false,
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Edit Description',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    String res = await FireStoreMethods().updatePost(
                      widget.snap['postId'].toString(),
                      _descriptionController.text,
                    );
                    if (res == 'success') {
                      Navigator.of(context).pop();
                      setState(() {});
                    } else {
                      showSnackBar(context, res);
                    }
                  },
                  child: const Text('Update'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // MEDIA HANDLING SECTION
  Widget _buildPostMedia() {
    String postUrl = widget.snap['postUrl'] ?? '';
    String mediaType = widget.snap['mediaType'] ?? ''; // Fetch mediaType
    if (postUrl == null || mediaType == null) {
      return const Center(
        child: Text('Error: Media data is incomplete.'),
      );
    }
    if (mediaType == 'video' &&
        isVideo &&
        _videoController.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _videoController.value.aspectRatio,
        child: VideoPlayer(_videoController),
      );
    } else if (mediaType == 'audio') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.audiotrack, size: 50, color: Colors.grey[700]),
          const Text('Playing audio...', style: TextStyle(color: Colors.white)),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              _audioPlayer.resume();
            },
          ),
        ],
      );
    } else {
      // Assuming image if not video or audio
      return Image.network(
        postUrl,
        fit: BoxFit.cover,
      );
    }
  }

  // LIKE AND COMMENT SECTION
  Widget _buildLikeCommentSection(model.User user) {
    return Row(
      children: <Widget>[
        LikeAnimation(
          isAnimating: widget.snap['likes'].contains(user.uid),
          smallLike: true,
          child: IconButton(
            icon: widget.snap['likes'] != null &&
                    widget.snap['likes'].contains(user.uid)
                ? const Icon(Icons.favorite, color: Colors.red)
                : const Icon(Icons.favorite_border),
            onPressed: () async {
              await FireStoreMethods().likePost(
                widget.snap['postId'].toString(),
                user.uid,
                widget.snap['likes'],
              );
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.comment_outlined),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CommentsScreen(
                postId: widget.snap['postId'].toString(),
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {},
        ),
      ],
    );
  }

  // DESCRIPTION AND COMMENT COUNT SECTION
  Widget _buildDescriptionAndComments(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '${widget.snap['likes'].length} likes',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Container(
            width: double.infinity,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: widget.snap['username'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ' ${widget.snap['description'] ?? ''}',
                  ),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CommentsScreen(
                  postId: widget.snap['postId'].toString(),
                ),
              ),
            ),
            child: Text(
              'View all $commentLen comments',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          Text(
            DateFormat.yMMMd().format(
              widget.snap['datePublished'].toDate(),
            ),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
