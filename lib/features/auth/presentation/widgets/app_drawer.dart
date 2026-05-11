import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_helper.dart';

class AppDrawer extends StatefulWidget {
  final Function(int) onItemSelected;
  final int selectedIndex;

  const AppDrawer({
    super.key,
    required this.onItemSelected,
    required this.selectedIndex,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _isYardIntakeExpanded = false;

  @override
  void initState() {
    super.initState();
    // Expand if one of the yard intake sub-items is selected
    if (widget.selectedIndex >= 1 && widget.selectedIndex <= 4) {
      _isYardIntakeExpanded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: Responsive.drawerWidth(context),
      backgroundColor: AppTheme.bgColor,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header / Logo
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Image.asset(
                "assets/images/logo/gme.png",
                height: Responsive.isTablet(context) ? 80 : 60,
              ),
            ),
            const Divider(color: Colors.white24, height: 1),

            // Drawer Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.grid_view,
                    title: "Dashboard",
                    index: 0,
                  ),

                  // Yard Intake with Submenu
                  _buildExpandableItem(
                    context: context,
                    icon: Icons.local_shipping_outlined,
                    title: "Yard Intake",
                    isExpanded: _isYardIntakeExpanded,
                    onToggle: () {
                      setState(() {
                        _isYardIntakeExpanded = !_isYardIntakeExpanded;
                      });
                    },
                    children: [
                      _buildSubmenuItem(
                        context: context,
                        title: "Intake Dashboard",
                        index: 1,
                      ),
                      _buildSubmenuItem(
                        context: context,
                        title: "Companies",
                        index: 2,
                      ),
                      _buildSubmenuItem(
                        context: context,
                        title: "Vehicles",
                        index: 3,
                      ),
                      _buildSubmenuItem(
                        context: context,
                        title: "Material Types",
                        index: 4,
                      ),
                    ],
                  ),

                  _buildDrawerItem(
                    context: context,
                    icon: Icons.plumbing,
                    title: "Crushing & Processing",
                    index: 5,
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.science_outlined,
                    title: "Assaying & Testing",
                    index: 6,
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.assignment_turned_in_outlined,
                    title: "Inspection & Certification",
                    index: 7,
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.inventory_2_outlined,
                    title: "Bagging & Warehousing",
                    index: 8,
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.conveyor_belt,
                    title: "Loading & Dispatch",
                    index: 9,
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.description_outlined,
                    title: "Export Documentation",
                    index: 10,
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.scale_outlined,
                    title: "Weighbridge",
                    index: 11,
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.send_outlined,
                    title: "Transportation",
                    index: 12,
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.attach_money,
                    title: "Invoices & Financials",
                    index: 13,
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.storage_outlined,
                    title: "Inventory & Traceability",
                    index: 14,
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.bar_chart_outlined,
                    title: "Reports",
                    index: 15,
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.business_outlined,
                    title: "Client Management",
                    index: 16,
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.people_outline,
                    title: "User Management",
                    index: 17,
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.settings_outlined,
                    title: "Settings",
                    index: 18,
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.phone_outlined,
                    title: "Contact Us",
                    index: 19,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    // Check if any child is active
    bool anyChildActive =
        widget.selectedIndex >= 1 && widget.selectedIndex <= 4;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: anyChildActive ? AppTheme.btnColor : Colors.transparent,
          ),
          child: ListTile(
            leading: Icon(
              icon,
              color: Colors.white,
              size: Responsive.iconSize(context, base: 22),
            ),
            title: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: Responsive.isTablet(context) ? 20 : 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            trailing: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.white54,
              size: Responsive.iconSize(context, base: 20),
            ),
            onTap: onToggle,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 0,
            ),
            dense: true,
          ),
        ),
        if (isExpanded) ...children,
      ],
    );
  }

  Widget _buildSubmenuItem({
    required BuildContext context,
    required String title,
    required int index,
  }) {
    final bool isActive = widget.selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      child: ListTile(
        title: Padding(
          padding: const EdgeInsets.only(left: 48),
          child: Text(
            title,
            style: TextStyle(
              color: isActive ? const Color(0xFFF07D4F) : Colors.white70,
              fontSize: Responsive.isTablet(context) ? 18 : 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        onTap: () {
          widget.onItemSelected(index);
          Navigator.pop(context);
        },
        dense: true,
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required int index,
    bool hasSubmenu = false,
  }) {
    final bool isActive = widget.selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.btnColor : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.white,
          size: Responsive.iconSize(context, base: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: Responsive.isTablet(context) ? 20 : 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        trailing: hasSubmenu
            ? Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white54,
                size: Responsive.iconSize(context, base: 20),
              )
            : null,
        onTap: () {
          widget.onItemSelected(index);
          Navigator.pop(context);
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        dense: true,
      ),
    );
  }
}
