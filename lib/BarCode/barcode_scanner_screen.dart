import 'package:avirat_energy/Delivery/delivery_screen.dart';
import 'package:avirat_energy/barcodegetscreen.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:http/http.dart' as http;

class BarcodeScannerScreen extends StatefulWidget {
  final String username;
  BarcodeScannerScreen({required this.username});
  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  List<Map<String, String>> scannedBarcodes = [];
  TextEditingController descriptionController = TextEditingController();
  bool isLoading = false;

  Future<void> scanBarcode() async {
    try {
      var result = await BarcodeScanner.scan();
      setState(() {
        scannedBarcodes.add({
          'code': result.rawContent ?? "No data",
          'description': descriptionController.text,
        });
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> submitData() async {
    setState(() {
      isLoading = true;
    });
    try {
      for (var barcodeData in scannedBarcodes) {
        await sendBarcodeData(barcodeData);
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> sendBarcodeData(Map<String, String> barcodeData) async {
    final url = Uri.parse('https://avirat-energy-backend.vercel.app/api/barcodes/');
    final response = await http.post(
      url,
      body: {
        'code': barcodeData['code'] ?? '',
        'description': barcodeData['description'] ?? '',
        'username': widget.username,
      },
    );

    if (response.statusCode == 201) {
      print('Barcode data sent successfully');
    } else if (response.statusCode == 307) {
      // Handle redirect
      final newUrl = response.headers['location'];
      if (newUrl != null) {
        await sendBarcodeDataWithRedirect(barcodeData, Uri.parse(newUrl));
      } else {
        print('Redirect URL not found in headers');
      }
    } else {
      print('Failed to send barcode data. Status code: ${response.statusCode}');
    }
  }

  Future<void> sendBarcodeDataWithRedirect(Map<String, String> barcodeData, Uri redirectUrl) async {
    final response = await http.post(
      redirectUrl,
      body: {
        'code': barcodeData['code'] ?? '',
        'description': barcodeData['description'] ?? '',
        'username': widget.username,
      },
    );

    if (response.statusCode == 201) {
      print('Barcode data sent successfully');
    } else {
      print('Failed to send barcode data after redirect. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade400,
        title: Text(
          'Barcode Scanner',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            String defaultUsername = 'DefaultUsername';
            String selectedUsername = widget.username ?? defaultUsername;
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>DeliveryScreen(username: selectedUsername,)));
          },

        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ),
            onPressed: () {
              String defaultUsername = 'DefaultUsername';
              String selectedUsername = widget.username ?? defaultUsername;
              Navigator.push(context, MaterialPageRoute(builder: (context) => BarcodeGet(username: selectedUsername,)));
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: scannedBarcodes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer Name : ${scannedBarcodes[index]['description']}'),
                      Text('Code : ${scannedBarcodes[index]['code']}'),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(13.0),
            child: Column(
              children: [
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Customer Name'),
                ),
                SizedBox(   height: MediaQuery.of(context).size.height / 20,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade400,
                  ),
                  onPressed: scanBarcode,
                  child: Text('Scan Barcode', style: TextStyle(color: Colors.white)),
                ),
                SizedBox(   height: MediaQuery.of(context).size.height / 50,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade400,
                  ),
                  onPressed: isLoading ? null : submitData,
                  child: isLoading ? CircularProgressIndicator() : Text('Submit Data', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
