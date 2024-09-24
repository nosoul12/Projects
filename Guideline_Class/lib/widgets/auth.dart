import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:student_1/screen/route.dart';
import 'package:student_1/screen/student_input.dart';
import 'package:student_1/widgets/media_picker.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _userEmail = '';
  var _userName = '';
  var _userPassword = '';
  bool _isAuthenticating = false;
  File? _pickedImage;

  void _pickImage(File pickedImage) {
    setState(() {
      _pickedImage = pickedImage;
    });
  }

  Future<void> _trySubmit() async {
    if (_isAuthenticating) return; // Prevent re-entrance

    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    if (!_isLogin && _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick an image.')),
      );
      return;
    }

    _formKey.currentState!.save();
    setState(() {
      _isAuthenticating = true;
    });

    try {
      UserCredential authResult;
      if (_isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
          email: _userEmail,
          password: _userPassword,
        );
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
          email: _userEmail,
          password: _userPassword,
        );

        final ref = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${authResult.user!.uid}.jpg');

        await ref.putFile(_pickedImage!);
        final url = await ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(authResult.user!.uid)
            .set({
          'username': _userName,
          'email': _userEmail,
          'image_url': url,
        });

        await FirebaseFirestore.instance
            .collection('user_images')
            .doc(authResult.user!.uid)
            .set({'image_url': url});

        // Ensure a document is created in the "students" collection
        await FirebaseFirestore.instance
            .collection('students')
            .doc(authResult.user?.uid)
            .set({
          'email': _userEmail,
          'profileCompleted': false,
          'image_url': url,
        });

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const DetailInputScreen(),
          ),
        );
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(authResult.user?.uid)
          .get();

      if (userDoc.exists && userDoc.data()?['profileCompleted'] == true) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const DetailInputScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      var message = 'An error occurred, please check your credentials!';

      if (e.message != null) {
        message = e.message!;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).hoverColor,
        ),
      );
    } catch (error) {
      print('Sign up error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'An unexpected error occurred. Please try again later.'),
          backgroundColor: Theme.of(context).highlightColor,
        ),
      );
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_isLogin) UserImagePicker(onpickimage: _pickImage),
                TextFormField(
                  key: const ValueKey('email'),
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return 'Please enter a valid email address.';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email address'),
                  onSaved: (value) {
                    _userEmail = value!;
                  },
                ),
                if (!_isLogin)
                  TextFormField(
                    key: const ValueKey('username'),
                    validator: (value) {
                      if (value!.isEmpty || value.length < 4) {
                        return 'Please enter at least 4 characters';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(labelText: 'Username'),
                    onSaved: (value) {
                      _userName = value!;
                    },
                  ),
                TextFormField(
                  key: const ValueKey('password'),
                  validator: (value) {
                    if (value!.isEmpty || value.length < 7) {
                      return 'Password must be at least 7 characters long.';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  onSaved: (value) {
                    _userPassword = value!;
                  },
                ),
                const SizedBox(height: 12),
                if (_isAuthenticating) const CircularProgressIndicator(),
                if (!_isAuthenticating)
                  ElevatedButton(
                    onPressed: _trySubmit,
                    child: Text(_isLogin ? 'Login' : 'Signup'),
                  ),
                if (!_isAuthenticating)
                  TextButton(
                    child: Text(_isLogin
                        ? 'Create new account'
                        : 'I already have an account'),
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
