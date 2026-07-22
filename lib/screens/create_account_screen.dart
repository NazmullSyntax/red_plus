import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'otp_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  String? selectedBloodGroup;
  String? selectedAddress;
  String? selectedAge;
  DateTime? lastDonationDate;

  bool isPasswordHidden = true;
  bool acceptedTerms = false;
  bool isLoading = false;

  // 🔁 OTP RESEND CONTROL
  bool canSendOtp = true;
  Timer? otpTimer;
  int otpCooldown = 60;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final bloodGroups = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];
  final addresses = [
    "Mirpur",
    "Uttara",
    "Dhanmondi",
    "Motijheel",
    "Badda",
    "Gulshan",
    "Banani",
    "Mohammadpur",
  ];

  // ---------------- DATE PICKER ----------------
  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => lastDonationDate = picked);
    }
  }

  // ---------------- CHECK PHONE EXISTS ----------------
  Future<bool> _isPhoneAlreadyRegistered(String phone) async {
    final result = await _firestore
        .collection("users")
        .where("phone", isEqualTo: phone)
        .limit(1)
        .get();

    return result.docs.isNotEmpty;
  }

  // ---------------- OTP COOLDOWN ----------------
  void _startOtpCooldown() {
    canSendOtp = false;
    otpCooldown = 60;

    otpTimer?.cancel();
    otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (otpCooldown == 0) {
        timer.cancel();
        setState(() => canSendOtp = true);
      } else {
        setState(() => otpCooldown--);
      }
    });
  }

  // ---------------- SEND OTP ----------------
  Future<void> sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    if (!acceptedTerms) {
      showMessage("Please accept terms & privacy policy");
      return;
    }

    if (!canSendOtp) {
      showMessage("Please wait $otpCooldown seconds before resending OTP");
      return;
    }

    String phone = phoneController.text.trim();
    if (phone.startsWith("0")) phone = phone.substring(1);
    phone = "+880$phone";

    setState(() => isLoading = true);

    // 🔒 CHECK DUPLICATE PHONE
    bool exists = await _isPhoneAlreadyRegistered(phone);
    if (exists) {
      showMessage("This phone number is already registered");
      setState(() => isLoading = false);
      return;
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),

      verificationCompleted: (cred) async {
        await _createAccount(cred);
      },

      verificationFailed: (e) {
        showMessage(e.message ?? "OTP failed");
        setState(() => isLoading = false);
      },

      codeSent: (verificationId, _) async {
        setState(() => isLoading = false);
        _startOtpCooldown();

        final credential = await Navigator.push<PhoneAuthCredential>(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreen(verificationId: verificationId),
          ),
        );

        if (credential != null) {
          await _createAccount(credential);
        }
      },

      codeAutoRetrievalTimeout: (_) {},
    );
  }

  // ---------------- CREATE ACCOUNT ----------------
  Future<void> _createAccount(PhoneAuthCredential phoneCred) async {
    try {
      setState(() => isLoading = true);

      // 1️⃣ SIGN IN WITH PHONE (OTP VERIFIED)
      UserCredential phoneUser = await _auth.signInWithCredential(phoneCred);
      User user = phoneUser.user!;

      // 2️⃣ LINK EMAIL + PASSWORD
      final emailCred = EmailAuthProvider.credential(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      await user.linkWithCredential(emailCred);

      // 3️⃣ SAVE USER DATA
      await _firestore.collection("users").doc(user.uid).set({
        "username": usernameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": user.phoneNumber,
        "bloodGroup": selectedBloodGroup,
        "age": selectedAge,
        "address": selectedAddress,
        "lastDonationDate": lastDonationDate?.toIso8601String(),
        "createdAt": Timestamp.now(),
      });

      showMessage("Account created successfully");
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      showMessage(e.message ?? "Registration failed");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Icon(Icons.bloodtype, size: 60, color: Colors.red),
              const SizedBox(height: 10),
              const Text(
                "Create an Account",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 25),

              fieldLabel("USERNAME"),
              input(usernameController, "Adam"),

              fieldLabel("YOUR E-MAIL"),
              input(emailController, "redpulse@gmail.com"),

              fieldLabel("PHONE NUMBER"),
              input(phoneController, "01XXXXXXXX"),

              fieldLabel("BLOOD GROUP"),
              dropdown(bloodGroups, (v) => selectedBloodGroup = v),

              fieldLabel("AGE"),
              dropdown(
                List.generate(63, (i) => "${i + 18}"),
                (v) => selectedAge = v,
              ),

              fieldLabel("ADDRESS"),
              dropdown(addresses, (v) => selectedAddress = v),

              fieldLabel("LAST DONATION DATE"),
              dateField(),

              fieldLabel("PASSWORD"),
              passwordField(),

              Row(
                children: [
                  Checkbox(
                    value: acceptedTerms,
                    onChanged: (v) => setState(() => acceptedTerms = v!),
                  ),
                  const Expanded(
                    child: Text(
                      "i accept terms and conditions and privacy policy",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : sendOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Register Now",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- WIDGETS ----------------
  Widget fieldLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget input(TextEditingController c, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        validator: (v) => v!.isEmpty ? "Required" : null,
        decoration: inputDecoration(hint),
      ),
    );
  }

  Widget dropdown(List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? "Required" : null,
        decoration: inputDecoration("select"),
      ),
    );
  }

  Widget dateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: pickDate,
        child: InputDecorator(
          decoration: inputDecoration(
            "DD/MM/YY",
          ).copyWith(suffixIcon: const Icon(Icons.calendar_month)),
          child: Text(
            lastDonationDate == null
                ? "DD/MM/YY"
                : "${lastDonationDate!.day}/${lastDonationDate!.month}/${lastDonationDate!.year}",
          ),
        ),
      ),
    );
  }

  Widget passwordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: passwordController,
        obscureText: isPasswordHidden,
        validator: (v) => v!.length < 6 ? "Min 6 characters" : null,
        decoration: inputDecoration("********").copyWith(
          suffixIcon: IconButton(
            icon: Icon(
              isPasswordHidden ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () =>
                setState(() => isPasswordHidden = !isPasswordHidden),
          ),
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
