import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'view_res_screen.dart';

class MyReqScreen extends StatefulWidget {
  const MyReqScreen({Key? key}) : super(key: key);

  @override
  State<MyReqScreen> createState() => _MyReqScreenState();
}

class _MyReqScreenState extends State<MyReqScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "My Requests",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
            .where("userId", isEqualTo: user!.uid)
            .orderBy("time", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No SOS requests yet",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final int responseCount = (data["respondedBy"] is List)
                  ? data["respondedBy"].length
                  : 0;

              return _buildRequestCard(
                requestId: doc.id,
                bloodGroup: data["bloodType"] ?? "N/A",
                area: data["area"] ?? "Unknown area",
                hospital: data["hospital"] ?? "Unknown hospital",
                responseCount: responseCount,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestCard({
    required String requestId,
    required String bloodGroup,
    required String area,
    required String hospital,
    required int responseCount,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Text(
              "SOS Blood Request",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),

          _rowItem(Icons.bloodtype, "REQUIRED BLOOD", bloodGroup),

          _divider(),

          _rowItem(Icons.location_on, "LOCATION", "$area, $hospital"),

          _divider(),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.people, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "$responseCount Donors Responded",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                ElevatedButton(
                  onPressed: responseCount == 0
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ViewResScreen(requestId: requestId),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("View Response"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, color: Colors.red),
          const SizedBox(width: 8),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(height: 1, color: Colors.grey.shade300);
  }
}
