import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_year_project/Resources/googleApi.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:final_year_project/Resources/constant.dart';
import 'package:final_year_project/Resources/item_widget.dart';
import 'package:final_year_project/model/items_List.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:place_picker_google/place_picker_google.dart';

class HomePageBody extends StatefulWidget {

  HomePageBody({super.key});

  @override
  State<HomePageBody> createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  final String currentUserEmail = FirebaseAuth.instance.currentUser!.email!;

  LatLng? selectedLocation;

  final currentUser = FirebaseAuth.instance.currentUser!;

  Future<void> _pickLocation() async {
    try {
      final LocationResult? result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Theme(
            data: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: PrimaryColor,
              primaryColor: PrimaryColor,
              hintColor: PrimaryColor,
              textTheme: TextTheme(
                bodyLarge: TextStyle(color: SecondaryColor),
                bodyMedium: TextStyle(color: SecondaryColor),
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.black,
                iconTheme: IconThemeData(color: SecondaryColor),
                titleTextStyle: TextStyle(color: SecondaryColor, fontSize: 20),
              ),
              inputDecorationTheme: InputDecorationTheme(
                hintStyle: TextStyle(color: SecondaryColor),
                filled: true,
                fillColor: Colors.black,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: SecondaryColor),
                ),
              ),
            ),
            child: PlacePicker(
              initialLocation: LatLng(3.1025622508964545, 101.63749811950501),
              apiKey: google_api_key,
              searchInputDecorationConfig: SearchInputDecorationConfig(
                hintText: 'Search for a place',
              ),
              onPlacePicked: (result) {
                Navigator.of(context).pop(result);
                Navigator.pushReplacementNamed(context, 'home');
              },
            ),
          ),
        ),
      );

      if (result != null && result.latLng != null) {
        setState(() {
          selectedLocation =
              LatLng(result.latLng!.latitude, result.latLng!.longitude);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
                "Location selected: ${selectedLocation!.latitude}, ${selectedLocation!.longitude}"),
          ),
        );

        // Automatically save the location
        await _saveLocation();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text("No location selected"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking location: $e")),
      );
    }
  }

 Future<void> _saveLocation() async {
  if (selectedLocation != null) {
    try {
      // Get the current user's email
      String? userEmail = FirebaseAuth.instance.currentUser?.email;
      if (userEmail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not logged in!")),
        );
        return;
      }

      // Get the address from the coordinates (latitude and longitude)
      List<Placemark> placemarks = await placemarkFromCoordinates(
        selectedLocation!.latitude,
        selectedLocation!.longitude,
      );

      if (placemarks.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No address found for the location")),
        );
        return;
      }

      Placemark placemark = placemarks.first;

      // Construct full address with null safety
      String fullAddress = [
        placemark.name,
        placemark.street,
        placemark.subLocality,
        placemark.locality,
        placemark.administrativeArea,
        placemark.postalCode,
        placemark.country
      ].where((element) => element != null && element.isNotEmpty).join(', ');

      if (fullAddress.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Address could not be determined")),
        );
        return;
      }

      // Save location and address to Firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.email)
          .collection('Location')
          .doc('doc')
          .set({
        'latitude': selectedLocation!.latitude,
        'longitude': selectedLocation!.longitude,
        'address': fullAddress,  // Save the full address
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location and address saved")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving location: $e")),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please select a location first.")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Promotion widget
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: 300.0,
                    height: 180.0,
                    child: InkWell(
                      child: Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        elevation: 5,
                        margin: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Text(
                              'Choose Location',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: PrimaryColor,
                                fontSize: 15,
                              ),
                            ),
                            // Updated: Listen to real-time address changes
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(currentUserEmail)
                                  .collection('Location')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                }

                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }

                                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                  return Text('No address found');
                                }

                                // Fetch the first document's address
                                var address = snapshot.data!.docs.first['address'] ?? 'No address found';

                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                   " $address.",
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        _pickLocation();
                       
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Services widget
            Container(
              padding: EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: PrimaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(right: 20, left: 15, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Services',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    itemCount: catalog.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(), // Prevents scrolling issues
                    itemBuilder: (context, index) => ItemWidget(
                      item: catalog[index],
                      isCartItems: false,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
