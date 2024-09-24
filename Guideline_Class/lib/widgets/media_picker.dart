import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({
    super.key,
    required this.onpickimage,
  });
  final void Function(File pickimage) onpickimage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImage;
  void pickImage() async {
    final selectedImage = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50, maxWidth: 150);
    if (selectedImage == null) {
      return;
    }
    setState(() {
      _pickedImage = File(selectedImage.path);
    });

    widget.onpickimage(_pickedImage!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 100,
          child: CircleAvatar(
            maxRadius: 200,
            foregroundImage:
                _pickedImage != null ? FileImage(_pickedImage!) : null,
            backgroundColor: const Color.fromARGB(255, 189, 220, 215),
          ),
        ),
        TextButton.icon(
          onPressed: pickImage,
          label: const Text('Profile'),
          icon: const Icon(Icons.camera),
        )
      ],
    );
  }
}
