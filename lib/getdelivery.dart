import 'dart:convert';
import 'package:avirat_energy/Delivery/delivery_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DeliveryGet {
  final int id;
  final String username;
  final String transportName;
  final String nameD; // Add the new field
  final String panelBrand;
  final int size404053;
  final int size40406;
  final int size60406;
  final int pvcPipe;
  final int ekit;
  final int bfc;
  final int boxKit;

  DeliveryGet({
    required this.id,
    required this.username,
    required this.transportName,
    required this.nameD,
    required this.panelBrand,
    required this.size404053,
    required this.size40406,
    required this.size60406,
    required this.pvcPipe,
    required this.ekit,
    required this.bfc,
    required this.boxKit,
  });

  factory DeliveryGet.fromJson(Map<String, dynamic> json) {
    return DeliveryGet(
      id: json['id'],
      username: json['username'],
      transportName: json['transport_name'],
      nameD: json['name_d'], // Parse the new field

      panelBrand: json['panel_brand'],
      size404053: json['size_40_40_53'] ?? 0, // Provide a default value if null
      size40406: json['size_40_40_6'] ?? 0,
      size60406: json['size_60_40_6'] ?? 0,
      pvcPipe: json['pvc_pipe'] ?? 0,
      ekit: json['ekit'] ?? 0,
      bfc: json['bfc'] ?? 0,
      boxKit: json['box_kit'] ?? 0,
    );
  }
}

class DeliveryScreenGet extends StatefulWidget {
  final String username;

  DeliveryScreenGet({required this.username});

  @override
  _DeliveryScreenGetState createState() => _DeliveryScreenGetState();
}

class _DeliveryScreenGetState extends State<DeliveryScreenGet> {
  late List<DeliveryGet> _deliveries = [];
  late List<DeliveryGet> _filteredDeliveries = [];
  TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDeliveryData();
  }

  Future<void> _fetchDeliveryData() async {
    final url = Uri.parse(
        'https://avirat-energy-backend.vercel.app/api/delivery_orders/${widget.username}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          _deliveries =
              jsonData.map((data) => DeliveryGet.fromJson(data)).toList();
          _filteredDeliveries = List.from(_deliveries);
          _isLoading = false;

        });
      } else {
        print('Failed to load delivery data: ${response.statusCode}');
      }
    } catch (error) {
      print('Failed to load delivery data: $error');
    }
  }

  void _filterDeliveries(String query) {
    setState(() {
      _filteredDeliveries = _deliveries
          .where((delivery) => delivery.nameD
          .toLowerCase()
          .contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _deleteDelivery(BuildContext context, int id) async {
    final url = Uri.parse(
        'https://avirat-energy-backend.vercel.app/api/delivery-orders/$id/');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 204) {
        setState(() {
          _deliveries.removeWhere((delivery) => delivery.id == id);
          _filteredDeliveries.removeWhere((delivery) => delivery.id == id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delivery deleted successfully from screen and API'),
          ),
        );
      } else if (response.statusCode == 307) {
        final redirectUrl = response.headers['location'];
        if (redirectUrl != null) {
          await _handleRedirect(context, id, redirectUrl);
        } else {
          print('Redirect URL not found');
        }
      } else {
        print('Failed to delete delivery: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete delivery'),
          ),
        );
      }
    } catch (error) {
      print('Failed to delete delivery: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete delivery'),
        ),
      );
    }
  }

  Future<void> _handleRedirect(
      BuildContext context, int id, String redirectUrl) async {
    try {
      final response = await http.delete(Uri.parse(redirectUrl));

      if (response.statusCode == 204) {
        setState(() {
          _deliveries.removeWhere((delivery) => delivery.id == id);
          _filteredDeliveries.removeWhere((delivery) => delivery.id == id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delivery deleted successfully from screen and API'),
          ),
        );
      } else {
        print('Failed to delete delivery: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete delivery'),
          ),
        );
      }
    } catch (error) {
      print('Failed to delete delivery: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete delivery'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Delivery Details',
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

      ),

      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by transport name...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterDeliveries,
            ),
          ),
          Expanded(
          child: _isLoading // Check if loading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
        :  _filteredDeliveries.isNotEmpty
                ? ListView.builder(
              itemCount: _filteredDeliveries.length,
              itemBuilder: (context, index) {
                final delivery = _filteredDeliveries[index];
                return Padding(
                  padding: EdgeInsets.all(14.0),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Transport Name : ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: '${delivery.transportName}\n\n',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Customer Name : ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: '${delivery.nameD}\n\n',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(

                            children: [

                              TextSpan(
                                text: 'Username : ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: '${delivery.username}\n\n',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Panel Brand : ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: '${delivery.panelBrand}\n\n',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Size 40x40x53 : ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: '${delivery.size404053}\n\n',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Size 40x40x6 : ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: '${delivery.size40406}\n\n',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Size 60x40x6 : ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: '${delivery.size60406}\n\n',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'PVC Pipe : ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: '${delivery.pvcPipe}\n\n',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Ekit : ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: '${delivery.ekit}\n\n',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'BFC : ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: '${delivery.bfc}\n\n',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Box Kit : ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: '${delivery.boxKit}\n\n',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Add other delivery details similarly
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 8.0),
                            ElevatedButton(
                              onPressed: () {
                                // Show confirmation dialog before deleting
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Delete Confirmation'),
                                    content: Text(
                                        'Are you sure you want to delete this delivery?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context),
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _deleteDelivery(
                                              context,
                                              delivery.id); // Pass the context here
                                          Navigator.pop(context);
                                        },
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
                : Center(
              child: Text('No deliveries found'),
            ),
          ),
        ],
      ),
    );
  }
}
