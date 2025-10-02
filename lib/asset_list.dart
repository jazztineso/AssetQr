import 'package:flutter/material.dart';
import 'component/nav_footer.dart';
import 'asset_details.dart';

class AssetList extends StatelessWidget {
  const AssetList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text("Asset List"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Search functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              // Filter functionality
            },
          ),
        ],
      ),
      body: Column(
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
                  "All Assets",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "20 assets found",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Asset List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: 20,
              itemBuilder: (context, index) {
                return _buildAssetCard(context, index);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavFooter(initialIndex: 1),
    );
  }

  Widget _buildAssetCard(BuildContext context, int index) {
    final List<Map<String, dynamic>> assetData = [
      {
        'name': 'Laptop - Dell XPS 15',
        'id': 'AST-001',
        'location': 'Office 101',
        'status': 'Active',
        'statusColor': Colors.green,
        'icon': Icons.laptop,
        'iconColor': Colors.blue,
      },
      {
        'name': 'Projector - Epson EB-X41',
        'id': 'AST-002',
        'location': 'Conference Room A',
        'status': 'In Use',
        'statusColor': Colors.orange,
        'icon': Icons.videocam,
        'iconColor': Colors.purple,
      },
      {
        'name': 'Desk Chair - ErgoMax',
        'id': 'AST-003',
        'location': 'Warehouse B',
        'status': 'Available',
        'statusColor': Colors.green,
        'icon': Icons.chair,
        'iconColor': Colors.orange,
      },
      {
        'name': 'Monitor - LG 27" 4K',
        'id': 'AST-004',
        'location': 'Office 203',
        'status': 'Active',
        'statusColor': Colors.green,
        'icon': Icons.monitor,
        'iconColor': Colors.teal,
      },
      {
        'name': 'Printer - HP LaserJet',
        'id': 'AST-005',
        'location': 'Print Room',
        'status': 'Maintenance',
        'statusColor': Colors.red,
        'icon': Icons.print,
        'iconColor': Colors.indigo,
      },
    ];

    final asset = assetData[index % assetData.length];

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AssetDetails()),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (asset['iconColor'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  asset['icon'] as IconData,
                  color: asset['iconColor'] as Color,
                  size: 28,
                ),
              ),
              SizedBox(width: 16),

              // Asset Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset['name'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'ID: ${asset['id']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                        SizedBox(width: 4),
                        Text(
                          asset['location'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (asset['statusColor'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (asset['statusColor'] as Color).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  asset['status'] as String,
                  style: TextStyle(
                    color: asset['statusColor'] as Color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
