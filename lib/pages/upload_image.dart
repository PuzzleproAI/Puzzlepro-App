import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:core';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:puzzlepro_app/models/sudoku.dart';
import 'package:puzzlepro_app/pages/sudoku_home.dart';
import 'package:puzzlepro_app/services/database.dart';

class UploadImagePage extends StatefulWidget {
  final Uint8List image;

  const UploadImagePage({super.key, required this.image});

  @override
  State<UploadImagePage> createState() => _UploadImagePageState();
}

class _UploadImagePageState extends State<UploadImagePage> {
  bool _isUploading = false;
  int _uploadProgress = 0;
  int _uploadedSize = 0;
  int _totalSize = 0;
  String error = "";
  bool isHavingHandwrittenDigits = false;
  bool isLocalHost = false;

  @override
  void initState() {
    super.initState();
    calculateUploadSize();
  }

  void calculateUploadSize() {
    setState(() {
      _totalSize = widget.image.length;
    });
  }

  Future<void> _uploadImage() async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
      _uploadedSize = 0;
    });
    try {
      HttpClient httpClient = HttpClient();
      // var url =
      //     'https://puzzlepro-backend-release-0-1.onrender.com/generate-sudoku-matrix';
      // var url = "http://10.0.2.2:8000/generate-sudoku-matrix";
      String url;
      if (isLocalHost) {
        url =
            'http://10.0.2.2:8000/${isHavingHandwrittenDigits ? "generate-sudoku-matrix-for-mixed" : "generate-sudoku-matrix"}';
      } else {
        url =
            'https://puzzlepro.azurewebsites.net/${isHavingHandwrittenDigits ? "generate-sudoku-matrix-for-mixed" : "generate-sudoku-matrix"}';
      }
      String imageBase64 = base64Encode(widget.image);
      var jsonBody = {"base64_image": "data:image/jpg;base64,$imageBase64"};
      var body = json.encode(jsonBody);
      Stream<String> stream = Stream.value(body);

      HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));

      setState(() {
        _totalSize = body.length;
      });
      Stream<List<int>> streamUpload =
          stream.transform(StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          setState(() {
            _uploadedSize += data.length;
            _uploadProgress = ((_uploadedSize * 100) / _totalSize).round();
          });
        },
        handleDone: (sink) {
          sink.close();
        },
        handleError: (error, stackTrace, sink) {
          throw error;
        },
      ));
      request.headers
          .set("Content-Type", "application/json", preserveHeaderCase: true);

      String authToken =
          'Basic ${base64Encode(utf8.encode('puzzleProAdmin:willBeChangedOnDeployment'))}';
      request.headers.set("Authorization", authToken, preserveHeaderCase: true);
      request.add(utf8.encode(body));
      await request.addStream(streamUpload);

      HttpClientResponse response = await request.close();
      String jsonResponse = "someNull";
      if (response.statusCode == 200) {
        response
            .listen((event) => jsonResponse = utf8.decode(event))
            .onDone(() {
          Map<String, dynamic> parsedJson = json.decode(jsonResponse);

          List<List<int>> matrix = (json.decode(parsedJson['matrix']) as List)
              .map((row) => List<int>.from(row))
              .toList();
          if (!context.mounted) return;
          Sudoku sudoku = Sudoku(matrix, true, "NA");
          StorageHelper.saveSudoku(sudoku).then((value) => Navigator.push(
                  context, MaterialPageRoute(builder: (BuildContext context) {
                return SudokuHome(
                  index: value,
                );
              })));
        });
      } else {
        setState(() {
          error = "bad request";
        });
      }
    } catch (error) {
      setState(() {
        this.error = 'Error during image upload: $error';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Upload Image",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 27.0,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: _uploadProgress / 100,
              minHeight: 20,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 10),
            Text(
              '$_uploadProgress% Uploaded',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Uploaded Size: ${(_uploadedSize / (1024 * 1024)).toStringAsFixed(2)} MB',
            ),
            const SizedBox(height: 10),
            Text(
              'Total Size: ${(_totalSize / (1024 * 1024)).toStringAsFixed(2)} MB',
            ),
            const SizedBox(height: 20),
            CheckboxListTile(
              title: const Text("My image contains handwritten digits."),
              value: isHavingHandwrittenDigits,
              onChanged: (newValue) {
                setState(() {
                  isHavingHandwrittenDigits = newValue!;
                });
              },
              controlAffinity:
                  ListTileControlAffinity.leading, //  <-- leading Checkbox
            ),
            const SizedBox(height: 20),
            CheckboxListTile(
              title: const Text("Use local host."),
              value: isLocalHost,
              onChanged: (newValue) {
                setState(() {
                  isLocalHost = newValue!;
                });
              },
              controlAffinity:
                  ListTileControlAffinity.leading, //  <-- leading Checkbox
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadImage,
              child: _isUploading
                  ? const SizedBox(
                      width: 20, height: 20, child: CircularProgressIndicator())
                  : const Text('Upload Image'),
            ),
            const SizedBox(height: 20),
            if (_uploadProgress == 100)
              const Text(
                'Recognising image',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
