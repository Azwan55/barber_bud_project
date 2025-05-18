import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:final_year_project/Resources/constant.dart';
import 'package:final_year_project/Resources/googleApi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class OrderTrackingPage extends StatefulWidget {
  final String orderId;

  const OrderTrackingPage({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final currentUser = FirebaseAuth.instance.currentUser!;
  static LatLng barberLocation = LatLng(2.922954879748687, 101.65392407916282);
  LatLng destinationLocation = LatLng(
      2.9387191799806622, 101.6657974213556); // Destination from Firestore

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;
  String? estimatedTime;

  @override
  void initState() {
    super.initState();
    getBarberLocation();
    getDestinationLocation(); // Fetch user's saved location
    setCustomMarkerIcon();
  }

  // Fetch user's destination location from Firestore
  void getDestinationLocation() async {
    DocumentSnapshot locationDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.email)
        .collection('Location')
        .doc('doc') // Assuming the document ID is 'doc'
        .get();

    if (locationDoc.exists) {
      double latitude = (locationDoc['latitude']).toDouble();
      double longitude = (locationDoc['longitude']).toDouble();

      setState(() {
        destinationLocation = LatLng(latitude, longitude);
        destinationIcon = BitmapDescriptor.defaultMarker;
      });

      getPolyPoints(); // Call polyline update once destination is set
      getEstimatedArrivalTime(); // Get the estimated time after setting the destination
    }
  }

  void getBarberLocation() async {
    Location location = Location();

    location.getLocation().then((location) {
      setState(() {
        currentLocation = location;
      });
    });

    GoogleMapController getMapController = await _controller.future;

    location.onLocationChanged.listen((newLocation) {
      setState(() {
        currentLocation = newLocation;
      });

      getMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(newLocation.latitude!, newLocation.longitude!),
            zoom: 14,
          ),
        ),
      );

      getPolyPoints(); // Update polyline when location changes
    });
  }

  void getPolyPoints() async {
    if (currentLocation == null) return;

    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: google_api_key,
      request: PolylineRequest(
        origin: PointLatLng(barberLocation.latitude, barberLocation.longitude),
        destination: PointLatLng(
            destinationLocation.latitude, destinationLocation.longitude),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
      setState(() {});
    }
  }

  Future<void> getEstimatedArrivalTime() async {
    try {
      final url =
          "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric"
          "&origins=${barberLocation.latitude},${barberLocation.longitude}"
          "&destinations=${destinationLocation.latitude},${destinationLocation.longitude}"
          "&key=$google_api_key";

      final uri = Uri.parse(url);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          setState(() {
            estimatedTime = data['rows'][0]['elements'][0]['duration']['text'];
          });
        } else {
          setState(() {
            estimatedTime = 'Unable to fetch time';
          });
        }
      } else {
        setState(() {
          estimatedTime = 'Error fetching time';
        });
      }
    } catch (e) {
      setState(() {
        estimatedTime = 'Error: $e';
      });
    }
  }

  void setCustomMarkerIcon() async {
    currentLocationIcon =
        await getTransparentBitmap('asset/image/deliveryIcon.png');
    setState(() {});
  }

  Future<BitmapDescriptor> getTransparentBitmap(String assetPath,
      {int width = 100}) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List list = data.buffer.asUint8List();
    ui.Codec codec = await ui.instantiateImageCodec(list, targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();

    ByteData? byteData =
        await fi.image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  // Function to make a phone call
  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PrimaryColor,
      appBar: AppBar(
        backgroundColor: PrimaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: SecondaryColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Order Tracking', style: TextStyle(color: SecondaryColor)),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(widget.orderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final orderDoc = snapshot.data!;
          double barberLat = orderDoc['barberLatitude'].toDouble();
          double barberLng = orderDoc['barberLongitude'].toDouble();
          double customerLat = orderDoc['latitude'].toDouble();
          double customerLng = orderDoc['longitude'].toDouble();
          String barberPhoneNumber = orderDoc['barberNumber'].toString();

          barberLocation = LatLng(barberLat, barberLng);
          destinationLocation = LatLng(customerLat, customerLng);
          currentLocation = LocationData.fromMap({
            "latitude": barberLat,
            "longitude": barberLng,
          });

          getPolyPoints();

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(barberLat, barberLng),
                  zoom: 14,
                ),
                polylines: {
                  Polyline(
                    polylineId: PolylineId("route"),
                    color: Colors.blueAccent,
                    width: 6,
                    points: polylineCoordinates,
                  ),
                },
                markers: {
                  Marker(
                    markerId: const MarkerId('barberLocation'),
                    position: barberLocation,
                    icon: currentLocationIcon,
                  ),
                  Marker(
                    markerId: const MarkerId('customerLocation'),
                    position: destinationLocation,
                    icon: destinationIcon,
                  ),
                },
                onMapCreated: (mapController) {
                  _controller.complete(mapController);
                },
              ),

              /*if (estimatedTime != null)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black26)],
                    ),
                    child: Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.timer, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Estimated Arrival: $estimatedTime',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),*/
              Positioned(
                right: 5,
                bottom: 100,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                  ),
                  onPressed: () => _makePhoneCall(barberPhoneNumber),
                  child: const Icon(Icons.phone, size: 25, color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
