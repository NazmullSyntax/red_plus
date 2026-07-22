import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_app/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  File? _profileImage;
  String? userName;

  User? get user => _auth.currentUser;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  // 🔥 FETCH USER NAME FROM FIRESTORE
  Future<void> fetchUserData() async {
    if (user == null) return;

    final doc = await _firestore.collection("users").doc(user!.uid).get();

    if (doc.exists) {
      setState(() {
        userName = doc.data()?["username"];
      });
    }
  }

  // 📷 Pick image
  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  // 🖼 Bottom Sheet
  void showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 🚪 Logout
  Future<void> logout() async {
    await _auth.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String email = user?.email ?? "";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // 👤 Profile Image
              Stack(
                children: [
                  CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : const AssetImage(
                                "assets/images/profile_placeholder.png",
                              )
                              as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: showImagePickerOptions,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 👤 REAL USER NAME (FROM FIRESTORE)
              Text(
                userName ?? "Loading...",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // 📧 Email
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.cyan.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(email, style: const TextStyle(fontSize: 14)),
              ),

              const SizedBox(height: 30),

              // 🔧 Menu Items
              buildMenuItem(
                icon: Icons.edit,
                title: "Edit Profile",
                onTap: () {
                  // 🔜 Later
                },
              ),
              buildMenuItem(
                icon: Icons.language,
                title: "Language",
                onTap: () {},
              ),
              buildMenuItem(
                icon: Icons.settings,
                title: "Settings",
                onTap: () {},
              ),
              buildMenuItem(
                icon: Icons.help_outline,
                title: "Help & Support",
                onTap: () {},
              ),

              // 🚪 Logout
              buildMenuItem(
                icon: Icons.logout,
                title: "Logout",
                titleColor: Colors.red,
                iconColor: Colors.red,
                onTap: logout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMenuItem({
    required IconData icon,
    required String title,
    Color iconColor = Colors.teal,
    Color titleColor = Colors.black,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red.shade100),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 16, color: titleColor),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
