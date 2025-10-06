import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './component/nav_footer.dart';
import './models/asset.dart';
import './providers/asset_provider.dart';

class AddNewAsset extends StatefulWidget {
  const AddNewAsset({super.key});

  @override
  State<AddNewAsset> createState() => _AddNewAssetState();
}

class _AddNewAssetState extends State<AddNewAsset> {
  final _formKey = GlobalKey<FormState>();
  final _assetNameController = TextEditingController();
  final _assetIdController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedCategory = 'Electronics';
  String _selectedStatus = 'Active';
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _assetNameController.dispose();
    _assetIdController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveAsset() async {
    if (_formKey.currentState!.validate()) {
      final assetProvider = Provider.of<AssetProvider>(context, listen: false);

      final newAsset = Asset(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _assetNameController.text.trim(),
        assetId: _assetIdController.text.trim(),
        category: _selectedCategory,
        location: _locationController.text.trim(),
        status: _selectedStatus,
        purchaseDate: _selectedDate,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Saving asset...'),
            ],
          ),
          duration: Duration(seconds: 10),
        ),
      );

      try {
        // Wait for asset to be saved to database
        await assetProvider.addAsset(newAsset);

        // Check if widget is still mounted
        if (!mounted) return;

        // Hide loading indicator
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Asset added successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Clear form
        _assetNameController.clear();
        _assetIdController.clear();
        _locationController.clear();
        _notesController.clear();
        setState(() {
          _selectedCategory = 'Electronics';
          _selectedStatus = 'Active';
          _selectedDate = DateTime.now();
        });
      } catch (e) {
        // Check if widget is still mounted
        if (!mounted) return;

        // Hide loading indicator
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('Error saving asset: $e'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text("Add New Asset"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Register New Asset",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Fill in the details to add a new asset",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Form Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Asset Name Field
                    Text(
                      "Asset Information",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 16),

                    _buildTextField(
                      controller: _assetNameController,
                      label: "Asset Name",
                      hint: "Enter asset name",
                      icon: Icons.inventory_2,
                    ),
                    SizedBox(height: 16),

                    _buildTextField(
                      controller: _assetIdController,
                      label: "Asset ID",
                      hint: "Enter asset ID (e.g., AST-001)",
                      icon: Icons.qr_code,
                    ),
                    SizedBox(height: 16),

                    // Category Dropdown
                    _buildDropdown(
                      label: "Category",
                      value: _selectedCategory,
                      icon: Icons.category,
                      items: ['Electronics', 'Furniture', 'Equipment', 'Vehicles', 'Other'],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                    SizedBox(height: 16),

                    _buildTextField(
                      controller: _locationController,
                      label: "Location",
                      hint: "Enter location",
                      icon: Icons.location_on,
                    ),
                    SizedBox(height: 16),

                    // Status Dropdown
                    _buildDropdown(
                      label: "Status",
                      value: _selectedStatus,
                      icon: Icons.check_circle,
                      items: ['Active', 'Inactive', 'In Use', 'Maintenance', 'Retired'],
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                    ),
                    SizedBox(height: 24),

                    // Purchase Date
                    Text(
                      "Additional Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 16),

                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _selectedDate = pickedDate;
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.calendar_today, color: Colors.blue),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Purchase Date",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Notes field
                    _buildTextField(
                      controller: _notesController,
                      label: "Notes (Optional)",
                      hint: "Enter any additional notes",
                      icon: Icons.notes,
                      maxLines: 3,
                    ),

                    SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        onPressed: _saveAsset,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline, size: 24),
                            SizedBox(width: 12),
                            Text(
                              "Add Asset",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavFooter(initialIndex: 2),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            border: InputBorder.none,
            prefixIcon: Icon(icon, color: Colors.blue),
            labelStyle: TextStyle(color: Colors.grey.shade600),
          ),
          validator: (value) {
            if (!label.contains('Optional') && (value == null || value.isEmpty)) {
              return 'Please enter $label';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
            prefixIcon: Icon(icon, color: Colors.blue),
            labelStyle: TextStyle(color: Colors.grey.shade600),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
