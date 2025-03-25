import 'package:app/Components/drawer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "G1 app",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            labelStyle: TextStyle(color: Colors.white),
            unselectedLabelColor: Colors.white30,
            tabs: [
              Tab(
                child: Text("Donate"),
              ),
              Tab(
                child: Text("Receiver"),
              ),
            ],
          ),
        ),
        drawer: const AppDrawer(),
        body: TabBarView(
          children: [
            Donate(),
            const Receiver(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

class Receiver extends StatelessWidget {
  const Receiver({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [Text("data")],
    );
  }
}

class Donate extends StatefulWidget {
  Donate({super.key});

  @override
  _DonateState createState() => _DonateState();
}

class _DonateState extends State<Donate> {
  final FirebaseFirestore firebaseStore = FirebaseFirestore.instance;
  Position? _currentPosition;
  double _radius = 5; // Radius in kilometers

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });
  }

  double _calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    const p = 0.017453292519943295; // PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lng2 - lng1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: FutureBuilder<QuerySnapshot>(
        future: firebaseStore.collection('hospital').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            print(snapshot.data!.docs);
            return const Center(child: Text('No data available'));
          }

          final documents = snapshot.data!.docs.where((doc) {
            double lat = doc['lat'];
            double lng = doc['lng'];
            return _calculateDistance(_currentPosition!.latitude,
                    _currentPosition!.longitude, lat, lng) <=
                _radius;
          }).toList();

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final doc = documents[index];
              final String name = doc['name'];
              final String address = doc['address'];
              final String phone = doc['phone'];
              final double lat = doc['lat'];
              final double lng = doc['lng'];
              final double distance = _calculateDistance(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                  lat,
                  lng);
              return Card(
                child: ListTile(
                  title: Text(name),
                  subtitle: Text(
                      '$address\nDistance: ${distance.toStringAsFixed(2)} km'),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Text(name),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Text(address),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 50),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: () async {
                                            final Uri url =
                                                Uri(scheme: 'tel', path: phone);
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(url);
                                            } else {
                                              throw 'Could not launch $url';
                                            }
                                          },
                                          icon: const Icon(Icons.call),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          onPressed: () async {
                                            final Uri url =
                                                Uri(scheme: 'sms', path: phone);
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(url);
                                            } else {
                                              throw 'Could not launch $url';
                                            }
                                          },
                                          icon: const Icon(Icons.message),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          onPressed: () async {
                                            final Uri url = Uri(
                                              scheme: 'geo',
                                              path: '0,0',
                                              queryParameters: {
                                                'q':
                                                    '${doc['lat']},${doc['lng']}'
                                              },
                                            );
                                            if (await canLaunchUrl(url)) {
                                              await launchUrl(url);
                                            } else {
                                              throw 'Could not launch $url';
                                            }
                                          },
                                          icon: const Icon(Icons.directions),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
