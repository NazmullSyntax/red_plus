import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  Future<String> _getName() async {
    final snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.otherUserId)
        .get();
    return snap.data()?["username"] ?? "Chat";
  }

  void _send() async {
    if (_msgCtrl.text.trim().isEmpty || user == null) return;

    await FirebaseFirestore.instance
        .collection("chats")
        .doc(widget.chatId)
        .collection("messages")
        .add({
          "text": _msgCtrl.text.trim(),
          "senderId": user!.uid,
          "time": FieldValue.serverTimestamp(),
        });

    _msgCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getName(),
      builder: (context, snap) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.red,
            title: Text(snap.data ?? "Chat"),
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("chats")
                      .doc(widget.chatId)
                      .collection("messages")
                      .orderBy("time")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ListView(
                      padding: const EdgeInsets.all(12),
                      children: snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final isMe = data["senderId"] == user!.uid;

                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.red : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              data["text"],
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _msgCtrl,
                        decoration: const InputDecoration(
                          hintText: "Type message...",
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.red),
                      onPressed: _send,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
