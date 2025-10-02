import 'package:flutter/material.dart';
import '../main.dart';
import '../asset_list.dart';
import '../add_new_asset.dart';
import '../asset_details.dart';

class NavFooter extends StatefulWidget {
  final int initialIndex;
  const NavFooter({super.key, this.initialIndex = 0});

  @override
  State<NavFooter> createState() => _NavFooterState();
}

class _NavFooterState extends State<NavFooter> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, // To show all labels comment here if u want to hide it
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner_outlined),
          label: 'Scanner',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Assets',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_box_outlined),
          label: 'Add New Asset',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline_sharp),
          label: 'Asset Details',
        )
      ],
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });

        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const IndexPage()),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AssetList()),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AddNewAsset()),
          );
        }else if (index==3){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AssetDetails()),
          );
        }
      },
    );
  }
}
