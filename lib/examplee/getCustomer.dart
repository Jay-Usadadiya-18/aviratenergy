/*

import 'dart:convert';
import 'dart:io';
import 'package:avirat_energy/CustomerMaster/customer_master.dart';
import 'package:avirat_energy/Delivery/delivery_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';

class PostModel {
  final int id;
  final String username;
  final String name;
  final String mobileNumber;
  final String panelBrand;
  final String panelQuality;
  final String inverterBrand;
  final int panelWatt;
  final String lightBillImage;
  final String passbookImage;
  final String panCardImage;
  final String uipImage;
  final String chequeImage;
  final String cashAmount;
  final int cashDenomination500;
  final int cashDenomination200;
  final int cashDenomination100;
  final int cashDenomination50;
  final int cashDenomination20;
  final int cashDenomination10;
  final String cashTotal;
  final String sitePhoto;

  PostModel({
    required this.id,
    required this.username,
    required this.name,
    required this.mobileNumber,
    required this.panelBrand,
    required this.panelQuality,
    required this.inverterBrand,
    required this.panelWatt,
    required this.lightBillImage,
    required this.passbookImage,
    required this.panCardImage,
    required this.uipImage,
    required this.chequeImage,
    required this.cashAmount,
    required this.cashDenomination500,
    required this.cashDenomination200,
    required this.cashDenomination100,
    required this.cashDenomination50,
    required this.cashDenomination20,
    required this.cashDenomination10,
    required this.cashTotal,
    required this.sitePhoto,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
      panelBrand: json['panel_brand'] ?? '',
      panelQuality: json['panel_quality'] ?? '',
      inverterBrand: json['inverter_brand'] ?? '',
      panelWatt: json['panel_watt'] ?? 0,
      lightBillImage: json['light_bill_image'] ?? '',
      passbookImage: json['passbook_image'] ?? '',
      panCardImage: json['pan_card_image'] ?? '',
      uipImage: json['uip_image'] ?? '',
      chequeImage: json['cheque_image'] ?? '',
      cashAmount: json['cash_amount'] ?? '',
      cashDenomination500: json['cash_denomination_500'] ?? 0,
      cashDenomination200: json['cash_denomination_200'] ?? 0,
      cashDenomination100: json['cash_denomination_100'] ?? 0,
      cashDenomination50: json['cash_denomination_50'] ?? 0,
      cashDenomination20: json['cash_denomination_20'] ?? 0,
      cashDenomination10: json['cash_denomination_10'] ?? 0,
      cashTotal: json['cash_total'] ?? '',
      sitePhoto: json['site_photo'] ?? '',
    );
  }
}

class ApiService {
  static Future<void> deleteCustomer(int id) async {
    final url = Uri.parse(
        'https://avirat-energy-backend.vercel.app/api/customer/$id/');
    try {
      final response = await _handleRedirection(() => http.delete(url));

      if (response.statusCode == 204) {
        print('Customer deleted successfully');
        // Perform any additional actions needed after successful deletion
      } else {
        print('Failed to delete customer: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to delete customer');
      }
    } catch (e) {
      print('Error deleting customer: $e');
      throw Exception('Failed to delete customer');
    }
  }

  static Future<http.Response> _handleRedirection(
      Future<http.Response> Function() request) async {
    const int maxRedirects = 5;
    var response = await request();
    var redirectCount = 0;
    while (redirectCount < maxRedirects &&
        (response.statusCode == 301 ||
            response.statusCode == 302 ||
            response.statusCode == 307)) {
      final redirectUrl = response.headers['location'];
      if (redirectUrl == null) {
        throw Exception(
            'Redirection response did not contain a location header');
      }
      print('Redirecting to: $redirectUrl');
      final newUrl = Uri.parse(redirectUrl);
      try {
        response = await http.delete(newUrl); // Modified to send DELETE request
        if (response.statusCode >= 400) {
          throw Exception('Error response: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Failed to follow redirect: $e');
      }
      redirectCount++;
    }
    return response;
  }
}

class CustomerMaster1 extends StatefulWidget {
  final String username;
  bool _isMounted = false;

  CustomerMaster1({Key? key, required this.username}) : super(key: key);

  @override
  State<CustomerMaster1> createState() => _CustomerMaster1State();
}

class _CustomerMaster1State extends State<CustomerMaster1> {
  late List<PostModel> _allPosts;
  late List<PostModel> _filteredPosts;
  TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    widget._isMounted = true;
    _allPosts = [];
    _filteredPosts = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchData();
  }

  @override
  void dispose() {
    widget._isMounted = false;
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final url = Uri.parse(
        'https://avirat-energy-backend.vercel.app/api/customers/${widget.username}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      setState(() {
        _allPosts = jsonData.map((item) => PostModel.fromJson(item)).toList();
        _filteredPosts =
            List.from(_allPosts); // Initialize filtered list with all posts
        _isLoading = false; // Data has been loaded
      });
    } else {
      setState(() {
        _isLoading = false; // Data loading failed
      });
      throw Exception('Failed to load data');
    }
  }
  void _filterPosts(String query) {
    setState(() {
      _filteredPosts = _allPosts
          .where(
              (post) => post.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Widget _buildImageWidget(BuildContext context, String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullScreenImage(imageUrl: imageUrl),
            ),
          );
        },
        child: Icon(Icons.image),
      );
    } else {
      // Return a placeholder widget when no image URL is provided
      return Text(
        'No Image Available',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          decoration: TextDecoration.underline,
        ),
      );
    }
  }

  Future<void> _deleteCustomer(BuildContext context, int id) async {
    try {
      // Send DELETE request to the REST API's endpoint
      await ApiService.deleteCustomer(id);

      setState(() {
        _allPosts.removeWhere((post) => post.id == id);
        _filteredPosts.removeWhere((post) => post.id == id);
      });

      if (widget._isMounted) {
        // Check if the widget is still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Customer deleted successfully from screen and API'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error deleting customer: $e');
      if (widget._isMounted) {
        // Check if the widget is still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete customer'),
          ),
        );
      }
    }
  }
  void _updateCustomer(BuildContext context, PostModel post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateCustomerScreen(post: post),
      ),
    ).then((shouldReload) {
      if (shouldReload ?? false) {
        // Reload data if necessary
        _fetchData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade400,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
            ),
            color: Colors.white,
            onPressed: () {
              String defaultUsername = 'DefaultUsername';
              String selectedUsername = widget.username ??
                  defaultUsername; // Accessing username using widget.username
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CustomerMaster(username: selectedUsername)),
              );
            }),
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Customer Information',
                style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              color: Colors.white,
              onPressed: () {
                String defaultUsername = 'DefaultUsername';
                String selectedUsername = widget.username ??
                    defaultUsername; // Accessing username using widget.username
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          DeliveryScreen(username: selectedUsername)),
                );
              },
            ),
          ],
        ),
      ),
      body:
      _isLoading
          ? Center(
        child: CircularProgressIndicator(), // Show loading indicator
      )
          : _filteredPosts.isEmpty
          ? Center(
        child: Text(
          'No customer information available',
          style: TextStyle(fontSize: 16.0),
        ),
      )
          : Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _filterPosts(value);
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _filteredPosts.map((post) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Customer Name :  ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      decoration: TextDecoration.underline,
                                      fontSize: 16),
                                ),
                                TextSpan(
                                  text: '${post.name}\n\n',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                                TextSpan(
                                  text: 'Mobile Number :  ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      decoration: TextDecoration.underline,
                                      fontSize: 16),
                                ),
                                TextSpan(
                                  text: '${post.mobileNumber}\n\n',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                                // Add other fields similarly
                                TextSpan(
                                  text: 'Panel Brand :  ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      decoration: TextDecoration.underline,
                                      fontSize: 16),
                                ),
                                TextSpan(
                                  text: '${post.panelBrand}\n\n',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                                TextSpan(
                                  text: 'Panel Quality :  ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      decoration: TextDecoration.underline,
                                      fontSize: 16),
                                ),
                                TextSpan(
                                  text: '${post.panelQuality}\n\n',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                                TextSpan(
                                  text: 'Inverter Brand :  ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      decoration: TextDecoration.underline,
                                      fontSize: 16),
                                ),
                                TextSpan(
                                  text: '${post.inverterBrand}\n\n',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                                TextSpan(
                                  text: 'Panel Watt :  ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      decoration: TextDecoration.underline,
                                      fontSize: 16),
                                ),
                                TextSpan(
                                  text: '${post.panelWatt}\n\n',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                                TextSpan(
                                  text: 'Cash Denomination 500 :  ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      decoration: TextDecoration.underline,
                                      fontSize: 16),
                                ),
                                TextSpan(
                                  text: '${post.cashDenomination500}\n\n',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                                TextSpan(
                                  text: 'Cash Denomination 200 :  ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      decoration: TextDecoration.underline,
                                      fontSize: 16),
                                ),
                                TextSpan(
                                  text: '${post.cashDenomination200}\n\n',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                                TextSpan(
                                  text: 'Cash Denomination 100 :  ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      decoration: TextDecoration.underline,
                                      fontSize: 16),
                                ),
                                TextSpan(
                                  text: '${post.cashDenomination100}\n\n',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                                TextSpan(
                                  text: 'Cash Denomination 50 :  ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      decoration: TextDecoration.underline,
                                      fontSize: 16),
                                ),
                                TextSpan(
                                  text: '${post.cashDenomination50}\n\n',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                                TextSpan(
                                  text: 'Cash Denomination 20 :  ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      decoration: TextDecoration.underline,
                                      fontSize: 16),
                                ),
                                TextSpan(
                                  text: '${post.cashDenomination20}\n\n',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                                TextSpan(
                                  text: 'Cash Denomination 10 :  ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      decoration: TextDecoration.underline,
                                      fontSize: 16),
                                ),
                                TextSpan(
                                  text: '${post.cashDenomination10}\n\n',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                                TextSpan(
                                  text: 'Cash Total :  ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      decoration: TextDecoration.underline,
                                      fontSize: 16),
                                ),
                                TextSpan(
                                  text: '${post.cashTotal}\n\n',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                                TextSpan(
                                  text: 'Rokda Name :  ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      decoration: TextDecoration.underline,
                                      fontSize: 16),
                                ),
                                TextSpan(
                                  text: '${post.cashAmount}\n\n',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: MediaQuery.sizeOf(context).height/100),
                          Text('Light Bill Image: ${post.lightBillImage}'),
                          SizedBox(height: MediaQuery.sizeOf(context).height/100),
                          _buildImageWidget(context, post.lightBillImage),
                          SizedBox(height: MediaQuery.sizeOf(context).height/100),
                          Divider(
                            thickness: 1,
                            color: Colors.black,
                          ),
                          Text('Passbook Image: ${post.passbookImage}'),
                          SizedBox(height: MediaQuery.sizeOf(context).height/100),
                          _buildImageWidget(context, post.passbookImage),
                          SizedBox(height: MediaQuery.sizeOf(context).height/100),
                          Divider(
                            thickness: 1,
                            color: Colors.black,
                          ),
                          Text('Pan Card Image: ${post.panCardImage}'),
                          SizedBox(height: MediaQuery.sizeOf(context).height/100),
                          _buildImageWidget(context, post.panCardImage),
                          SizedBox(height: MediaQuery.sizeOf(context).height/100),
                          Divider(
                            thickness: 1,
                            color: Colors.black,
                          ),
                          Text('Site Photo: ${post.sitePhoto}'),
                          SizedBox(height: MediaQuery.sizeOf(context).height/100),
                          _buildImageWidget(context, post.sitePhoto),
                          SizedBox(height: MediaQuery.sizeOf(context).height/100),
                          Divider(
                            thickness: 1,
                            color: Colors.black,
                          ),
                          Text('UIP Image: ${post.uipImage}'),
                          SizedBox(height: MediaQuery.sizeOf(context).height/100),
                          _buildImageWidget(context, post.uipImage),
                          SizedBox(height: MediaQuery.sizeOf(context).height/100),
                          Divider(
                            thickness: 1,
                            color: Colors.black,
                          ),
                          Text('Cheque Image: ${post.chequeImage}'),
                          SizedBox(height: MediaQuery.sizeOf(context).height/100),
                          _buildImageWidget(context, post.chequeImage),
                          SizedBox(height: MediaQuery.sizeOf(context).height/100),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // Show confirmation dialog before deleting
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Action Confirmation'),
                                      content: Text(
                                        'Do you want to update or delete this customer?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _updateCustomer(context, post);
                                          },
                                          child: Text('Update'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _deleteCustomer(context, post.id);
                                          },
                                          child: Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Text('Update'),
                              ),
                              SizedBox(width: 8.0),
                              ElevatedButton(
                                onPressed: () {
                                  // Show confirmation dialog before deleting
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Delete Confirmation'),
                                      content: Text(
                                          'Are you sure you want to delete this customer?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _deleteCustomer(context,
                                                post.id); // Pass the context here
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
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UpdateCustomerScreen extends StatefulWidget {
  final PostModel post;

  UpdateCustomerScreen({required this.post});

  @override
  _UpdateCustomerScreenState createState() => _UpdateCustomerScreenState();
}

class _UpdateCustomerScreenState extends State<UpdateCustomerScreen> {
  late TextEditingController _nameController;
  late TextEditingController _mobileNumberController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.post.name);
    _mobileNumberController =
        TextEditingController(text: widget.post.mobileNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileNumberController.dispose();
    super.dispose();
  }

  Future<void> _updateCustomer(int id) async {
    final updatedData = {
      'name': _nameController.text,
      'mobile_number': _mobileNumberController.text,
      // Add other fields similarly
    };

    try {
      final response = await http.put(
        Uri.parse('https://avirat-energy-backend.vercel.app/api/customer/$id/'),
        body: jsonEncode(updatedData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Customer updated successfully'),
          ),
        );
        Navigator.pop(context, true); // Signal parent to reload data
      } else {
        // Improve error handling to provide more informative message
        throw Exception(
            'Failed to update customer: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update customer: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Customer'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _mobileNumberController,
              decoration: InputDecoration(labelText: 'Mobile Number'),
            ),
            // Add other fields similarly
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _updateCustomer(widget.post.id);
              },
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: PhotoView(
          imageProvider: NetworkImage(
            imageUrl,
          ),
        ),
      ),
    );
  }
}

*/
