import 'package:final_year_project/Resources/constant.dart';
import 'package:flutter/material.dart';

class Aboutbarberbud extends StatelessWidget {
  const Aboutbarberbud({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PrimaryColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: SecondaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: PrimaryColor,
        title: Text(
          'About BarberBud',
          style: TextStyle(color: SecondaryColor),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                height: 200,
                width: 200,
              child: Image.asset('asset/image/BarberBudLogo.png',
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'BarberBud is an innovative platform designed for individuals seeking convenient and professional barbering services from the comfort of their homes. With just a few taps, users can book a personal barber who will provide high-quality haircuts, grooming, and styling services tailored to their preferences. Whether for a quick trim, a fresh fade, or a full grooming session, BarberBud connects customers with skilled barbers, ensuring a hassle-free and personalized experience.',
                style: TextStyle(color: SecondaryColor),
                textAlign: TextAlign.justify,
              ),
            ),
            SizedBox(height: 20),
            Text('Contact Us', style: TextStyle(color: SecondaryColor)),
            Text('Email: norosazwan10@gmail.com' , style: TextStyle(color: SecondaryColor)),
            Text('Phone: 012-3456789', style: TextStyle(color: SecondaryColor)),
          ],
        ),
      ),
    );
  }
}
