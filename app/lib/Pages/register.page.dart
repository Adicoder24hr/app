import 'package:app/Components/myappbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_field_validator/form_field_validator.dart';
import "package:firebase_auth/firebase_auth.dart";
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _auth = FirebaseAuth.instance;
  final _UserCol = FirebaseFirestore.instance;
  String email = "", name = "", phone = "", password = "";
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        await _UserCol.collection('Users').doc(user.uid).set({
          'email': user.email,
          'name': user.displayName,
        }, SetOptions(merge: true));
      }

      return user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: SingleChildScrollView(
              child: Card(
                child: Form(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Sing-in",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            FilledButton(
                              onPressed: () {
                                context.go("/login");
                              },
                              child: const Text("Login"),
                            )
                          ],
                        ),
                        // const Text(
                        //   "Sing-in",
                        //   style: TextStyle(
                        //     fontSize: 24,
                        //     fontWeight: FontWeight.w700,
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: InputText(
                            label: "Email",
                            validator:
                                EmailValidator(errorText: "Email id not valid"),
                            icons: Icon(
                              Icons.email_outlined,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            onChange: (value) {
                              email = value;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: InputText(
                            label: "Name",
                            validator:
                                RequiredValidator(errorText: "Name not valid"),
                            icons: Icon(
                              Icons.person,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            keyboardType: TextInputType.name,
                            onChange: (value) {
                              name = value;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: InputText(
                            label: "Phone No",
                            icons: Icon(
                              Icons.phone,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            validator: PatternValidator(
                                r'^((+|00)?218|0?)?(9[0-9]{8})$',
                                errorText: "Phone no not valid"),
                            keyboardType: TextInputType.phone,
                            onChange: (value) {
                              phone = value;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: InputText(
                            label: "Password",
                            icons: Icon(
                              Icons.password,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            validator: PatternValidator(r'(?=.*?[#?!@$%^&*-])',
                                errorText:
                                    'passwords must have at least one special character'),
                            keyboardType: TextInputType.text,
                            onChange: (value) {
                              password = value;
                            },
                          ),
                        ),
                        Row(
                          children: [
                            FilledButton.icon(
                              onPressed: () async {
                                try {
                                  final user = await _signInWithGoogle();
                                  if (user == null) {
                                    throw Error();
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          "Your account as be created"),
                                      action: SnackBarAction(
                                        label: "Go to dashboard",
                                        onPressed: ScaffoldMessenger.of(context)
                                            .hideCurrentMaterialBanner,
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          "Internal server error try again"),
                                      action: SnackBarAction(
                                        label: "OK",
                                        onPressed: ScaffoldMessenger.of(context)
                                            .hideCurrentMaterialBanner,
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: const FaIcon(FontAwesomeIcons.google),
                              label: const Text("Google"),
                            ),
                            const Spacer(),
                            FilledButton.icon(
                              onPressed: () async {
                                try {
                                  final user = await _auth
                                      .createUserWithEmailAndPassword(
                                          email: email, password: password);
                                  // ignore: unnecessary_null_comparison
                                  if (user == null) {
                                    throw Error();
                                  }
                                  await _UserCol.collection("Users")
                                      .doc(user.user!.uid.toString())
                                      .set({
                                    "name": name,
                                    "phone": phone,
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          "Your account as be created"),
                                      action: SnackBarAction(
                                        label: "Go to dashboard",
                                        onPressed: () {
                                          context.go("/home");
                                        },
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          "Internal server error try again"),
                                      action: SnackBarAction(
                                        label: "OK",
                                        onPressed: ScaffoldMessenger.of(context)
                                            .hideCurrentMaterialBanner,
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.person),
                              label: const Text("Sign-in"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InputText extends StatelessWidget {
  final String label;
  final Icon icons;
  final TextFieldValidator validator;
  final TextInputType keyboardType;
  final Function(String) onChange;
  const InputText(
      {required this.label,
      required this.icons,
      required this.validator,
      required this.keyboardType,
      required this.onChange});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(20),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(50),
          ),
        ),
        labelText: label,
        prefixIcon: icons,
      ),
      validator: validator.call,
      keyboardType: keyboardType,
      onChanged: onChange,
    );
  }
}
