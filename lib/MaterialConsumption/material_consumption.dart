import 'package:avirat_energy/BarCode/barcode_scanner_screen.dart';
import 'package:avirat_energy/Delivery/delivery_screen.dart';
import 'package:avirat_energy/getmaterialconsummption.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Material_Screen extends StatefulWidget {
  final String username;
  Material_Screen({required this.username});
  @override
  _Material_ScreenState createState() => _Material_ScreenState();
}

class _Material_ScreenState extends State<Material_Screen> {
  TextEditingController _customerNameController = TextEditingController();
  TextEditingController _size1Controller = TextEditingController();
  TextEditingController _size2Controller = TextEditingController();
  TextEditingController _size3Controller = TextEditingController();
  TextEditingController _pvcController = TextEditingController();
  TextEditingController _basePlateController = TextEditingController();
  TextEditingController _autoroadController = TextEditingController();
  TextEditingController _pcCablesController = TextEditingController();
  TextEditingController _acCablesController = TextEditingController();
  TextEditingController _laCablesController = TextEditingController();
  bool isLoading = false;

  Future<void> sendDataToAPI() async {
    setState(() {
      isLoading = true;
    });

    final Map<String, dynamic> requestData = {
      'username': widget.username,

      'name_m': _customerNameController.text,
      '_40_40_53': _size1Controller.text,
      '_40_40_6': _size2Controller.text,
      '_60_40_6': _size3Controller.text,
      'pic_pipe': _pvcController.text,
      'base_plate': _basePlateController.text,
      'auto_road': _autoroadController.text,
      'pc_cable': _pcCablesController.text,
      'ac_cable': _acCablesController.text,
      'la_cable': _laCablesController.text,
    };
    try {
      var response = await http.post(
        Uri.parse('https://avirat-energy-backend.vercel.app/api/materials/'),
        body: requestData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        print('Data submitted successfully');
        // Navigate to the next screen
        String defaultUsername = 'DefaultUsername';
        String selectedUsername = widget.username ?? defaultUsername;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MaterialScreen(username: selectedUsername,)),
        );
      } else {
        // Request failed
        print('Failed to submit data: ${response.statusCode}');
      }
    } catch (e) {
      // Request error
      print('Error submitting data: $e');
    }finally {
      setState(() {
        isLoading = false;
      });
    }
  }

    /*try {
      var response = await http.post(
        Uri.parse('https://avirat-energy-backend.vercel.app/api/materials/'),
        body: requestData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Navigate to the next screen
        String defaultUsername = 'DefaultUsername';
        String selectedUsername = widget.username ?? defaultUsername;
        Navigator.push(context, MaterialPageRoute(builder: (context) => MaterialScreen(username:selectedUsername,)));
      } else if (response.statusCode == 307) {
        // Extract the new URI from the response headers
        String? newUri = response.headers['location'];
        if (newUri != null) {
          // Make another request to the new URI
          var newResponse = await http.post(
            Uri.parse(newUri),
            body: requestData,
          );
          // Check if the request to the new URI was successful
          if (newResponse.statusCode == 200 || newResponse.statusCode == 201) {
            // Navigate to the next screen
            String defaultUsername = 'DefaultUsername';
            String selectedUsername = widget.username ?? defaultUsername;
            Navigator.push(context, MaterialPageRoute(builder: (context) => MaterialScreen(username:selectedUsername,)));
          } else {
            print('Failed to submit data to new URI: ${newResponse.statusCode}');
          }
        } else {
          print('New URI not found in response headers');
        }
      } else {
        print('Failed to submit data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error submitting data: $e');
    }
  }*/

  // Helper method to clear all text controllers
  void _clearTextControllers() {
    _customerNameController.clear();
    _size1Controller.clear();
    _size2Controller.clear();
    _size3Controller.clear();
    _pvcController.clear();
    _basePlateController.clear();
    _autoroadController.clear();
    _pcCablesController.clear();
    _acCablesController.clear();
    _laCablesController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Material Consumption',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade400,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            String defaultUsername = 'DefaultUsername';
            String selectedUsername = widget.username ?? defaultUsername;
            Navigator.push(context, MaterialPageRoute(builder: (context) => DeliveryScreen(username: selectedUsername,)));
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => MaterialScreen(username: selectedUsername,)));
            },
          ),
        ],

      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _customerNameController,
              decoration: InputDecoration(labelText: 'Customer Name'),
            ),
            _buildTextField(controller: _size1Controller, label: '40*40*5.3 ft'),
            _buildTextField(controller: _size2Controller, label: '40*40*6 ft'),
            _buildTextField(controller: _size3Controller, label: '60*40*6 ft'),
            _buildTextField(controller: _pvcController, label: 'PVC Pipe'),
            _buildTextField(controller: _basePlateController, label: 'Base Plate'),
            _buildTextField(controller: _autoroadController, label: 'Autoroad'),
            _buildTextField(controller: _pcCablesController, label: 'DC Cables'),
            _buildTextField(controller: _acCablesController, label: 'AC Cables/E Cables'),
            _buildTextField(controller: _laCablesController, label: 'LA Cables'),
            SizedBox(   height: MediaQuery.of(context).size.height / 50,),
            SizedBox(
              width: double.infinity,
              child: Expanded(

                child: ElevatedButton(
                  onPressed: () {
                    String defaultUsername = 'DefaultUsername';
                    String selectedUsername = widget.username ?? defaultUsername;
                    Navigator.push(context, MaterialPageRoute(builder: (context) => BarcodeScannerScreen(username: selectedUsername,)));
                  },
                  child: Text('Scanner'),
                ),
              ),
            ),
            SizedBox(   height: MediaQuery.of(context).size.height / 50,),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade400,
                ),
                onPressed: isLoading ? null : () async {
                  await sendDataToAPI();
                },
                child: isLoading ? CircularProgressIndicator() : Text('Submit', style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(   height: MediaQuery.of(context).size.height / 40,),
        TextField(
          controller: controller,
          decoration: InputDecoration(labelText: label),
        ),
      ],
    );
  }
}
