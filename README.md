# Barber Bud - On-Demand Barber Service App

Barber Bud is a mobile application that allows users to book personal barber services at their preferred location. The app aims to make barbering services more convenient by bringing barbers directly to customers.

## Features
- **Service Selection**: Browse and select barbering services.
- **E-Wallet Integration**: Top-up and make payments within the app.
- **Vouchers**: View available vouchers.
- **Real-Time Order Tracking**: Track your barber's location and order status.
- **Location Picker**: Select and save your service address.
- **User Profile Management**: View and update profile information.

## Tech Stack
- **Flutter**
- **Firebase Authentication**
- **Firebase Firestore**
- **Firebase Storage**
- **Google Maps API**

## Important Notes
- To enable map functionalities, you need to:
  1. Create your own `google_maps_API.dart` file and declare your API key:
     ```dart
     const String google_api_key = 'YOUR_GOOGLE_MAPS_API_KEY';
     ```
  2. Add your Google Maps API key to the native platform configurations:

     **For Android:**  
     Place your API key in  
     `android/app/src/main/AndroidManifest.xml` inside the `<application>` tag as:
     ```xml
     <meta-data
         android:name="com.google.android.geo.API_KEY"
         android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
     ```

     **For iOS:**  
     Add your API key in  
     `ios/Runner/AppDelegate.swift` by configuring the Google Maps SDK (if applicable).

- Replace all instances of `YOUR_GOOGLE_MAPS_API_KEY` with your actual API key.
- You can also use firebase storage to store you profile pictures,only a little configuration in profilepages  code needed.



## Installation
1. Clone the repository.
2. Run `flutter pub get`.
3. Configure Firebase project.
4. Add your `google_maps_API.dart` file.
5. Update Android and iOS native files with your API key.
6. Run the app using Android Studio or VS Code.

## License
This project is for educational purposes only.
