import 'package:app/Components/myappbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Image.network(
                "https://images.unsplash.com/photo-1615461066159-fea0960485d5",
                width: MediaQuery.of(context).size.width,
              ),
              const SizedBox(
                height: 20,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Donating blood is an extraordinary act of kindness and generosity that can truly make a difference. By giving the gift of life through blood donation, you are offering a precious resource that can save lives and provide hope to those in need. Each donation can help patients undergoing surgeries, recovering from accidents, or battling serious illnesses. The impact of this simple yet profound gesture cannot be overstated, as it directly contributes to the well-being and recovery of countless individuals. Embrace the opportunity to be a hero and give the gift of life through blood donation.",
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 17),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    FilledButton.icon(
                      onPressed: () {
                        GoRouter.of(context).go("/login");
                      },
                      label: const Text("Login"),
                      icon: const Icon(Icons.person),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () {
                        GoRouter.of(context).go("/register");
                      },
                      label: const Text("Register"),
                      icon: const Icon(Icons.person),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
