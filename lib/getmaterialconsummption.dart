import 'dart:convert';
import 'package:avirat_energy/MaterialConsumption/material_consumption.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Materialgetaa {
  Materialgetaa({
    this.id,
    this.something1,
    this.something2,
    this.something3,
    this.picPipe,
    this.basePlate,
    this.autoRoad,
    this.pcCable,
    this.acCable,
    this.laCable,
    this.username,
    this.nameM,
  });

  num? id;
  num? something1;
  num? something2;
  num? something3;
  num? picPipe;
  num? basePlate;
  num? autoRoad;
  num? pcCable;
  num? acCable;
  num? laCable;
  String? username;
  String? nameM;

  factory Materialgetaa.fromJson(Map<String, dynamic> json) {
    return Materialgetaa(
      id: json['id'],
      something1: json['_40_40_53'],
      something2: json['_40_40_6'],
      something3: json['_60_40_6'],
      picPipe: json['pic_pipe'],
      basePlate: json['base_plate'],
      autoRoad: json['auto_road'],
      pcCable: json['pc_cable'],
      acCable: json['ac_cable'],
      laCable: json['la_cable'],
      username: json['username'],
      nameM: json['name_m'],
    );
  }
}

class MaterialScreen extends StatefulWidget {
  final String username;

  MaterialScreen({required this.username});

  @override
  _MaterialScreenState createState() => _MaterialScreenState();
}

class _MaterialScreenState extends State<MaterialScreen> {
  late List<Materialgetaa> _materials = [];
  late List<Materialgetaa> _filteredMaterials = [];
  TextEditingController _searchController = TextEditingController();

  late Future<List<Materialgetaa>> futureMaterials;

  @override
  void initState() {
    super.initState();
    futureMaterials = fetchMaterials();
  }

  Future<List<Materialgetaa>> fetchMaterials() async {
    final response = await http.get(Uri.parse('https://avirat-energy-backend.vercel.app/api/materials/${widget.username}'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return List<Materialgetaa>.from(data.map((item) => Materialgetaa.fromJson(item)));
    } else {
      throw Exception('Failed to load materials');
    }
  }

  void _filterMaterials(String query) {
    setState(() {
      _filteredMaterials = _materials
          .where((material) => material.nameM!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _deleteMaterial(BuildContext context, num? id) async {
    if (id == null) {
      print('Material id is null.');
      return;
    }

    final url = Uri.parse(
        'https://avirat-energy-backend.vercel.app/api/materials/$id/');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 204) {
        setState(() {
          _materials.removeWhere((material) => material.id == id);
          _filteredMaterials.removeWhere((material) => material.id == id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Material deleted successfully from screen and API'),
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
        print('Failed to delete material: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete material'),
          ),
        );
      }
    } catch (error) {
      print('Failed to delete material: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete material'),
        ),
      );
    }
  }

  Future<void> _handleRedirect(
      BuildContext context, num? id, String redirectUrl) async {
    try {
      final response = await http.delete(Uri.parse(redirectUrl));

      if (response.statusCode == 204) {
        setState(() {
          _materials.removeWhere((material) => material.id == id);
          _filteredMaterials.removeWhere((material) => material.id == id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Material deleted successfully from screen and API'),
          ),
        );
      } else {
        print('Failed to delete material: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete material'),
          ),
        );
      }
    } catch (error) {
      print('Failed to delete material: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete material'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Material Details',
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => Material_Screen(username: selectedUsername,)));
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
                hintText: 'Search by username...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterMaterials,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Materialgetaa>>(
              future: futureMaterials,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  _materials = snapshot.data!;

                  return ListView.builder(
                    itemCount: _filteredMaterials.isNotEmpty ? _filteredMaterials.length : _materials.length,
                    itemBuilder: (context, index) {
                      final material = _filteredMaterials.isNotEmpty ? _filteredMaterials[index] : _materials[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Username : ${material.username ?? ''}'),
                              Text('Customer Name : ${material.nameM ?? ''}'),
                              Text('40*40*5.3 ft : ${material.something1 ?? ''}'),
                              Text('40*40*6 ft : ${material.something2 ?? ''}'),
                              Text('60*40*6 ft : ${material.something3 ?? ''}'),
                              Text('Pvc Pipe : ${material.picPipe ?? ''}'),
                              Text('Base Plate : ${material.basePlate ?? ''}'),
                              Text('Auto Road : ${material.autoRoad ?? ''}'),
                              Text('PC Cable : ${material.pcCable ?? ''}'),
                              Text('AC Cable : ${material.acCable ?? ''}'),
                              Text('LA Cable : ${material.laCable ?? ''}'),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Delete Confirmation'),
                                          content: Text(
                                              'Are you sure you want to delete this material?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                _deleteMaterial(
                                                    context,
                                                    material.id); // Pass the context here
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
                  );
                } else {
                  return Center(child: Text('No data available'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
