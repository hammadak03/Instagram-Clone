import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';

import '../providers/user_provider.dart';
import '../resources/firestore_methods.dart';
import '../resources/storage_methods.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _imageFile; // For images
  File? _mediaFile; // For video and audio
  bool isLoading = false;
  String mediaType = 'image'; // Default to image
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  VideoPlayerController? _videoPlayerController;

  Future<void> _selectMediaType() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Media Type'),
          children: <Widget>[
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Image'),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  mediaType = 'image';
                });
                _selectMedia();
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Video'),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  mediaType = 'video';
                });
                _selectMedia();
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Audio'),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  mediaType = 'audio';
                });
                _selectMedia();
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectMedia() async {
    XFile? file;
    if (mediaType == 'image') {
      file = await _picker.pickImage(source: ImageSource.gallery);
    } else if (mediaType == 'video') {
      file = await _picker.pickVideo(source: ImageSource.gallery);
    } else if (mediaType == 'audio') {
      file =
          (await FilePicker.platform.pickFiles(type: FileType.audio)) as XFile?;
    }

    if (file != null) {
      setState(() {
        _mediaFile = File(file!.path);
        if (mediaType == 'image') {
          _imageFile = Uint8List.fromList(File(file.path).readAsBytesSync());
        } else if (mediaType == 'video') {
          _videoPlayerController = VideoPlayerController.file(File(file.path))
            ..initialize().then((_) {
              setState(() {});
            });
        }
      });
    }
  }

  Future<void> postMedia(String uid, String username, String profImage) async {
    setState(() {
      isLoading = true;
    });
    try {
      String mediaUrl = '';
      if (mediaType == 'image' && _imageFile != null) {
        mediaUrl = await StorageMethods().uploadImageToStorage(
          'posts',
          _imageFile!,
          true, // Image flag
        );
      } else if (_mediaFile != null) {
        mediaUrl = await StorageMethods().uploadMediaToStorage(
          'posts',
          _mediaFile!,
          mediaType,
        );
      }

      String res = await FireStoreMethods().uploadPost(
        _descriptionController.text,
        mediaUrl,
        uid,
        username,
        profImage,
        mediaType,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        if (context.mounted) {
          showSnackBar(context, 'Posted!');
        }
        clearMedia();
      } else {
        if (context.mounted) {
          showSnackBar(context, res);
        }
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(context, err.toString());
    }
  }

  void clearMedia() {
    setState(() {
      _imageFile = null;
      _mediaFile = null;
      if (_videoPlayerController != null) {
        _videoPlayerController!.dispose();
      }
      _videoPlayerController = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
    if (_videoPlayerController != null) {
      _videoPlayerController!.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return _imageFile == null && _mediaFile == null
        ? Center(
            child: IconButton(
              icon: const Icon(Icons.upload),
              onPressed: () => _selectMediaType(),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: clearMedia,
              ),
              title: const Text('Post to'),
              centerTitle: false,
              actions: <Widget>[
                TextButton(
                  onPressed: () => postMedia(
                    userProvider.getUser.uid,
                    userProvider.getUser.username,
                    userProvider.getUser.photoUrl,
                  ),
                  child: const Text(
                    "Post",
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0),
                  ),
                )
              ],
            ),
            body: Column(
              children: <Widget>[
                isLoading
                    ? const LinearProgressIndicator()
                    : const Padding(padding: EdgeInsets.only(top: 0.0)),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage:
                          NetworkImage(userProvider.getUser.photoUrl),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                            hintText: "Write a caption...",
                            border: InputBorder.none),
                        maxLines: 8,
                      ),
                    ),
                    if (mediaType == 'image' && _imageFile != null)
                      SizedBox(
                        height: 45.0,
                        width: 45.0,
                        child: AspectRatio(
                          aspectRatio: 487 / 451,
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                image: MemoryImage(_imageFile!),
                              ),
                            ),
                          ),
                        ),
                      )
                    else if (mediaType == 'video' &&
                        _videoPlayerController != null)
                      AspectRatio(
                        aspectRatio: _videoPlayerController!.value.aspectRatio,
                        child: VideoPlayer(_videoPlayerController!),
                      )
                    else if (mediaType == 'audio' && _mediaFile != null)
                      Text('Audio File Selected'), // Placeholder for audio UI
                  ],
                ),
                const Divider(),
              ],
            ),
          );
  }
}
