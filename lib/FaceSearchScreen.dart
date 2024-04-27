import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FaceSearchScreen extends StatefulWidget {
  const FaceSearchScreen({super.key});

  @override
  _FaceSearchScreenState createState() => _FaceSearchScreenState();
}

class _FaceSearchScreenState extends State<FaceSearchScreen> {
  List<String> users = [];
  Timer? _timer;
  File? imageFile;
  List<String> pictures = [];
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String fetchImageUrl = '';

  void _fetchNextImage() async {
    // Dummy API URL
    const apiUrl = "https://randomuser.me/api/?results=10";

    try {
      final url = Uri.parse(apiUrl);
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        for (int i = 0; i < data['results'].length; i++) {
          pictures.add(data['results'][i]['picture']['large']);
          Future.delayed(const Duration(seconds: 2), () {
            setState(() {
              fetchImageUrl = data['results'][i]['picture']['large'];
            });
          });
        }
      } else {
        throw Exception('Failed to fetch images');
      }
    } catch (e) {
      log('Error: $e');
    }
  }

  final Duration _duration = const Duration(seconds: 2);

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_duration.inSeconds <= 0) {
        // Countdown is finished
        _timer?.cancel();
        // Perform any desired action when the countdown is completed
      }
    });
  }

  void _uploadImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() {
        imageFile = imageTemp;
      });
      _timer?.cancel(); // Cancel the existing timer
      _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
        _fetchNextImage();
      });
    } catch (e) {
      log('Failed to pick image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black45,
        centerTitle: true,
        title: const Text(
          'Face Check',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        titleSpacing: 00.0,
        toolbarHeight: 60.2,
        toolbarOpacity: 0.8,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Setting Icon',
            onPressed: () {},
          ), //IconButton
        ],
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          // color: Colors.black,
          image: DecorationImage(
            image: AssetImage(
                'assets/photo.jpg'), // Change this to your background image path
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(60.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: imageFile != null
                    ? Image.file(
                        imageFile!,
                        height: 150,
                      )
                    : const SizedBox(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _uploadImage();
                  setState(() {
                    _searching = true;
                  });
                },
                child: const Text('Upload Image'),
              ),
              const SizedBox(height: 20),
              if (_searching) const CircularProgressIndicator(),
              if (fetchImageUrl.isNotEmpty && _searching)
                const SizedBox(height: 10),
              const Text(
                'Searching for similar faces',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: fetchImageUrl.isNotEmpty
                      ? Image.network(
                          fetchImageUrl,
                          height: 200,
                        )
                      : const SizedBox(),
                ),
              ),

              //     // Center(
              //     //   child: Container(
              //     //     margin: const EdgeInsets.all(80),
              //     //     padding: const EdgeInsets.all(40),
              //     //     // height: 450,
              //     //     decoration: BoxDecoration(
              //     //       color: Colors.black45,
              //     //       borderRadius: BorderRadius.circular(50),
              //     //       boxShadow: [
              //     //         BoxShadow(
              //     //           color: Colors.black.withOpacity(0.10),
              //     //           spreadRadius: 2,
              //     //           blurRadius: 5,
              //     //           offset: const Offset(0, 2),
              //     //         ),
              //     //       ],
              //     //     ),
              //     //     child: Column(
              //     //       mainAxisAlignment: MainAxisAlignment.center,
              //     //       children: <Widget>[
              //     //         Container(
              //     //           decoration: BoxDecoration(
              //     //             borderRadius: BorderRadius.circular(10),
              //     //             boxShadow: [
              //     //               BoxShadow(
              //     //                 color: Colors.grey.withOpacity(0.5),
              //     //                 spreadRadius: 2,
              //     //                 blurRadius: 5,
              //     //                 offset: const Offset(0, 2),
              //     //               ),
              //     //             ],
              //     //           ),
              //     //           child: imageFile != null
              //     //               ? Image.file(
              //     //                   imageFile!,
              //     //                   height: 150,
              //     //                 )
              //     //               : const SizedBox(),
              //     //         ),
              //     //         const SizedBox(height: 20),
              //     //         ElevatedButton(
              //     //           onPressed: () {
              //     //             _uploadImage();
              //     //             setState(() {
              //     //               _searching = true;
              //     //             });
              //     //           },
              //     //           child: const Text('Upload Image'),
              //     //         ),
              //     //         const SizedBox(height: 15),
              //     //         if (_searching) const CircularProgressIndicator(),
              //     //         if (fetchImageUrl.isNotEmpty && _searching)
              //     //           const SizedBox(height: 10),
              //     //         const Text(
              //     //           'Searching for similar faces',
              //     //           style: TextStyle(color: Colors.white, fontSize: 12),
              //     //         ),
              //     //         const SizedBox(height: 10),
              //     //         Container(
              //     //           decoration: BoxDecoration(
              //     //             borderRadius: BorderRadius.circular(10),
              //     //             boxShadow: [
              //     //               BoxShadow(
              //     //                 color: Colors.grey.withOpacity(0.5),
              //     //                 spreadRadius: 2,
              //     //                 blurRadius: 5,
              //     //                 offset: const Offset(0, 2),
              //     //               ),
              //     //             ],
              //     //           ),
              //     //           child: ClipRRect(
              //     //             borderRadius: BorderRadius.circular(10),
              //     //             child: fetchImageUrl.isNotEmpty
              //     //                 ? Image.network(
              //     //                     fetchImageUrl,
              //     //                     height: 200,
              //     //                   )
              //     //                 : const SizedBox(),
              //     //           ),
              //     //         ),
              //     //       ],
              //     //     ),
              //     //   ),
              //     // ),
            ],
          ),
        ),
      ),
    );
  }
}
