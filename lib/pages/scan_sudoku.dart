import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/foundation.dart';
import 'package:puzzlepro_app/pages/upload_image.dart';

class ImageProcessingPage extends StatefulWidget {
  const ImageProcessingPage({super.key, required this.handleScreenChange});
  final Function(int, String) handleScreenChange;

  @override
  State<ImageProcessingPage> createState() => _ImageProcessingPageState();
}

class _ImageProcessingPageState extends State<ImageProcessingPage> {
  late final ColorScheme _colorScheme = Theme.of(context).colorScheme;
  XFile? _pickedFile;
  CroppedFile? _croppedFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    if (_croppedFile != null || _pickedFile != null) {
      return _imageCard();
    } else {
      return _uploaderCard();
    }
  }

  Widget _imageCard() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: kIsWeb ? 24.0 : 16.0),
            child: Card(
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(kIsWeb ? 24.0 : 16.0),
                child: _image(),
              ),
            ),
          ),
          const SizedBox(height: 24.0),
          _menu(),
        ],
      ),
    );
  }

  Widget _image() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    if (_croppedFile != null) {
      final path = _croppedFile!.path;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 0.6 * screenWidth,
          maxHeight: 0.4 * screenHeight,
        ),
        child: Image.file(File(path)),
      );
    } else if (_pickedFile != null) {
      final path = _pickedFile!.path;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 0.6 * screenWidth,
          maxHeight: 0.4 * screenHeight,
        ),
        child: Image.file(File(path)),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _menu() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: "delete button",
          onPressed: () {
            _clear();
          },
          backgroundColor: _colorScheme.onSecondary,
          tooltip: 'Delete',
          child: const Icon(Icons.delete, color: Colors.red),
        ),
        if (_croppedFile == null)
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: FloatingActionButton(
              heroTag: "crop button",
              onPressed: () {
                _cropImage();
              },
              backgroundColor: _colorScheme.onSecondary,
              tooltip: 'Crop',
              child: Icon(Icons.crop, color: _colorScheme.primary),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: FloatingActionButton(
            heroTag: "save button",
            onPressed: () {
              _saveAndProceed();
            },
            backgroundColor: _colorScheme.onSecondary,
            tooltip: 'Save',
            child: const Icon(Icons.check_rounded, color: Colors.green),
          ),
        )
      ],
    );
  }

  Widget _uploaderCard() {
    return Center(
        child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 10.0),
            child: Text(
              'SudokuLens by PuzzlePro Sudoku Recogniser',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 130.0),
          ElevatedButton.icon(
            onPressed: () {
              _captureImage(context);
            },
            icon: const Icon(
              Icons.camera_alt,
              size: 30,
            ),
            label: const Text(
              'Capture from Camera',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(330, 80), // Set the button size
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              await _pickImageFromGallery(context);
            },
            icon: const Icon(
              Icons.photo,
              size: 30,
            ),
            label: const Text(
              'Choose Image',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(250, 80), // Set the button size
            ),
          ),
        ],
      ),
    ));
  }

  Future<void> _cropImage() async {
    if (_pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _pickedFile!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Crop and Rotate',
              toolbarColor: _colorScheme.background,
              toolbarWidgetColor: _colorScheme.primary,
              dimmedLayerColor: _colorScheme.background.withOpacity(0.8),
              cropGridColor: _colorScheme.primary,
              cropFrameColor: _colorScheme.primary,
              statusBarColor: _colorScheme.background,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: false),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          _croppedFile = croppedFile;
        });
      }
    }
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
      });
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image picking canceled'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _clear() {
    setState(() {
      _pickedFile = null;
      _croppedFile = null;
    });
  }

  Future<void> _captureImage(BuildContext context) async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
      });
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image capture canceled'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Route _uploadPageRoute(bytes) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => UploadImagePage(
        image: bytes,
        handleScreenChange: widget.handleScreenChange,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        // Adding a fade transition along with the slide transition
        var fadeTween = Tween<double>(begin: 0.0, end: 1.0);
        var fadeAnimation = animation.drive(fadeTween);

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: animation.drive(tween),
            child: child,
          ),
        );
      },
    );
  }

  void _saveAndProceed() async {
    String imagePath = "someRandomPath";
    if (_croppedFile == null) {
      imagePath = _pickedFile!.path;
    } else {
      imagePath = _croppedFile!.path;
    }
    final bytes = File(imagePath).readAsBytesSync();

    Navigator.push(context, _uploadPageRoute(bytes));
  }
}
