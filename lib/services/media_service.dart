import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class MediaService {
  final ImagePicker _picker = ImagePicker();

  MediaService();

  Future<File?> getImageFromGallery() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      return _cropImage(file);
    }
    return null;
  }

  Future<File?> takePhoto() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.camera);
    if (file != null) {
      return _cropImage(file);
    }
    return null;
  }

  Future<File?> _cropImage(XFile file) async {
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Edit Image',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Edit Image',
        ),
      ],
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    }
    return null;
  }

  Future<File?> getVideoFromGallery() async {
    final XFile? file = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 30),
    );
    if (file != null) {
      return File(file.path);
    }
    return null;
  }
}
