import 'package:avirat_energy/Animation/splash_screen.dart';
import 'package:avirat_energy/Auth/login_screen.dart';
import 'package:avirat_energy/BarCode/BarcodeScannerScreen.dart';
import 'package:avirat_energy/CustomerMaster/customer_master.dart';
import 'package:avirat_energy/Delivery/delivery_screen.dart';
import 'package:avirat_energy/MaterialConsumption/material_consumption.dart';
import 'package:avirat_energy/Payment/payment_screen.dart';
import 'package:avirat_energy/SignaturePad/signature_screen.dart';
import 'package:avirat_energy/get_customer.dart';
import 'package:avirat_energy/getdelivery.dart';
import 'package:avirat_energy/getmaterialconsummption.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  SplashScreen(),
    );
  }
}

