import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewResScreen extends StatelessWidget {
  final String requestId;
  const ViewResScreen({Key? key, required this.requestId}) : super(key: key);

  void _call(String phone) async {
    if (phone.isEmpty) return;
    final uri = Uri.parse("tel:$phone");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "SOS Status",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("sos_requests")
            .doc(requestId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final List respondedBy = data["respondedBy"] ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _statusCard(respondedBy.length),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "Donor Responses",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: respondedBy.length,
                  itemBuilder: (context, index) {
                    final donorId = respondedBy[index];
                    final chatId = "${requestId}_$donorId";

                    return StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .doc(donorId)
                          .snapshots(),
                      builder: (context, snap) {
                        if (!snap.hasData) return const SizedBox();
                        final donor = snap.data!.data() as Map<String, dynamic>;

                        return _donorCard(context, donorId, chatId, donor);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------------- STATUS CARD ----------------
  Widget _statusCard(int count) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Active",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "$count Donors Responded to your request",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- DONOR CARD ----------------
  Widget _donorCard(
    BuildContext context,
    String donorId,
    String chatId,
    Map<String, dynamic> donor,
  ) {
    final String location =
        donor["address"] ??
        donor["location"] ??
        donor["area"] ??
        "Unknown location";

    final String profilePic = donor["profilePic"] ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          // Header (Avatar + Name + Location)
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: profilePic.isNotEmpty
                    ? NetworkImage(profilePic)
                    : null,
                child: profilePic.isEmpty
                    ? const Icon(Icons.person, color: Colors.white, size: 28)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      donor["username"] ?? "Unknown",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: const TextStyle(color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Buttons
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _pillBtn(Icons.check_circle, "Accept", Colors.green, () {}),
              _pillBtn(Icons.check, "Confirm", Colors.blue, () {}),
              _pillBtn(Icons.close, "Decline", Colors.grey, () {}),

              _pillBtn(Icons.chat, "Chat", Colors.blue, () {
                Navigator.pushNamed(
                  context,
                  '/chat',
                  arguments: {"chatId": chatId, "otherUserId": donorId},
                );
              }),

              _pillBtn(Icons.call, "Call", Colors.green, () {
                _call(donor["phone"] ?? "");
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pillBtn(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
