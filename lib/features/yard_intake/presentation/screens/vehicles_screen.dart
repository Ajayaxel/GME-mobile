import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gme/features/yard_intake/data/models/yard_intake_model.dart';
import 'package:gme/features/yard_intake/presentation/widgets/intake_create_sheet.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/services/injection_container.dart';
import '../../../../core/widgets/app_button.dart';
import '../bloc/yard_intake_bloc.dart';
import '../bloc/yard_intake_event.dart';
import '../bloc/yard_intake_state.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  String? _selectedVehicle;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<YardIntakeBloc>()..add(FetchYardIntake()),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: AppTheme.bgColor,
          body: BlocListener<YardIntakeBloc, YardIntakeState>(
            listener: (context, state) {
              if (state is YardIntakeCreateSuccess ||
                  state is YardIntakeDeleteSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state is YardIntakeCreateSuccess
                          ? "Vehicle added successfully"
                          : "Vehicle removed successfully",
                    ),
                  ),
                );
                context.read<YardIntakeBloc>().add(FetchYardIntake());
                if (state is YardIntakeDeleteSuccess) {
                  setState(() => _selectedVehicle = null);
                }
              }
            },
            child: BlocBuilder<YardIntakeBloc, YardIntakeState>(
              builder: (context, state) {
                if (state is YardIntakeLoading || state is YardIntakeInitial) {
                  return _buildLoadingShimmer(context);
                } else if (state is YardIntakeLoaded) {
                  final allIntakes = state.intakeList;
                  final uniqueVehicles = allIntakes
                      .map((e) => e.vehicleNumber)
                      .toSet()
                      .where(
                        (v) => v.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ),
                      )
                      .toList();

                  return Responsive.isTablet(context)
                      ? _buildTabletLayout(context, uniqueVehicles, allIntakes)
                      : _buildMobileLayout(context, uniqueVehicles, allIntakes);
                } else if (state is YardIntakeError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    List<String> vehicles,
    List<YardIntakeModel> allData,
  ) {
    return Row(
      children: [
        // Left Side: Vehicle Registry
        SizedBox(
          width: 350,
          child: _buildVehicleList(context, vehicles, allData),
        ),
        const VerticalDivider(color: Colors.white10, width: 1),
        // Right Side: Activity History
        Expanded(child: _buildActivityHistory(context, allData)),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    List<String> vehicles,
    List<YardIntakeModel> allData,
  ) {
    if (_selectedVehicle != null) {
      return WillPopScope(
        onWillPop: () async {
          setState(() => _selectedVehicle = null);
          return false;
        },
        child: _buildActivityHistory(context, allData),
      );
    }
    return _buildVehicleList(context, vehicles, allData);
  }

  Widget _buildVehicleList(
    BuildContext context,
    List<String> vehicles,
    List<YardIntakeModel> allData,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Vehicle Registry",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${vehicles.length} Authenticated vehicles in system",
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Search vehicles...",
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Colors.white38),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final v = vehicles[index];
                final isSelected = _selectedVehicle == v;
                return GestureDetector(
                  onTap: () => setState(() => _selectedVehicle = v),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.btnColor.withOpacity(0.2)
                          : Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppTheme.btnColor : Colors.white10,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_shipping,
                          color: Colors.white54,
                          size: 20,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          v,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.chevron_right,
                          color: Colors.white24,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                            size: 18,
                          ),
                          onPressed: () =>
                              _showDeleteConfirmDialog(context, v, allData),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    String vehicleNumber,
    List<YardIntakeModel> allData,
  ) {
    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog(
        backgroundColor: AppTheme.bgColor,
        title: const Text(
          "Delete Vehicle",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Are you sure you want to delete vehicle $vehicleNumber and all its records?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(innerContext),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(innerContext);
              // Find all intakes for this vehicle and delete them
              final intakesToDelete = allData
                  .where((e) => e.vehicleNumber == vehicleNumber)
                  .toList();
              for (var intake in intakesToDelete) {
                context.read<YardIntakeBloc>().add(DeleteYardIntake(intake.id));
              }
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showRecordDeleteConfirm(BuildContext context, YardIntakeModel item) {
    showDialog(
      context: context,
      builder: (innerContext) => AlertDialog(
        backgroundColor: AppTheme.bgColor,
        title: const Text(
          "Delete Record",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Are you sure you want to delete the record ${item.grnNumber}?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(innerContext),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(innerContext);
              context.read<YardIntakeBloc>().add(DeleteYardIntake(item.id));
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityHistory(
    BuildContext context,
    List<YardIntakeModel> allData,
  ) {
    return Column(
      children: [
        // Constant Header for the right side body
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _selectedVehicle == null
                      ? "Operational History"
                      : "History: $_selectedVehicle",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showAddVehicleSheet(context, allData),
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Add Vehicle"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.btnColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (_selectedVehicle == null)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.white.withOpacity(0.05),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Select a vehicle",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Choose a vehicle from the registry to view\nits operational history across all modules.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                ],
              ),
            ),
          )
        else ...[
          if (!Responsive.isTablet(context))
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => setState(() => _selectedVehicle = null),
              ),
              title: Text(
                _selectedVehicle!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (Responsive.isTablet(context)) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Activity Records",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "${allData.where((e) => e.vehicleNumber == _selectedVehicle).length} records found",
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                  Expanded(
                    child: ListView.builder(
                      itemCount: allData
                          .where((e) => e.vehicleNumber == _selectedVehicle)
                          .length,
                      itemBuilder: (context, index) {
                        final history = allData
                            .where((e) => e.vehicleNumber == _selectedVehicle)
                            .toList();
                        final item = history[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.supplierName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.grnNumber,
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(
                                            item.status,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          item.status,
                                          style: TextStyle(
                                            color: _getStatusColor(item.status),
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.redAccent,
                                          size: 16,
                                        ),
                                        onPressed: () =>
                                            _showRecordDeleteConfirm(
                                              context,
                                              item,
                                            ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.white10, height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _historyStat(
                                    "Net Wt",
                                    "${item.netWeight} kg",
                                  ),
                                  _historyStat(
                                    "Date",
                                    "${item.date.day}/${item.date.month}/${item.date.year}",
                                  ),
                                  _historyStat(
                                    "Material",
                                    item.materialTypes.isNotEmpty
                                        ? item.materialTypes.first.name
                                        : "N/A",
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showAddVehicleSheet(
    BuildContext context,
    List<YardIntakeModel> allData,
  ) {
    final TextEditingController vehicleController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppTheme.bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (innerContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(innerContext).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Add New Vehicle",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Register a new authorized vehicle to the system.",
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: vehicleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Vehicle Number",
                labelStyle: const TextStyle(color: Colors.white54),
                hintText: "e.g., KL-07-AB-1234",
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              text: "Add Vehicle",
              onPressed: () {
                final vehicleNumber = vehicleController.text.trim();
                if (vehicleNumber.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter vehicle number"),
                    ),
                  );
                  return;
                }

                context.read<YardIntakeBloc>().add(
                  CreateYardIntake({
                    'vehicleNumber': vehicleNumber,
                    'supplierName': 'Vehicle Registry',
                    'grossWeight': 0,
                    'tareWeight': 0,
                    'materialType': [],
                    'status': 'Pending',
                    'customerName': 'N/A',
                  }),
                );

                Navigator.pop(innerContext);
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _historyStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.greenAccent;
      case 'paid':
        return Colors.blueAccent;
      default:
        return Colors.orangeAccent;
    }
  }

  Widget _buildLoadingShimmer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: List.generate(
          5,
          (index) => Shimmer.fromColors(
            baseColor: Colors.white10,
            highlightColor: Colors.white24,
            child: Container(
              height: 100,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
