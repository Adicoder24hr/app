// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  // final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: const [
          SizedBox(
            // child: DrawerHeader(
            //   decoration: BoxDecoration(
            //     color: Theme.of(context).primaryColor,
            //   ),
            //   margin: const EdgeInsets.all(0.0),
            //   padding: const EdgeInsets.all(0.0),
            //   child: Text(
            //     _auth.currentUser!.email ?? "",
            //     textAlign: TextAlign.start,
            //     style: const TextStyle(color: Colors.white),
            //   ),
            // ),
            height: 50,
          ),
          ListTile(
            title: Text("data"),
          ),
          ListTile(
            title: Text("data"),
          )
        ],
      ),
    );
  }
}
