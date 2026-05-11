import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../auth/presentation/widgets/app_drawer.dart';
import '../profile/presentation/screens/profile_screen.dart';
import '../dashboard/presentation/screens/dashboard_screen.dart';
import '../yard_intake/presentation/screens/yard_intake_screen.dart';
import '../yard_intake/presentation/screens/intake_dashboard_screen.dart';
import '../yard_intake/presentation/screens/companies_screen.dart';
import '../yard_intake/presentation/screens/vehicles_screen.dart';
import '../yard_intake/presentation/screens/material_types_screen.dart';
import '../processing/presentation/screens/processing_screen.dart';
import '../assaying/presentation/screens/assaying_screen.dart';
import '../inspection/presentation/screens/inspection_screen.dart';
import '../warehousing/presentation/screens/warehousing_screen.dart';
import '../dispatch/presentation/screens/dispatch_screen.dart';
import '../export/presentation/screens/export_screen.dart';
import '../weighbridge/presentation/screens/weighbridge_screen.dart';
import '../transportation/presentation/screens/transportation_screen.dart';
import '../financials/presentation/screens/financials_screen.dart';
import '../traceability/presentation/screens/traceability_screen.dart';
import '../reports/presentation/screens/reports_screen.dart';
import '../client_mgmt/presentation/screens/client_mgmt_screen.dart';
import '../user_mgmt/presentation/screens/user_mgmt_screen.dart';
import '../settings/presentation/screens/settings_screen.dart';
import '../contact_us/presentation/screens/contact_us_screen.dart';
import '../../core/utils/responsive_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const IntakeDashboardScreen(),
    const CompaniesScreen(),
    const VehiclesScreen(),
    const MaterialTypesScreen(),
    const ProcessingScreen(),
    const AssayingScreen(),
    const InspectionScreen(),
    const WarehousingScreen(),
    const DispatchScreen(),
    const ExportScreen(),
    const WeighbridgeScreen(),
    const TransportationScreen(),
    const FinancialsScreen(),
    const TraceabilityScreen(),
    const ReportsScreen(),
    const ClientMgmtScreen(),
    const UserMgmtScreen(),
    const SettingsScreen(),
    const ContactUsScreen(),
  ];

  final List<String> _titles = [
    "DASHBOARD",
    "INTAKE DASHBOARD",
    "COMPANIES",
    "VEHICLES",
    "MATERIAL TYPES",
    "CRUSHING & PROCESSING",
    "ASSAYING & TESTING",
    "INSPECTION & CERTIFICATION",
    "BAGGING & WAREHOUSING",
    "LOADING & DISPATCH",
    "EXPORT DOCUMENTATION",
    "WEIGHBRIDGE",
    "TRANSPORTATION",
    "INVOICES & FINANCIALS",
    "INVENTORY & TRACEABILITY",
    "REPORTS",
    "CLIENT MANAGEMENT",
    "USER MANAGEMENT",
    "SETTINGS",
    "CONTACT US",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      drawer: AppDrawer(
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedIndex: _selectedIndex,
      ),
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              child: CircleAvatar(
                radius: Responsive.profileAvatarRadius(context),
                backgroundColor: Colors.white24,
                child: Icon(
                  Icons.person,
                  size: Responsive.iconSize(context, base: 20),
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.isTablet(context) ? 60.0 : 0.0,
        ),
        child: IndexedStack(index: _selectedIndex, children: _pages),
      ),
    );
  }
}
