import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../core/models/area_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers with initial dummy data
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Dropdown selections
  String? _selectedGovernorateId;
  String? _selectedAreaId;

  // Data for dropdowns
  List<GovernorateWithAreas> _governoratesData = [];
  bool _isLoadingAreas = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _fetchAreas();
  }

  Future<void> _fetchAreas() async {
    setState(() => _isLoadingAreas = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      final client = ApiClient();
      final response = await client.fetchAreas(token: token);

      List<AreaModel> allAreas = response.map((json) => AreaModel.fromJson(json)).toList();

      // Group areas
      Map<String, List<AreaModel>> groupedAreas = {};
      for (var area in allAreas) {
        if (!groupedAreas.containsKey(area.governorateName)) {
          groupedAreas[area.governorateName] = [];
        }
        groupedAreas[area.governorateName]!.add(area);
      }

      List<GovernorateWithAreas> governorates = [];
      groupedAreas.forEach((govName, areas) {
        governorates.add(GovernorateWithAreas(
          governorateId: areas.first.governorateId,
          governorateName: govName,
          areas: areas,
        ));
      });

      if (mounted) {
        setState(() {
          _governoratesData = governorates;
          _isLoadingAreas = false;
        });
      }
    } catch (e) {
      print("Error fetching areas: $e");
      if (mounted) setState(() => _isLoadingAreas = false);
    }
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return;

      final client = ApiClient();
      final response = await client.get(ApiConstants.profile, token: token);

      if (response != null && response is Map) {
         setState(() {
           _nameController.text = response['fullName'] ?? response['name'] ?? '';
           _phoneController.text = response['phoneNumber'] ?? response['phone'] ?? '';
           _addressController.text = response['address'] ?? '';
           
           // Handle nullable IDs safely
           if (response['governorateId'] != null) {
              _selectedGovernorateId = response['governorateId'].toString();
           }
           if (response['areaId'] != null) {
              _selectedAreaId = response['areaId'].toString();
           }
         });
      }
    } catch (e) {
      print("Error loading profile: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final client = ApiClient();

      final payload = {
        "fullName": _nameController.text,
        "phoneNumber": _phoneController.text,
        "address": _addressController.text,
        if (_selectedGovernorateId != null) "governorateId": _selectedGovernorateId,
        if (_selectedAreaId != null) "areaId": _selectedAreaId,
      };

      await client.put(ApiConstants.profile, payload, token: token);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("تم حفظ التعديلات بنجاح"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل الحفظ: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Matching app theme
      appBar: AppBar(
        title: const Text(
          "تعديل الملف الشخصي",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.yellow[700], // Matching app theme
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoading 
      ? const Center(child: CircularProgressIndicator()) 
      : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture Edit
              Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.yellow[100],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.yellow[700]!, width: 2),
                    ),
                    child: Icon(Icons.person, size: 50, color: Colors.yellow[800]),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.black87,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              _buildTextField("الاسم", Icons.person_outline, _nameController),
              const SizedBox(height: 16),
              _buildTextField("رقم الهاتف", Icons.phone_android, _phoneController, isPhone: true),
              const SizedBox(height: 16),
              
              // Governorate Dropdown
              _isLoadingAreas 
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      value: _selectedGovernorateId,
                      items: _governoratesData.map((gov) {
                        return DropdownMenuItem(
                          value: gov.governorateId,
                          child: Text(gov.governorateName),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedGovernorateId = val;
                          _selectedAreaId = null; // Reset area
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "المحافظة",
                        prefixIcon: Icon(Icons.location_city, color: Colors.grey[600]),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.yellow[700]!)),
                      ),
                      validator: (val) => val == null ? "مطلوب" : null,
                    ),

              const SizedBox(height: 16),

              // Area Dropdown
              DropdownButtonFormField<String>(
                value: _selectedAreaId,
                items: (_selectedGovernorateId == null) 
                    ? [] 
                    : _governoratesData
                        .firstWhere((g) => g.governorateId == _selectedGovernorateId, orElse: () => GovernorateWithAreas(governorateId: "", governorateName: "", areas: []))
                        .areas
                        .map((area) {
                          return DropdownMenuItem(
                            value: area.id,
                            child: Text(area.name),
                          );
                        }).toList(),
                onChanged: _selectedGovernorateId == null 
                    ? null 
                    : (val) {
                        setState(() {
                          _selectedAreaId = val;
                        });
                      },
                decoration: InputDecoration(
                  labelText: "المنطقة",
                  prefixIcon: Icon(Icons.map_outlined, color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.yellow[700]!)),
                ),
                validator: (val) => val == null ? "مطلوب" : null,
              ),

              const SizedBox(height: 16),
              _buildTextField("اسم الشارع / تفاصيل العنوان", Icons.home_work_outlined, _addressController),
              
              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[700],
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "حفظ التغييرات",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool isPhone = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "هذا الحقل مطلوب";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.yellow[700]!),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
