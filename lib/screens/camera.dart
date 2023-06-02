import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
void main() {
  runApp(const TfliteModel());
}

class TfliteModel extends StatefulWidget {
  const TfliteModel({Key? key}) : super(key: key);

  @override
  _TfliteModelState createState() => _TfliteModelState();
}

class _TfliteModelState extends State<TfliteModel> {

  late File _image;
  late List _results;
  bool imageSelect = false;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future loadModel() async {
    Tflite.close();
    String res;
    res = (await Tflite.loadModel(
        model: "assets/my_model.tflite", labels: "assets/label.txt"))!;
    if (kDebugMode) {
      print("Models loading status: $res");
    }
  }

  Future imageClassification(File image) async {
    final List? recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _results = recognitions!;
      _image = image;
      imageSelect = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image selection"),

      ),
      body: ListView(
        children: [
          (imageSelect) ? Container(
            margin: const EdgeInsets.all(10),
            child: Image.file(_image),
          ) : Container(
            margin: const EdgeInsets.all(10),
            child: const Opacity(
              opacity: 0.8,
              child: Center(
                child: Text("No image selected"),

              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: (imageSelect) ? _results.map((result) {
                return Card(
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: Text(
                      "${result['label']} - ${result['confidence']
                          .toStringAsFixed(2)}",
                      style: const TextStyle(color: Colors.red,
                          fontSize: 18),
                    ),
                  ),
                );
              }).toList() : [],

            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Select image from:'),
                actions: [
                  TextButton(
                    child: Text('Camera'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  TextButton(
                    child: Text('Gallery'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add_a_photo),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage == null) return;

    setState(() {
      _image = File(pickedImage.path);
    });

    await imageClassification(_image);
  }

}
