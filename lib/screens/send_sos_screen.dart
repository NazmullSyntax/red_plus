import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SendSosScreen extends StatefulWidget {
  const SendSosScreen({super.key});

  @override
  State<SendSosScreen> createState() => _SendSosScreenState();
}

class _SendSosScreenState extends State<SendSosScreen> {
  String? selectedBloodType;
  String? selectedNeed;
  String? selectedArea;
  String? selectedHospital;
  final TextEditingController phoneCtrl = TextEditingController();

  bool isSubmitting = false;
  bool _popupClosed = false; // ✅ prevents double close

  final List<String> bloodTypes = [
    "A+",
    "A-",
    "B+",
    "B-",
    "AB+",
    "AB-",
    "O+",
    "O-",
  ];

  final List<String> needTypes = [
    "Blood Bag",
    "Plasma",
    "Platelets",
    "Whole Blood",
  ];

  final Map<String, List<String>> hospitalByArea = {
    "Dhanmondi": [
      "Ibn Sina Hospital",
      "Popular Diagnostic Centre",
      "Labaid Hospital",
      "Medinova Medical",
      "Dhanmondi General Hospital",
    ],
    "Uttara": [
      "Uttara Adhunik Hospital",
      "Popular Diagnostic Uttara",
      "Ibn Sina Uttara",
      "Lubana Hospital",
      "Amar Hospital",
      "Crescent Hospital Uttara",
    ],
    "Mohakhali": [
      "ICDDR,B",
      "BRB Hospital",
      "United Hospital",
      "Universal Medical College",
    ],
    "Mirpur": [
      "National Heart Foundation",
      "Mirpur General Hospital",
      "Delta Hospital",
      "Care Hospital",
      "Islamia Hospital",
    ],
    "Banani": [
      "Ahsania Mission Cancer Hospital",
      "Japanese Hospital Dhaka",
      "Banani Clinic",
    ],
    "Bashundhara": [
      "Evercare Hospital",
      "Parkview Hospital",
      "Bashundhara Eye Hospital",
    ],
    "Shyamoli": [
      "Japan Bangladesh Friendship Hospital",
      "Shyamoli Square Hospital",
      "BIRDEM General Hospital",
    ],
    "Malibagh": [
      "Central Hospital",
      "Al-Raji Hospital",
      "Malibagh Community Hospital",
    ],
  };

  Future<void> _submitSOS() async {
    if (selectedBloodType == null ||
        selectedNeed == null ||
        selectedArea == null ||
        selectedHospital == null ||
        phoneCtrl.text.trim().isEmpty) {
      _showMessage("Please fill all fields!");
      return;
    }

    setState(() => isSubmitting = true);

    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection("sos_requests").add({
      "bloodType": selectedBloodType,
      "needType": selectedNeed,
      "area": selectedArea,
      "hospital": selectedHospital,
      "phone": phoneCtrl.text.trim(),
      "userId": user?.uid,
      "time": FieldValue.serverTimestamp(),
    });

    setState(() => isSubmitting = false);
    _showSuccessPopup();
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  // ✅ SUCCESS POPUP WITH BLUR + TAP TO CLOSE
  void _showSuccessPopup() {
    _popupClosed = false;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      builder: (_) {
        return Stack(
          children: [
            GestureDetector(
              onTap: _closePopupEarly,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(color: Colors.transparent),
              ),
            ),
            Center(
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "SOS Sent Successfully",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "We are notifying nearby blood donors",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xffFFF2F2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.red.shade100),
                        ),
                        child: Column(
                          children: [
                            _infoRow("BLOOD GROUP", selectedBloodType!),
                            _divider(),
                            _infoRow("NEED", selectedNeed!),
                            _divider(),
                            _infoRow(
                              "LOCATION",
                              "$selectedArea, $selectedHospital",
                            ),
                            _divider(),
                            _infoRow("PHONE", phoneCtrl.text.trim()),
                            _divider(),
                            _infoRow("TIME", "JUST NOW"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    // ✅ AUTO CLOSE AFTER 3 SECONDS
    Future.delayed(const Duration(seconds: 3), () {
      if (_popupClosed || !mounted) return;
      _popupClosed = true;

      Navigator.of(context).pop(); // close dialog
      Navigator.of(context).pop(); // back to Feed
    });
  }

  // ✅ CLOSE WHEN BLUR IS TAPPED
  void _closePopupEarly() {
    if (_popupClosed || !mounted) return;
    _popupClosed = true;

    Navigator.of(context).pop(); // close dialog
    Navigator.of(context).pop(); // back to Feed
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: "$label: ",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(color: Colors.grey.shade300);

  Widget _buildDropdownLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? selectedValue,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint),
          value: selectedValue,
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F6F6),
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: const Color(0xffF6F6F6),
        elevation: 0,
        title: const Text(
          "Send SOS",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Icon(Icons.error, size: 90, color: Colors.red),
            const SizedBox(height: 30),

            _buildDropdownLabel("BLOOD TYPE"),
            _buildDropdown(
              hint: "select",
              selectedValue: selectedBloodType,
              items: bloodTypes,
              onChanged: (v) => setState(() => selectedBloodType = v),
            ),
            const SizedBox(height: 20),

            _buildDropdownLabel("NEED"),
            _buildDropdown(
              hint: "select",
              selectedValue: selectedNeed,
              items: needTypes,
              onChanged: (v) => setState(() => selectedNeed = v),
            ),
            const SizedBox(height: 20),

            _buildDropdownLabel("LOCATION"),
            _buildDropdown(
              hint: "select area",
              selectedValue: selectedArea,
              items: hospitalByArea.keys.toList(),
              onChanged: (v) {
                setState(() {
                  selectedArea = v;
                  selectedHospital = null;
                });
              },
            ),
            const SizedBox(height: 20),

            _buildDropdownLabel("HOSPITAL"),
            _buildDropdown(
              hint: "select hospital",
              selectedValue: selectedHospital,
              items: selectedArea == null ? [] : hospitalByArea[selectedArea]!,
              onChanged: (v) => setState(() => selectedHospital = v),
            ),
            const SizedBox(height: 20),

            _buildDropdownLabel("PHONE NUMBER"),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: "01XXXXXXXXX",
                filled: true,
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _submitSOS,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Send SOS",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
