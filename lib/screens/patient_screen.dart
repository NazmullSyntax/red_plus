import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'create_post_screen.dart';
import 'my_req_screen.dart';
import 'send_sos_screen.dart';

class PatientScreen extends StatefulWidget {
  const PatientScreen({Key? key}) : super(key: key);

  @override
  State<PatientScreen> createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  int _selectedIndex = 2; // Feed selected by default

  String profilePic = "";
  String username = "";
  bool isUserLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if (!mounted) return;

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;

      setState(() {
        username = data.containsKey("username") ? data["username"] ?? "" : "";
        profilePic = data.containsKey("profilePic")
            ? data["profilePic"] ?? ""
            : "";
        isUserLoading = false;
      });
    }
  }

  // ---------------- BOTTOM NAV ----------------
  void _onNavTapped(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MyReqScreen()),
      ).then((_) {
        if (mounted) setState(() => _selectedIndex = 2);
      });
      return;
    }

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SendSosScreen()),
      ).then((_) {
        if (mounted) setState(() => _selectedIndex = 2);
      });
      return;
    }

    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Row(
          children: const [
            Icon(Icons.bloodtype, color: Colors.red, size: 24),
            SizedBox(width: 6),
            Text(
              "RedPulse",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          _buildPostComposer(),
          Container(height: 8, color: Colors.grey.shade300),
          _buildFeed(),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        onTap: _onNavTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: "My Request",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.emergency), label: "SOS"),
          BottomNavigationBarItem(icon: Icon(Icons.rss_feed), label: "Feed"),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: "Donors",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Nearby"),
        ],
      ),
    );
  }

  // ---------------- POST COMPOSER ----------------
  Widget _buildPostComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: profilePic.isNotEmpty
                ? NetworkImage(profilePic)
                : null,
            child: profilePic.isEmpty
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreatePostScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.grey.shade200,
                ),
                child: Text(
                  isUserLoading
                      ? "Loading..."
                      : "What's on your mind, $username?",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- FEED ----------------
  Widget _buildFeed() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("posts")
            .orderBy("time", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No posts yet...",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final post =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return _buildPostItem(post);
            },
          );
        },
      ),
    );
  }

  Widget _buildPostItem(Map<String, dynamic> post) {
    final String postProfilePic = post["profilePic"] ?? "";
    final String postName = post["name"] ?? "Unknown User";
    final String caption = post["caption"] ?? "";
    final image = post["image"];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: postProfilePic.isNotEmpty
                      ? NetworkImage(postProfilePic)
                      : null,
                  child: postProfilePic.isEmpty
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        postName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        _formatTime(post["time"]),
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        caption,
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (image != null && image.toString().isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                image,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(timestamp) {
    if (timestamp == null) return "";
    final DateTime time = timestamp.toDate();
    final Duration diff = DateTime.now().difference(time);

    if (diff.inDays >= 1) return "${diff.inDays} d";
    if (diff.inHours >= 1) return "${diff.inHours} h";
    if (diff.inMinutes >= 1) return "${diff.inMinutes} m";
    return "just now";
  }
}
