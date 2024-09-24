import 'package:image_picker/image_picker.dart';

class ChatField {
  final String text;

  final bool currentuser;
  final XFile? image;
  ChatField(
      {required this.text, required this.image, required this.currentuser});
}
