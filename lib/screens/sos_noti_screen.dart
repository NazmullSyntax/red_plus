import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class SosNotiScreen extends StatefulWidget {
  const SosNotiScreen({super.key});

  @override
  State<SosNotiScreen> createState() => _SosNotiScreenState();
}

class _SosNotiScreenState extends State<SosNotiScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  void _refresh() => setState(() {});

  Future<void> _respond(String docId) async {
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection("sos_requests")
        .doc(docId)
        .update({
          "respondedBy": FieldValue.arrayUnion([user!.uid]),
        });
  }

  void _call(String phone) async {
    final uri = Uri.parse("tel:$phone");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<String> _getUsername(String uid) async {
    final snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();
    return snap.data()?["username"] ?? "Unknown";
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Not logged in")));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "SOS Requests",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _refresh,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("sos_requests")
            .orderBy("time", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data["userId"] != user!.uid;
          }).toList();

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No SOS requests available",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final respondedBy = List<String>.from(data["respondedBy"] ?? []);
              final hasResponded = respondedBy.contains(user!.uid);

              return FutureBuilder<String>(
                future: _getUsername(data["userId"]),
                builder: (context, snap) {
                  return _sosCard(
                    docId: doc.id,
                    patientId: data["userId"],
                    patientName: snap.data ?? "Loading...",
                    phone: data["phone"] ?? "",
                    blood: data["bloodType"] ?? "N/A",
                    location:
                        "${data["area"] ?? ""}, ${data["hospital"] ?? ""}",
                    time: data["time"],
                    responses: respondedBy.length,
                    hasResponded: hasResponded,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _sosCard({
    required String docId,
    required String patientId,
    required String patientName,
    required String phone,
    required String blood,
    required String location,
    required dynamic time,
    required int responses,
    required bool hasResponded,
  }) {
    final chatId = "${docId}_${user!.uid}";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Text(
              "Emergency Blood Request",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _info("REQUESTED BY", patientName),
          _info("REQUIRED BLOOD", blood),
          _info("LOCATION", location),
          _info("TIME", _formatTime(time)),
          _info("RESPONSES", responses.toString()),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: hasResponded
                        ? const Icon(Icons.check)
                        : const Icon(Icons.favorite_border),
                    label: Text(hasResponded ? "Responded" : "Respond"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasResponded ? Colors.green : Colors.red,
                    ),
                    onPressed: hasResponded ? null : () => _respond(docId),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chat, color: Colors.blue),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/chat',
                      arguments: {"chatId": chatId, "otherUserId": patientId},
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.call, color: Colors.green),
                  onPressed: phone.isEmpty ? null : () => _call(phone),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  String _formatTime(dynamic time) {
    if (time == null || time is! Timestamp) return "Unknown";
    final diff = DateTime.now().difference(time.toDate());
    if (diff.inDays > 0) return "${diff.inDays} days ago";
    if (diff.inHours > 0) return "${diff.inHours} hours ago";
    if (diff.inMinutes > 0) return "${diff.inMinutes} minutes ago";
    return "Just now";
  }
}
